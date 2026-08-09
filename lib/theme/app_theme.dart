import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // PROJECT X / HABIO BLUE
  // ============================================================

  static const Color primaryBlue = Color(0xFF1557FF);
  static const Color lightBlue = Color(0xFFEEF3FF);

  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF667085);
  static const Color border = Color(0xFFE1E5EC);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // ----------------------------------------------------------
      // COLORS
      // ----------------------------------------------------------

      scaffoldBackgroundColor: background,

      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        onPrimary: Colors.white,

        secondary: primaryBlue,
        onSecondary: Colors.white,

        surface: surface,
        onSurface: textPrimary,

        error: Color(0xFFD92D20),
        onError: Colors.white,
      ),

      // ----------------------------------------------------------
      // TYPOGRAPHY
      // ----------------------------------------------------------

      fontFamily: 'Roboto',

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.15,
        ),

        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.15,
        ),

        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.2,
        ),

        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.2,
        ),

        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),

        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),

        bodyLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.4,
        ),

        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.4,
        ),

        bodySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),

        labelLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),

        labelMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),

      // ----------------------------------------------------------
      // TEXT SELECTION / CURSOR
      // THIS IS THE IMPORTANT PART
      // ----------------------------------------------------------

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primaryBlue,
        selectionColor: Color(0x331557FF),
        selectionHandleColor: primaryBlue,
      ),

      // ----------------------------------------------------------
      // APP BAR
      // ----------------------------------------------------------

      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,

        titleTextStyle: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),

        iconTheme: IconThemeData(
          color: textPrimary,
          size: 30,
        ),
      ),

      // ----------------------------------------------------------
      // INPUT FIELDS
      // ----------------------------------------------------------

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        hintStyle: const TextStyle(
          fontSize: 17,
          color: Color(0xFF98A2B3),
          fontWeight: FontWeight.w400,
        ),

        labelStyle: const TextStyle(
          fontSize: 17,
          color: textSecondary,
        ),

        floatingLabelStyle: const TextStyle(
          fontSize: 16,
          color: primaryBlue,
          fontWeight: FontWeight.w600,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: border,
            width: 1.4,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: primaryBlue,
            width: 2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFFD92D20),
            width: 1.5,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFFD92D20),
            width: 2,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // ELEVATED BUTTONS
      // ----------------------------------------------------------

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,

          minimumSize: const Size(
            double.infinity,
            62,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // OUTLINED BUTTONS
      // ----------------------------------------------------------

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,

          minimumSize: const Size(
            double.infinity,
            62,
          ),

          side: const BorderSide(
            color: Color(0xFFD5DDEE),
            width: 1.5,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // FLOATING ACTION BUTTON
      // ----------------------------------------------------------

      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),

      // ----------------------------------------------------------
      // PROGRESS INDICATORS
      // ----------------------------------------------------------

      progressIndicatorTheme:
          const ProgressIndicatorThemeData(
        color: primaryBlue,
      ),

      // ----------------------------------------------------------
      // CHECKBOX / RADIO / SWITCH
      // ----------------------------------------------------------

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return primaryBlue;
            }

            return null;
          },
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return primaryBlue;
            }

            return const Color(0xFF98A2B3);
          },
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return primaryBlue;
            }

            return const Color(0xFF667085);
          },
        ),
      ),

      // ----------------------------------------------------------
      // DIVIDERS
      // ----------------------------------------------------------

      dividerTheme: const DividerThemeData(
        color: Color(0xFFE4E7EC),
        thickness: 1,
      ),
    );
  }
}