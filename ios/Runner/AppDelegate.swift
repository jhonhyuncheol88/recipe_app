import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // UIScene lifecycle 마이그레이션: 플러그인 등록은 didInitializeImplicitFlutterEngine 으로 이동.
    // 이 콜백에서는 process-level 초기화만 수행한다.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Flutter 3.38+ : implicit engine 이 준비된 시점에 플러그인 / method channel / platform view 등록.
  // application:didFinishLaunchingWithOptions: 안에서 FlutterViewController 에 접근하면 크래시 가능.
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
