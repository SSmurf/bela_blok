import 'package:flutter/material.dart';

// Theme types
enum ThemeType { light, dark }

// Color palettes
enum ColorPalette { green, blue, red, purple, orange }

// Palette colors for light mode
const Map<ColorPalette, Map<String, Color>> lightPaletteColors = {
  ColorPalette.green: {
    'primary': Color(0xFF76dc74),
    'secondary': Color(0xFFff6961),
    'tertiary': Color(0xFFffcf0f),
  },
  ColorPalette.blue: {
    'primary': Color(0xFF5dadec),
    'secondary': Color(0xFFff9e7d),
    'tertiary': Color(0xFFffda44),
  },
  ColorPalette.red: {
    'primary': Color(0xFFff5a5f),
    'secondary': Color(0xFF5ac8fa),
    'tertiary': Color(0xFFffbd00),
  },
  ColorPalette.purple: {
    'primary': Color(0xFF9e54bd),
    'secondary': Color(0xFF5fc9f8),
    'tertiary': Color(0xFFffcc00),
  },
  ColorPalette.orange: {
    'primary': Color(0xFFffb347),
    'secondary': Color(0xFF5ac8fa),
    'tertiary': Color(0xFF85ca5d),
  },
};

// Palette colors for dark mode
const Map<ColorPalette, Map<String, Color>> darkPaletteColors = {
  ColorPalette.green: {
    'primary': Color(0xFF248b23),
    'secondary': Color(0xFF9e0800),
    'tertiary': Color(0xFFf0c000),
  },
  ColorPalette.blue: {
    'primary': Color(0xFF0a84ff),
    'secondary': Color(0xFFe6535a),
    'tertiary': Color(0xFFd9a23f),
  },
  ColorPalette.red: {
    'primary': Color(0xFFe82a2f),
    'secondary': Color(0xFF0080bf),
    'tertiary': Color(0xFFd9a600),
  },
  ColorPalette.purple: {
    'primary': Color(0xFF7842a0),
    'secondary': Color(0xFF0080bf),
    'tertiary': Color(0xFFd9a600),
  },
  ColorPalette.orange: {
    'primary': Color(0xFFd99237),
    'secondary': Color(0xFF0080bf),
    'tertiary': Color(0xFF67a340),
  },
};

// Light and Dark base colors
const Color lightTextColor = Color(0xFF333333);
const Color lightBackgroundColor = Color(0xFFebe8e6);
const Color darkTextColor = Color(0xFFcccccc);
const Color darkBackgroundColor = Color(0xFF13110f);
const Color darkDialogSurfaceColor = Color(0xFF1F1C1A);

ThemeData getTheme(ThemeType type, ColorPalette palette) {
  final isPaletteDark = type == ThemeType.dark;
  final colors = isPaletteDark ? darkPaletteColors[palette]! : lightPaletteColors[palette]!;
  final textColor = isPaletteDark ? darkTextColor : lightTextColor;
  final baseTheme = isPaletteDark ? ThemeData.dark() : ThemeData.light();

  return ThemeData(
    brightness: isPaletteDark ? Brightness.dark : Brightness.light,
    fontFamily: 'Nunito',
    colorScheme: ColorScheme(
      brightness: isPaletteDark ? Brightness.dark : Brightness.light,
      primary: colors['primary']!,
      onPrimary: isPaletteDark ? Colors.white : lightTextColor,
      secondary: colors['secondary']!,
      onSecondary: isPaletteDark ? Colors.white : lightTextColor,
      tertiary: colors['tertiary']!,
      onTertiary: isPaletteDark ? Colors.white : lightTextColor,
      surface: isPaletteDark ? darkBackgroundColor : lightBackgroundColor,
      onSurface: textColor,
      error: isPaletteDark ? const Color(0xffF2B8B5) : const Color(0xffB3261E),
      onError: isPaletteDark ? const Color(0xff601410) : const Color(0xffFFFFFF),
    ),
    scaffoldBackgroundColor: isPaletteDark ? darkBackgroundColor : lightBackgroundColor,
    textTheme: baseTheme.textTheme,
    appBarTheme: AppBarTheme(
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: 'Nunito',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(0),
        foregroundColor: WidgetStateProperty.all(textColor),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
        ),
        // splashFactory: NoSplash.splashFactory,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
        splashFactory: NoSplash.splashFactory,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(textColor),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
        ),
        // splashFactory: NoSplash.splashFactory,
        side: WidgetStateProperty.all(const BorderSide(color: Colors.transparent)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(style: ButtonStyle(splashFactory: NoSplash.splashFactory)),
    tabBarTheme: TabBarThemeData(
      labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
      unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Nunito'),
    ),
    dialogTheme: DialogThemeData(
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Nunito',
        color: textColor,
      ),
      contentTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontFamily: 'Nunito',
        color: textColor,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      backgroundColor: isPaletteDark ? darkDialogSurfaceColor : lightBackgroundColor,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: isPaletteDark ? darkDialogSurfaceColor : lightBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      elevation: 0,
    ),
  );
}
