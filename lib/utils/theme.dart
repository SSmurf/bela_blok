import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Theme types
enum ThemeType { light, dark }

// Color palettes
enum ColorPalette { green, blue, red, purple, gold }

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
  ColorPalette.gold: {
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
  ColorPalette.gold: {
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

ThemeData getTheme(ThemeType type, ColorPalette palette) {
  final isPaletteDark = type == ThemeType.dark;
  final colors = isPaletteDark ? darkPaletteColors[palette]! : lightPaletteColors[palette]!;

  final textTheme = GoogleFonts.nunitoTextTheme(
    isPaletteDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
  );

  return ThemeData(
    brightness: isPaletteDark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme(
      brightness: isPaletteDark ? Brightness.dark : Brightness.light,
      primary: colors['primary']!,
      onPrimary: isPaletteDark ? darkBackgroundColor : lightTextColor,
      secondary: colors['secondary']!,
      onSecondary: isPaletteDark ? darkBackgroundColor : lightTextColor,
      tertiary: colors['tertiary']!,
      onTertiary: isPaletteDark ? darkBackgroundColor : lightTextColor,
      surface: isPaletteDark ? darkBackgroundColor : lightBackgroundColor,
      onSurface: isPaletteDark ? darkTextColor : lightTextColor,
      error: isPaletteDark ? const Color(0xffF2B8B5) : const Color(0xffB3261E),
      onError: isPaletteDark ? const Color(0xff601410) : const Color(0xffFFFFFF),
    ),
    scaffoldBackgroundColor: isPaletteDark ? darkBackgroundColor : lightBackgroundColor,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isPaletteDark ? darkTextColor : lightTextColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w400),
    ),
  );
}
