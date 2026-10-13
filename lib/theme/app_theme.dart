import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const seedColor = Color(0xFF006A6A);
  static const _fieldRadius = BorderRadius.all(Radius.circular(4));
  static const clickableButtonStyle = ButtonStyle(
    mouseCursor: WidgetStateMouseCursor.clickable,
  );

  static ThemeData get light => _theme(Brightness.light);

  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: _fieldRadius),
        enabledBorder: OutlineInputBorder(
          borderRadius: _fieldRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _fieldRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _fieldRadius,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: _fieldRadius,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: _fieldRadius,
          borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.38),
          ),
        ),
      ),
      elevatedButtonTheme: const ElevatedButtonThemeData(
        style: clickableButtonStyle,
      ),
      filledButtonTheme: const FilledButtonThemeData(
        style: clickableButtonStyle,
      ),
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
}
