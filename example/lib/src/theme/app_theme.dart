import 'package:flutter/material.dart';
import 'shadcn_colors.dart';

/// App ThemeData configuration following Shadcn UI design tokens.
abstract class AppTheme {
  /// Light theme based on Shadcn Slate neutral scheme with 1px subtle borders.
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      surface: ShadcnColors.lightCard,
      onSurface: ShadcnColors.lightForeground,
      primary: ShadcnColors.lightPrimary,
      onPrimary: ShadcnColors.lightPrimaryForeground,
      secondary: ShadcnColors.lightMuted,
      onSecondary: ShadcnColors.slate900,
      error: ShadcnColors.lightDestructive,
      onError: Colors.white,
      outline: ShadcnColors.lightBorder,
      outlineVariant: ShadcnColors.slate300,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ShadcnColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: ShadcnColors.lightCard,
        foregroundColor: ShadcnColors.lightForeground,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: ShadcnColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: ShadcnColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(
            color: ShadcnColors.lightBorder,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ShadcnColors.lightCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: ShadcnColors.lightInput,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: ShadcnColors.lightInput,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: ShadcnColors.lightPrimary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: ShadcnColors.lightDestructive,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: ShadcnColors.lightDestructive,
            width: 1.5,
          ),
        ),
        labelStyle: const TextStyle(
          color: ShadcnColors.lightMutedForeground,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: ShadcnColors.slate400,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ShadcnColors.lightPrimary,
          foregroundColor: ShadcnColors.lightPrimaryForeground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ShadcnColors.lightForeground,
          side: const BorderSide(
            color: ShadcnColors.lightBorder,
            width: 1,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: ShadcnColors.lightCard,
        selectedIconTheme: const IconThemeData(color: ShadcnColors.lightPrimary),
        unselectedIconTheme: const IconThemeData(
          color: ShadcnColors.lightMutedForeground,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: ShadcnColors.lightPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: ShadcnColors.lightMutedForeground,
          fontSize: 12,
        ),
        indicatorColor: ShadcnColors.lightMuted,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ShadcnColors.lightCard,
        elevation: 0,
        indicatorColor: ShadcnColors.lightMuted,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: ShadcnColors.lightPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: ShadcnColors.lightMutedForeground,
            fontSize: 12,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: ShadcnColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ShadcnColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(
            color: ShadcnColors.lightBorder,
            width: 1,
          ),
        ),
      ),
    );
  }

  /// Dark theme based on Shadcn Slate/Zinc dark scheme with 1px subtle borders.
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      surface: ShadcnColors.darkCard,
      onSurface: ShadcnColors.darkForeground,
      primary: ShadcnColors.darkPrimary,
      onPrimary: ShadcnColors.darkPrimaryForeground,
      secondary: ShadcnColors.darkMuted,
      onSecondary: ShadcnColors.slate50,
      error: ShadcnColors.darkDestructive,
      onError: Colors.black,
      outline: ShadcnColors.darkBorder,
      outlineVariant: ShadcnColors.slate700,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ShadcnColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: ShadcnColors.darkCard,
        foregroundColor: ShadcnColors.darkForeground,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: ShadcnColors.darkBorder,
            width: 1,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: ShadcnColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(
            color: ShadcnColors.darkBorder,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ShadcnColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: ShadcnColors.darkInput,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: ShadcnColors.darkInput,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: ShadcnColors.darkPrimary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: ShadcnColors.darkDestructive,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: ShadcnColors.darkDestructive,
            width: 1.5,
          ),
        ),
        labelStyle: const TextStyle(
          color: ShadcnColors.darkMutedForeground,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: ShadcnColors.slate500,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ShadcnColors.darkPrimary,
          foregroundColor: ShadcnColors.darkPrimaryForeground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ShadcnColors.darkForeground,
          side: const BorderSide(
            color: ShadcnColors.darkBorder,
            width: 1,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: ShadcnColors.darkCard,
        selectedIconTheme: const IconThemeData(color: ShadcnColors.darkPrimary),
        unselectedIconTheme: const IconThemeData(
          color: ShadcnColors.darkMutedForeground,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: ShadcnColors.darkPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: ShadcnColors.darkMutedForeground,
          fontSize: 12,
        ),
        indicatorColor: ShadcnColors.darkMuted,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ShadcnColors.darkCard,
        elevation: 0,
        indicatorColor: ShadcnColors.darkMuted,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: ShadcnColors.darkPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: ShadcnColors.darkMutedForeground,
            fontSize: 12,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: ShadcnColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ShadcnColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(
            color: ShadcnColors.darkBorder,
            width: 1,
          ),
        ),
      ),
    );
  }
}
