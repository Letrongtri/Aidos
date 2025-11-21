import 'package:ct312h_project/utils/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme() {
  const Color bgColor = Colors.black;
  const Color surfaceColor = Color(
    0xFF121212,
  ); // Màu xám tối cho các thẻ/dialog
  const Color primaryColor = Colors.white;
  const Color accentColor = Color(0xFFF0B916);
  const Color errorColor = Color(0xFFA40606);

  final baseTheme = ThemeData.dark(useMaterial3: true);

  return baseTheme.copyWith(
    scaffoldBackgroundColor: bgColor,

    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      onPrimary: Colors.black,
      secondary: accentColor,
      onSecondary: Colors.white,
      surface: bgColor,
      onSurface: primaryColor,
      surfaceContainerHighest: surfaceColor,
      error: errorColor,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: bgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryColor),
    ),

    // Cấu hình Typography (Font chữ)
    // Outfit: Hiện đại, hình học, bí ẩn cho Tiêu đề
    // DM Sans: Tròn trịa, thân thiện, dễ đọc cho Nội dung
    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        letterSpacing: -1.0,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        color: primaryColor,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        color: Colors.white70,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 11,
        color: Colors.white38,
        letterSpacing: 0.5,
      ),
    ),

    // Cấu hình Icon
    iconTheme: const IconThemeData(color: primaryColor, size: 24),

    // Transition
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: const AidosPageTransitionBuilder(),
        TargetPlatform.android: const AidosPageTransitionBuilder(),
      },
    ),
  );
}
