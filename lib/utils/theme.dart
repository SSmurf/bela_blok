import 'package:flutter/material.dart';

// Theme types
enum ThemeType { light, dark }

// Color palettes
enum ColorPalette { green, spring, summer, autumn, winter }

// Palette colors for light mode
const Map<ColorPalette, Map<String, Color>> lightPaletteColors = {
  ColorPalette.green: {
    'primary': Color(0xFF76dc74),
    'secondary': Color(0xFFff6961),
    'tertiary': Color(0xFFffcf0f),
  },
};

// Palette colors for dark mode
const Map<ColorPalette, Map<String, Color>> darkPaletteColors = {
  ColorPalette.green: {
    'primary': Color(0xFF248b23),
    'secondary': Color(0xFF9e0800),
    'tertiary': Color(0xFFf0c000),
  },
};

ThemeData getTheme(ThemeType type, ColorPalette palette) {
  final isPaletteDark = type == ThemeType.dark;
  final brightness = isPaletteDark ? Brightness.dark : Brightness.light;

  ColorScheme colorScheme;
  if (palette == ColorPalette.green) {
    final colors = isPaletteDark ? darkPaletteColors[palette]! : lightPaletteColors[palette]!;
    colorScheme = ColorScheme.fromSeed(
      seedColor: colors['primary']!,
      primary: colors['primary']!,
      secondary: colors['secondary']!,
      tertiary: colors['tertiary']!,
      brightness: brightness,
    );
  } else {
    colorScheme =
        palette == ColorPalette.spring
            ? SeasonalThemes.spring(brightness)
            : palette == ColorPalette.summer
            ? SeasonalThemes.summer(brightness)
            : palette == ColorPalette.autumn
            ? SeasonalThemes.autumn(brightness)
            : SeasonalThemes.winter(brightness);
  }

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'Nunito',
    colorScheme: colorScheme,
    textTheme: const TextTheme().apply(
      fontFamily: 'Nunito',
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        fontFamily: 'Nunito',
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
      unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Nunito'),
    ),
    dialogTheme: DialogThemeData(
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Nunito',
        color: colorScheme.onSurface,
      ),
      contentTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontFamily: 'Nunito',
        color: colorScheme.onSurface,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      elevation: 0,
    ),
  );
}

class SeasonalThemes {
  //If there are two players/teams use the primary color for player 1 and tertiary color for player 2
  //If there are three players/teams use the primary color for player 1, secondary color for player 2 and tertiary color for player 3

  // --- SPRING: Fresh & Growth ---
  // Player 1: Sage, Player 2: Primrose, Player 3: Coral
  // Icon: Heart
  static ColorScheme spring(Brightness brightness) => ColorScheme.fromSeed(
    seedColor: const Color(0xFF8BAE66),
    primary: const Color(0xFF8BAE66),
    secondary: const Color(0xFFF3E5AB),
    tertiary: const Color(0xFFFFB7B2),
    brightness: brightness,
  );

  // --- SUMMER: Vibrant & High Energy ---
  // Player 1: Gold, Player 2: Leaf Green, Player 3: Sky Blue
  // Icon: Bell
  static ColorScheme summer(Brightness brightness) => ColorScheme.fromSeed(
    seedColor: const Color(0xFFFBC02D),
    primary: const Color(0xFFFBC02D),
    secondary: const Color(0xFF4CAF50),
    tertiary: const Color(0xFF0288D1),
    brightness: brightness,
  );

  // --- AUTUMN: Warm & Earthy ---
  // Player 1: Rust, Player 2: Earth Brown, Player 3: Olive
  // Icon: Leaf
  static ColorScheme autumn(Brightness brightness) => ColorScheme.fromSeed(
    seedColor: const Color(0xFFD84315),
    primary: const Color(0xFFD84315),
    secondary: const Color(0xFF8D6E63),
    tertiary: const Color(0xFF556B2F),
    brightness: brightness,
  );

  // --- WINTER: Cool & Deep ---
  // Player 1: Icy Blue, Player 2: Royal Purple, Player 3: Steel Grey
  // Icon: Acorn
  static ColorScheme winter(Brightness brightness) => ColorScheme.fromSeed(
    seedColor: const Color(0xFF1976D2),
    primary: const Color(0xFF1976D2),
    secondary: const Color(0xFF9C27B0),
    tertiary: const Color(0xFF607D8B),
    brightness: brightness,
  );
}
