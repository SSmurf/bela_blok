import 'package:flutter/material.dart';

// Light theme constants
const Color lightTextColor = Color(0xFF333333);
const Color lightBackgroundColor = Color(0xFFfff8f0);
const Color lightPrimaryColor = Color(0xFF76dc74);
const Color lightPrimaryFgColor = Color(0xFF333333);
const Color lightSecondaryColor = Color(0xFFff6961);
const Color lightSecondaryFgColor = Color(0xFF333333);
const Color lightAccentColor = Color(0xFFffcf0f);
const Color lightAccentFgColor = Color(0xFF333333);

// Dark theme constants
const Color darkTextColor = Color(0xFFcccccc);
const Color darkBackgroundColor = Color(0xFF0f0800);
const Color darkPrimaryColor = Color(0xFF248b23);
const Color darkPrimaryFgColor = Color(0xFF0f0800);
const Color darkSecondaryColor = Color(0xFF9e0800);
const Color darkSecondaryFgColor = Color(0xFF0f0800);
const Color darkAccentColor = Color(0xFFf0c000);
const Color darkAccentFgColor = Color(0xFF0f0800);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: lightPrimaryColor,
    onPrimary: lightPrimaryFgColor,
    secondary: lightSecondaryColor,
    onSecondary: lightSecondaryFgColor,
    tertiary: lightAccentColor,
    onTertiary: lightAccentFgColor,
    surface: lightBackgroundColor,
    onSurface: lightTextColor,
    error: Color(0xffB3261E),
    onError: Color(0xffFFFFFF),
  ),
  scaffoldBackgroundColor: lightBackgroundColor,
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: darkPrimaryColor,
    onPrimary: darkPrimaryFgColor,
    secondary: darkSecondaryColor,
    onSecondary: darkSecondaryFgColor,
    tertiary: darkAccentColor,
    onTertiary: darkAccentFgColor,
    surface: darkBackgroundColor,
    onSurface: darkTextColor,
    error: Color(0xffF2B8B5),
    onError: Color(0xff601410),
  ),
  scaffoldBackgroundColor: darkBackgroundColor,
);
