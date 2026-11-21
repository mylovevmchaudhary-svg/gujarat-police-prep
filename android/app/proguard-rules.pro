# Code Obfuscation & Security Rules for Gujarat Police Prep
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable

# Obfuscate Flutter & Dart internal symbols to prevent reverse engineering
-repackageclasses 'com.police.prep.obfuscated'
-allowaccessmodification

# Suppress warnings
-dontwarn io.flutter.**
-dontwarn com.google.**

# Prevent tampering with Supabase models
-keep class com.supabase.** { *; }
