import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../services/local_storage_service.dart';

final initialSettingsProvider = FutureProvider<AppSettings>((ref) async {
  final localStorageService = LocalStorageService();
  final settingsMap = await localStorageService.loadSettings();

  if (settingsMap.isNotEmpty) {
    return AppSettings.fromJson(settingsMap);
  } else {
    return AppSettings(goalScore: 1001, stigljaValue: 90, teamOneName: 'Mi', teamTwoName: 'Vi');
  }
});

final settingsProvider = StateProvider<AppSettings>((ref) {
  final initialSettingsAsync = ref.watch(initialSettingsProvider);

  return initialSettingsAsync.when(
    data: (settings) => settings,
    loading: () => AppSettings(goalScore: 1001, stigljaValue: 90, teamOneName: 'Mi', teamTwoName: 'Vi'),
    error: (_, __) => AppSettings(goalScore: 1001, stigljaValue: 90, teamOneName: 'Mi', teamTwoName: 'Vi'),
  );
});
