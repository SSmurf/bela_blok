import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/theme_settings.dart';
import '../services/local_storage_service.dart';
import '../utils/theme.dart';

class ThemeSettingsNotifier extends StateNotifier<ThemeSettings> {
  ThemeSettingsNotifier()
    : super(
        ThemeSettings(themeType: ThemeType.light, colorPalette: ColorPalette.green, useSystemTheme: true),
      ) {
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    final localStorage = LocalStorageService();
    final data = await localStorage.loadThemeSettings();
    if (data.isNotEmpty) {
      state = ThemeSettings.fromJson(data);
    }
  }

  Future<void> updateThemeSettings(ThemeSettings newSettings) async {
    state = newSettings;
    final localStorage = LocalStorageService();
    await localStorage.saveThemeSettings(newSettings.toJson());
  }
}

final themeSettingsProvider = StateNotifierProvider<ThemeSettingsNotifier, ThemeSettings>(
  (ref) => ThemeSettingsNotifier(),
);
