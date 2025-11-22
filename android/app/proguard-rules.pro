# Giữ lại class của thư viện notification
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepclassmembers class com.dexterous.flutterlocalnotifications.** { *; }

# Giữ lại các file R (Resource) để gọi bằng ID
-keepclassmembers class **.R$* {
    public static <fields>;
}