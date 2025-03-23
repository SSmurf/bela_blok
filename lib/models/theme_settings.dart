import 'package:bela_blok/utils/theme.dart';

class ThemeSettings {
  final ThemeType themeType;
  final ColorPalette colorPalette;
  final bool useSystemTheme;

  ThemeSettings({
    this.themeType = ThemeType.light,
    this.colorPalette = ColorPalette.green,
    this.useSystemTheme = true,
  });

  Map<String, dynamic> toJson() => {
    'themeType': themeType.index,
    'colorPalette': colorPalette.index,
    'useSystemTheme': useSystemTheme,
  };

  factory ThemeSettings.fromJson(Map<String, dynamic> json) => ThemeSettings(
    themeType: ThemeType.values[json['themeType'] as int? ?? 0],
    colorPalette: ColorPalette.values[json['colorPalette'] as int? ?? 0],
    useSystemTheme: json['useSystemTheme'] as bool? ?? true,
  );
}
