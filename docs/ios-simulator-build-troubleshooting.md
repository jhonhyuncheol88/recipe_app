# iOS Simulator Build Troubleshooting — 2026-05-07

## 요약

iOS 26.x 시뮬레이터 빌드가 다음 오류들로 실패했다.

```text
Framework 'Pods_Runner' not found
Building for 'iOS-simulator', but linking in object file ... MLImage.framework ... built for 'iOS'
Unable to find a destination matching the provided destination specifier
```

최종적으로 `flutter build ios --simulator --debug` 가 통과했다.

```text
✓ Built build/ios/iphonesimulator/Runner.app
```

## 왜 생겼나

### 1. `Pods_Runner.framework` 직접 링크 참조가 남아 있었음

`pod install` 은 Runner 프로젝트에 CocoaPods 설정을 다시 통합한다. 이 과정에서
`ios/Runner.xcodeproj/project.pbxproj` 의 `Link Binary With Libraries` 에
`Pods_Runner.framework` / `Pods_RunnerTests.framework` 참조가 들어갔다.

하지만 현재 Pods 구성에서는 `Pods_Runner.framework` 라는 실제 프레임워크 산출물이
생성되지 않는다. 각 Pod 프레임워크는 `Pods-Runner.*.xcconfig` 의
`OTHER_LDFLAGS` 와 `FRAMEWORK_SEARCH_PATHS` 로 직접 링크된다.

그래서 Xcode 링크 단계에서 존재하지 않는 `Pods_Runner.framework` 를 찾다가 실패했다.

### 2. `pod install` 을 다시 실행하면 참조가 재생성됨

처음에는 `project.pbxproj` 에서 stale 참조를 직접 제거했지만, `flutter build` 가
내부적으로 `pod install` 을 다시 실행하면서 동일 참조가 재삽입됐다.

따라서 한 번 수동 삭제하는 방식이 아니라, CocoaPods 통합 직후 자동으로 stale 참조를
제거하는 후처리가 필요했다.

### 3. MLKit `MLImage.framework` 의 arm64 시뮬레이터 호환 문제

`Pods_Runner` 문제가 사라진 뒤 다음 오류가 발생했다.

```text
Building for 'iOS-simulator', but linking in object file
... MLImage.framework/MLImage[arm64] ... built for 'iOS'
```

Apple Silicon Mac 에서는 iOS 시뮬레이터도 `arm64` 로 빌드될 수 있다. 그런데 현재
`google_mlkit_text_recognition` 이 끌고 오는 `MLImage (1.0.0-beta6)` 쪽 arm64 slice 가
시뮬레이터용이 아니라 디바이스용으로 취급되어 링크 충돌이 났다.

Pods 쪽에는 이미 시뮬레이터 `arm64` 제외가 들어가 있었지만 Runner 타겟에는 없어서,
Runner/RunnerTests 에도 같은 제외 설정을 적용했다.

## 수정 내용

### `ios/Podfile`

`post_integrate` 훅을 추가했다.

- `Pods_Runner.framework`
- `Pods_RunnerTests.framework`

위 stale framework 참조를 `Runner.xcodeproj` 에서 자동 제거한다.

또한 `Runner`, `RunnerTests` 타겟의 시뮬레이터 빌드에서 `arm64` 를 제외한다.

```ruby
config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
```

이 설정은 MLImage/MLKit 의 arm64 시뮬레이터 링크 충돌을 피하기 위한 현재 워크어라운드다.

### `ios/Runner.xcodeproj/project.pbxproj`

`pod install` 이후 자동 정리된 결과로 다음 참조가 제거된다.

- `Pods_Runner.framework in Frameworks`
- `Pods_RunnerTests.framework in Frameworks`
- Frameworks 그룹 안의 `Pods_Runner.framework`
- Frameworks 그룹 안의 `Pods_RunnerTests.framework`

## 앞으로 어떻게 해야 하나

### iOS 빌드/실행 기본 순서

의존성이나 Pod 관련 변경 뒤에는 아래 순서로 확인한다.

```bash
flutter pub get
cd ios
pod install
cd ..
flutter build ios --simulator --debug
```

실행은 현재 사용 가능한 디바이스 ID를 먼저 확인한 뒤 실행한다.

```bash
flutter devices
flutter run -d <device-id>
```

### Xcode로 실행할 때

항상 workspace 를 연다.

```text
ios/Runner.xcworkspace
```

`ios/Runner.xcodeproj` 만 열면 CocoaPods 타겟/설정이 빠져서 링크 문제가 다시 보일 수 있다.

### “destination not found” 가 뜰 때

다음 오류는 앱 코드나 Pod 링크 문제가 아니라 선택한 시뮬레이터 ID가 Xcode의 현재 빌드
대상 목록에 없다는 뜻이다.

```text
Unable to find a destination matching the provided destination specifier
```

이 경우 이전에 쓰던 ID를 고정해서 쓰지 말고, `flutter devices` 또는 Xcode의 available
destinations 에 표시되는 ID로 다시 실행한다.

### iOS 26.1 시뮬레이터 관련 주의

현재 워크어라운드는 시뮬레이터 빌드에서 `arm64` 를 제외해 `x86_64` 경로로 빌드한다.
따라서 특정 iOS 26.1 arm64 시뮬레이터 ID가 Xcode destination 에서 빠질 수 있다.

그럴 때는 available destination 에 표시되는 iOS 26.4.1 계열 시뮬레이터처럼, 현재 빌드
가능한 시뮬레이터 ID를 사용한다.

장기적으로 iOS 26.1 arm64 시뮬레이터를 꼭 지원해야 한다면 다음 중 하나를 검토한다.

- `google_mlkit_text_recognition` / `google_mlkit_commons` 최신 버전으로 업데이트
- MLKit iOS Pod 버전 갱신으로 `MLImage` 시뮬레이터 arm64 slice 호환성 확인
- 업데이트 후 `EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64` 워크어라운드 제거 가능 여부 검증

## 재발 시 체크리스트

1. `ios/Runner.xcodeproj/project.pbxproj` 에 `Pods_Runner` 문자열이 남아 있는지 확인한다.

```bash
rg "Pods_Runner|Pods_RunnerTests" ios/Runner.xcodeproj/project.pbxproj
```

결과가 없어야 정상이다.

2. `pod install` 후에도 위 문자열이 다시 생기지 않는지 확인한다.

```bash
cd ios
pod install
cd ..
rg "Pods_Runner|Pods_RunnerTests" ios/Runner.xcodeproj/project.pbxproj
```

3. 시뮬레이터 빌드가 통과하는지 확인한다.

```bash
flutter build ios --simulator --debug
```

4. 특정 ID로 실행이 안 되면 현재 디바이스 목록을 다시 본다.

```bash
flutter devices
```

## 검증 결과

수정 후 다음 명령이 성공했다.

```bash
flutter build ios --simulator --debug
```

결과:

```text
✓ Built build/ios/iphonesimulator/Runner.app
```
