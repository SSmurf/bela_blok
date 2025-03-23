import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';

final settingsProvider =
    StateProvider<AppSettings>((ref) => AppSettings(goalScore: 1001));
