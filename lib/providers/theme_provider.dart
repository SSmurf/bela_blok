import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/theme_settings.dart';
import '../utils/theme.dart';

final themeSettingsProvider = StateProvider<ThemeSettings>(
  (ref) => ThemeSettings(themeType: ThemeType.light, colorPalette: ColorPalette.green, useSystemTheme: true),
);
