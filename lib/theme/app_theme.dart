import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const seedColor = Color(0xFF006A6A);
  static const clickableButtonStyle = ButtonStyle(
    mouseCursor: WidgetStateMouseCursor.clickable,
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ),
    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: clickableButtonStyle,
    ),
    filledButtonTheme: const FilledButtonThemeData(style: clickableButtonStyle),
    iconButtonTheme: const IconButtonThemeData(style: clickableButtonStyle),
    outlinedButtonTheme: const OutlinedButtonThemeData(
      style: clickableButtonStyle,
    ),
    segmentedButtonTheme: const SegmentedButtonThemeData(
      style: clickableButtonStyle,
    ),
    textButtonTheme: const TextButtonThemeData(style: clickableButtonStyle),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: clickableButtonStyle,
    ),
    filledButtonTheme: const FilledButtonThemeData(style: clickableButtonStyle),
    iconButtonTheme: const IconButtonThemeData(style: clickableButtonStyle),
    outlinedButtonTheme: const OutlinedButtonThemeData(
      style: clickableButtonStyle,
    ),
    segmentedButtonTheme: const SegmentedButtonThemeData(
      style: clickableButtonStyle,
    ),
    textButtonTheme: const TextButtonThemeData(style: clickableButtonStyle),
  );
}
