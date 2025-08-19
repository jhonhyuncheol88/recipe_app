# Flutter 관련 규칙 (필수만)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.embedding.engine.** { *; }

# Flame 패키지 제거됨

# Firebase 관련 규칙
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Google Play Core 관련 규칙 (누락된 클래스들 보호)
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# AdMob 관련 규칙
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.ads.identifier.** { *; }
-keep class com.google.android.gms.ads.formats.** { *; }
-keep class com.google.android.gms.ads.mediation.** { *; }



# 앱 모델 클래스 보호
-keep class com.jalam.recipeapp.model.** { *; }
-keep class com.jalam.recipeapp.data.** { *; }

# 일반적인 Android 규칙
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# 성능 최적화 (R8 호환성을 위해 조정)
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 3
-allowaccessmodification

# R8 호환성 설정
-dontwarn com.google.android.play.core.**
-dontwarn com.google.mlkit.vision.text.**

# 불필요한 로그 제거
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}

# 리소스 최적화
-keep class **.R$* {
    public static <fields>;
}

# 네이티브 메서드 보호
-keepclasseswithmembernames class * {
    native <methods>;
}

# Parcelable 구현 보호
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Serializable 구현 보호
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
