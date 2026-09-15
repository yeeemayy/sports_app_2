# RongCloud IM SDK uses JNI + reflection; stripping breaks native method lookups.
-keep class io.rong.** { *; }
-dontwarn io.rong.**

# Firebase/Firestore models are (de)serialized via reflection.
-keepattributes Signature,*Annotation*
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
