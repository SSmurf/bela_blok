import 'package:bela_blok/models/app_settings.dart';
import 'package:bela_blok/providers/settings_provider.dart';
import 'package:bela_blok/providers/language_provider.dart';
import 'package:bela_blok/screens/about_app_screen.dart';
import 'package:bela_blok/services/local_storage_service.dart';
import 'package:bela_blok/utils/app_localizations.dart';
import 'package:bela_blok/widgets/delete_history_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../providers/theme_provider.dart';
import '../providers/game_provider.dart';
import '../providers/three_player_game_provider.dart';
import '../widgets/game_transfer_bottom_sheet.dart';
import '../widgets/theme_picker_bottom_sheet.dart';
import '../utils/player_name_utils.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final String rulesUrl = 'https://hr.wikipedia.org/wiki/Belot#Pravila';
  final String unspokenRulesUrl =
      'https://nepisanapravilabele.blogspot.com/2025/04/nepisana-pravila-bele.html';

  final GlobalKey _shareTileKey = GlobalKey();

  bool _keepScreenOn = true;
  int _goalScore = 1001;
  int _stigljaValue = 90;
  String _teamOneName = 'Mi';
  String _teamTwoName = 'Vi';
  bool _isThreePlayerMode = false;
  String _playerOneName = 'Osoba 1';
  String _playerTwoName = 'Osoba 2';
  String _playerThreeName = 'Osoba 3';

  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingsMap = await _localStorageService.loadSettings();
    if (settingsMap.isNotEmpty) {
      final settings = AppSettings.fromJson(settingsMap);
      final sanitizedSettings = settings.copyWith(
        playerOneName: settings.playerOneName.truncatedForThreePlayers,
        playerTwoName: settings.playerTwoName.truncatedForThreePlayers,
        playerThreeName: settings.playerThreeName.truncatedForThreePlayers,
      );
      // Load the saved language string and update the global language provider.
      final savedLang = settingsMap['selectedLanguage'] as String? ?? 'Hrvatski';
      final locale =
          savedLang == 'English'
              ? const Locale('en')
              : savedLang == 'Deutsch'
              ? const Locale('de')
              : const Locale('hr');
      ref.read(languageProvider.notifier).state = locale;
      setState(() {
        _goalScore = sanitizedSettings.goalScore;
        _stigljaValue = sanitizedSettings.stigljaValue;
        _teamOneName = sanitizedSettings.teamOneName;
        _teamTwoName = sanitizedSettings.teamTwoName;
        _isThreePlayerMode = sanitizedSettings.isThreePlayerMode;
        _playerOneName = sanitizedSettings.playerOneName;
        _playerTwoName = sanitizedSettings.playerTwoName;
        _playerThreeName = sanitizedSettings.playerThreeName;
      });
      ref.read(settingsProvider.notifier).state = sanitizedSettings;
    }
  }

  Map<String, dynamic> _buildSettingsMap(String languageString) {
    return {
      'goalScore': _goalScore,
      'stigljaValue': _stigljaValue,
      'teamOneName': _teamOneName,
      'teamTwoName': _teamTwoName,
      'selectedLanguage': languageString,
      'isThreePlayerMode': _isThreePlayerMode,
      'playerOneName': _playerOneName,
      'playerTwoName': _playerTwoName,
      'playerThreeName': _playerThreeName,
    };
  }

  String _getCurrentLanguageString() {
    final langCode = ref.read(languageProvider).languageCode;
    return langCode == 'en'
        ? 'English'
        : langCode == 'de'
        ? 'Deutsch'
        : 'Hrvatski';
  }

  Future<void> _saveLanguageSetting(Locale locale, String languageString) async {
    await _localStorageService.saveSettings(_buildSettingsMap(languageString));
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _reportProblem() async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'bela.podrska@gmail.com',
      query: 'subject=Bela Blok - Problem',
    );

    if (!await launchUrl(emailUri, mode: LaunchMode.platformDefault)) {
      throw 'Could not launch the email client';
    }
  }

  EdgeInsets _getDialogPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 375;

    return isSmallScreen
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 16)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  Future<bool?> _showActiveGameWarningDialog(BuildContext context, AppLocalizations loc) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 375;
    final buttonFontSize = isSmallScreen ? 16.0 : 18.0;

    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              loc.translate('activeGameTitle'),
              style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500, fontSize: 18),
            ),
            content: Text(
              loc.translate('activeGameContent'),
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 16),
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actionsPadding: _getDialogPadding(context),
            actions: [
              OverflowBar(
                alignment: MainAxisAlignment.spaceEvenly,
                spacing: isSmallScreen ? 8 : 16,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                      minimumSize: isSmallScreen ? const Size(90, 40) : const Size(100, 40),
                      padding:
                          isSmallScreen
                              ? const EdgeInsets.symmetric(horizontal: 8)
                              : const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      loc.translate('accept'),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w500,
                        fontSize: buttonFontSize,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                      minimumSize: isSmallScreen ? const Size(90, 40) : const Size(100, 40),
                      padding:
                          isSmallScreen
                              ? const EdgeInsets.symmetric(horizontal: 8)
                              : const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      loc.translate('discard'),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w500,
                        fontSize: buttonFontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  Future<void> _showGoalOptionsDialog(BuildContext context, AppLocalizations loc) async {
    final int originalGoal = _goalScore;
    int selectedOption = (_goalScore == 501 || _goalScore == 701 || _goalScore == 1001) ? _goalScore : 1001;

    final result = await showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth <= 375;
            final buttonFontSize = isSmallScreen ? 16.0 : 18.0;

            return AlertDialog(
              contentPadding:
                  isSmallScreen
                      ? const EdgeInsets.fromLTRB(16, 16, 16, 0)
                      : const EdgeInsets.fromLTRB(24, 20, 24, 0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<int>(
                    title: const Text('1001'),
                    controlAffinity: ListTileControlAffinity.trailing,
                    value: 1001,
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setStateSB(() {
                        selectedOption = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('701'),
                    controlAffinity: ListTileControlAffinity.trailing,
                    value: 701,
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setStateSB(() {
                        selectedOption = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('501'),
                    controlAffinity: ListTileControlAffinity.trailing,
                    value: 501,
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setStateSB(() {
                        selectedOption = value!;
                      });
                    },
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actionsPadding: _getDialogPadding(context),
              actions: [
                OverflowBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  spacing: isSmallScreen ? 8 : 16,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(selectedOption);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                        minimumSize: isSmallScreen ? const Size(90, 40) : const Size(100, 40),
                        padding:
                            isSmallScreen
                                ? const EdgeInsets.symmetric(horizontal: 8)
                                : const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(loc.translate('save'), style: TextStyle(fontSize: buttonFontSize)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(null);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                        minimumSize: isSmallScreen ? const Size(90, 40) : const Size(100, 40),
                        padding:
                            isSmallScreen
                                ? const EdgeInsets.symmetric(horizontal: 8)
                                : const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(loc.translate('cancel'), style: TextStyle(fontSize: buttonFontSize)),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result != originalGoal) {
      final isGameActive =
          _isThreePlayerMode
              ? ref.read(currentThreePlayerGameProvider).isNotEmpty
              : ref.read(currentGameProvider).isNotEmpty;

      bool proceed = true;
      if (isGameActive) {
        proceed = await _showActiveGameWarningDialog(context, loc) ?? false;
      }

      if (proceed) {
        if (isGameActive) {
          if (_isThreePlayerMode) {
            ref.read(currentThreePlayerGameProvider.notifier).clearRounds();
            await _localStorageService.clearCurrentThreePlayerGame();
          } else {
            ref.read(currentGameProvider.notifier).clearRounds();
            await _localStorageService.clearCurrentGame();
          }
        }

        setState(() {
          _goalScore = result;
        });
        ref.read(settingsProvider.notifier).state = AppSettings(
          goalScore: _goalScore,
          stigljaValue: _stigljaValue,
          teamOneName: _teamOneName,
          teamTwoName: _teamTwoName,
          isThreePlayerMode: _isThreePlayerMode,
          playerOneName: _playerOneName,
          playerTwoName: _playerTwoName,
          playerThreeName: _playerThreeName,
        );
        await _localStorageService.saveSettings(_buildSettingsMap(_getCurrentLanguageString()));
      }
    } else {
      setState(() {
        _goalScore = originalGoal;
      });
    }
  }

  Future<void> _showStigljaOptionsDialog(BuildContext context, AppLocalizations loc) async {
    final int originalStiglja = _stigljaValue;
    int selectedOption = (_stigljaValue == 90 || _stigljaValue == 100) ? _stigljaValue : 90;

    final result = await showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth <= 375;
            final buttonFontSize = isSmallScreen ? 16.0 : 18.0;

            return AlertDialog(
              contentPadding:
                  isSmallScreen
                      ? const EdgeInsets.fromLTRB(16, 16, 16, 0)
                      : const EdgeInsets.fromLTRB(24, 20, 24, 0),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<int>(
                      title: const Text('90'),
                      controlAffinity: ListTileControlAffinity.trailing,
                      value: 90,
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setStateSB(() {
                          selectedOption = value!;
                        });
                      },
                    ),
                    RadioListTile<int>(
                      title: const Text('100'),
                      controlAffinity: ListTileControlAffinity.trailing,
                      value: 100,
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setStateSB(() {
                          selectedOption = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actionsPadding: _getDialogPadding(context),
              actions: [
                OverflowBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  spacing: isSmallScreen ? 8 : 16,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _stigljaValue = selectedOption;
                        });
                        ref.read(settingsProvider.notifier).state = AppSettings(
                          goalScore: _goalScore,
                          stigljaValue: _stigljaValue,
                          teamOneName: _teamOneName,
                          teamTwoName: _teamTwoName,
                          isThreePlayerMode: _isThreePlayerMode,
                          playerOneName: _playerOneName,
                          playerTwoName: _playerTwoName,
                          playerThreeName: _playerThreeName,
                        );
                        _localStorageService.saveSettings(_buildSettingsMap(_getCurrentLanguageString()));
                        Navigator.of(context).pop(_stigljaValue);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                        minimumSize: isSmallScreen ? const Size(90, 40) : const Size(100, 40),
                        padding:
                            isSmallScreen
                                ? const EdgeInsets.symmetric(horizontal: 8)
                                : const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(loc.translate('save'), style: TextStyle(fontSize: buttonFontSize)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(null);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                        minimumSize: isSmallScreen ? const Size(90, 40) : const Size(100, 40),
                        padding:
                            isSmallScreen
                                ? const EdgeInsets.symmetric(horizontal: 8)
                                : const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(loc.translate('cancel'), style: TextStyle(fontSize: buttonFontSize)),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _stigljaValue = result;
      });
      ref.read(settingsProvider.notifier).state = AppSettings(
        goalScore: _goalScore,
        stigljaValue: _stigljaValue,
        teamOneName: _teamOneName,
        teamTwoName: _teamTwoName,
        isThreePlayerMode: _isThreePlayerMode,
        playerOneName: _playerOneName,
        playerTwoName: _playerTwoName,
        playerThreeName: _playerThreeName,
      );
      await _localStorageService.saveSettings(_buildSettingsMap(_getCurrentLanguageString()));
    } else {
      setState(() {
        _stigljaValue = originalStiglja;
      });
    }
  }

  Future<void> _showLanguageOptionsDialog(BuildContext context, AppLocalizations loc) async {
    final currentLocale = ref.read(languageProvider);
    String selected;
    if (currentLocale.languageCode == 'en') {
      selected = 'English';
    } else if (currentLocale.languageCode == 'de') {
      selected = 'Deutsch';
    } else {
      selected = 'Hrvatski';
    }

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth <= 375;
            final buttonFontSize = isSmallScreen ? 16.0 : 18.0;

            return AlertDialog(
              contentPadding:
                  isSmallScreen
                      ? const EdgeInsets.fromLTRB(16, 16, 16, 0)
                      : const EdgeInsets.fromLTRB(24, 20, 24, 0),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: const Text('Hrvatski 🇭🇷'),
                      value: 'Hrvatski',
                      controlAffinity: ListTileControlAffinity.trailing,
                      groupValue: selected,
                      onChanged: (value) {
                        setStateSB(() {
                          selected = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('English 🇬🇧'),
                      value: 'English',
                      controlAffinity: ListTileControlAffinity.trailing,
                      groupValue: selected,
                      onChanged: (value) {
                        setStateSB(() {
                          selected = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Deutsch 🇩🇪'),
                      value: 'Deutsch',
                      controlAffinity: ListTileControlAffinity.trailing,
                      groupValue: selected,
                      onChanged: (value) {
                        setStateSB(() {
                          selected = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actionsPadding: _getDialogPadding(context),
              actions: [
                OverflowBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  spacing: isSmallScreen ? 8 : 16,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(selected);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                        minimumSize: isSmallScreen ? const Size(90, 40) : const Size(100, 40),
                        padding:
                            isSmallScreen
                                ? const EdgeInsets.symmetric(horizontal: 8)
                                : const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(loc.translate('save'), style: TextStyle(fontSize: buttonFontSize)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(null);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                        minimumSize: isSmallScreen ? const Size(90, 40) : const Size(100, 40),
                        padding:
                            isSmallScreen
                                ? const EdgeInsets.symmetric(horizontal: 8)
                                : const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(loc.translate('cancel'), style: TextStyle(fontSize: buttonFontSize)),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      Locale newLocale;
      if (result == 'English') {
        newLocale = const Locale('en');
      } else if (result == 'Deutsch') {
        newLocale = const Locale('de');
      } else {
        newLocale = const Locale('hr');
      }

      bool isUsingDefaultTeamNames = false;
      if (_teamOneName == 'Mi' && _teamTwoName == 'Vi') {
        isUsingDefaultTeamNames = true;
      } else if (_teamOneName == 'We' && _teamTwoName == 'You') {
        isUsingDefaultTeamNames = true;
      } else if (_teamOneName == 'Wir' && _teamTwoName == 'Ihr') {
        isUsingDefaultTeamNames = true;
      }

      if (isUsingDefaultTeamNames) {
        final newLoc = AppLocalizations(newLocale);
        setState(() {
          _teamOneName = newLoc.translate('we');
          _teamTwoName = newLoc.translate('you');
        });
      }

      ref.read(languageProvider.notifier).state = newLocale;
      await _saveLanguageSetting(newLocale, result);

      ref.read(settingsProvider.notifier).state = AppSettings(
        goalScore: _goalScore,
        stigljaValue: _stigljaValue,
        teamOneName: _teamOneName,
        teamTwoName: _teamTwoName,
        isThreePlayerMode: _isThreePlayerMode,
        playerOneName: _playerOneName,
        playerTwoName: _playerTwoName,
        playerThreeName: _playerThreeName,
      );

      await _localStorageService.saveSettings(_buildSettingsMap(result));
    }
  }

  Future<void> _showTeamNamesDialog(BuildContext context, AppLocalizations loc) async {
    final teamOneController = TextEditingController(text: _teamOneName);
    final teamTwoController = TextEditingController(text: _teamTwoName);
    final formKey = GlobalKey<FormState>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 375;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            loc.translate('teamNames'),
            style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500, fontSize: 18),
          ),
          contentPadding:
              isSmallScreen
                  ? const EdgeInsets.fromLTRB(16, 16, 16, 0)
                  : const EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: teamOneController,
                  builder: (context, value, child) {
                    final hasText = value.text.isNotEmpty;

                    return TextFormField(
                      controller: teamOneController,
                      decoration: InputDecoration(
                        labelText: loc.translate('firstTeam'),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w500,
                        ),
                        suffixIcon:
                            hasText
                                ? IconButton(
                                  onPressed: () => teamOneController.clear(),
                                  icon: Icon(
                                    HugeIcons.strokeRoundedCancel01,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    size: 20,
                                  ),
                                  splashRadius: 20,
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        errorStyle: const TextStyle(fontSize: 0, height: 0),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (_) => formKey.currentState?.validate(),
                      style: const TextStyle(fontFamily: 'Nunito', fontSize: 16),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 20,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return loc.translate('emptyTeamName');
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: teamTwoController,
                  builder: (context, value, child) {
                    final hasText = value.text.isNotEmpty;

                    return TextFormField(
                      controller: teamTwoController,
                      decoration: InputDecoration(
                        labelText: loc.translate('secondTeam'),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w500,
                        ),
                        suffixIcon:
                            hasText
                                ? IconButton(
                                  onPressed: () => teamTwoController.clear(),
                                  icon: Icon(
                                    HugeIcons.strokeRoundedCancel01,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    size: 20,
                                  ),
                                  splashRadius: 20,
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        errorStyle: const TextStyle(fontSize: 0, height: 0),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (_) => formKey.currentState?.validate(),
                      style: const TextStyle(fontFamily: 'Nunito', fontSize: 16),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 20,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return loc.translate('emptyTeamName');
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    teamOneController.text = loc.translate('we');
                    teamTwoController.text = loc.translate('you');
                  },
                  icon: const Icon(HugeIcons.strokeRoundedUndo),
                  label: Text(loc.translate('resetTeamNames')),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: _getDialogPadding(context),
          actions: [
            OverflowBar(
              alignment: MainAxisAlignment.spaceEvenly,
              spacing: isSmallScreen ? 8 : 16,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final teamOne = teamOneController.text.trim();
                      final teamTwo = teamTwoController.text.trim();
                      Navigator.of(context).pop({'teamOne': teamOne, 'teamTwo': teamTwo});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    minimumSize: isSmallScreen ? const Size(90, 40) : const Size(100, 40),
                    padding:
                        isSmallScreen
                            ? const EdgeInsets.symmetric(horizontal: 8)
                            : const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    loc.translate('save'),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 16 : 18,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    minimumSize: isSmallScreen ? const Size(90, 40) : const Size(100, 40),
                    padding:
                        isSmallScreen
                            ? const EdgeInsets.symmetric(horizontal: 8)
                            : const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    loc.translate('cancel'),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 16 : 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _teamOneName = result['teamOne']!;
        _teamTwoName = result['teamTwo']!;
      });

      ref.read(settingsProvider.notifier).state = AppSettings(
        goalScore: _goalScore,
        stigljaValue: _stigljaValue,
        teamOneName: _teamOneName,
        teamTwoName: _teamTwoName,
        isThreePlayerMode: _isThreePlayerMode,
        playerOneName: _playerOneName,
        playerTwoName: _playerTwoName,
        playerThreeName: _playerThreeName,
      );

      await _localStorageService.saveSettings(_buildSettingsMap(_getCurrentLanguageString()));
    }
  }

  Future<void> _showPlayerNamesDialog(BuildContext context, AppLocalizations loc) async {
    final playerOneController = TextEditingController(text: _playerOneName.truncatedForThreePlayers);
    final playerTwoController = TextEditingController(text: _playerTwoName.truncatedForThreePlayers);
    final playerThreeController = TextEditingController(text: _playerThreeName.truncatedForThreePlayers);
    final formKey = GlobalKey<FormState>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 375;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            loc.translate('playerNames'),
            style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500, fontSize: 18),
          ),
          contentPadding:
              isSmallScreen
                  ? const EdgeInsets.fromLTRB(16, 16, 16, 0)
                  : const EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPlayerNameField(
                    playerOneController,
                    loc.translate('playerOne'),
                    formKey,
                    loc,
                    maxLength: kThreePlayerNameMaxLength,
                  ),
                  const SizedBox(height: 16),
                  _buildPlayerNameField(
                    playerTwoController,
                    loc.translate('playerTwo'),
                    formKey,
                    loc,
                    maxLength: kThreePlayerNameMaxLength,
                  ),
                  const SizedBox(height: 16),
                  _buildPlayerNameField(
                    playerThreeController,
                    loc.translate('playerThree'),
                    formKey,
                    loc,
                    maxLength: kThreePlayerNameMaxLength,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      playerOneController.text = loc.translate('person1').truncatedForThreePlayers;
                      playerTwoController.text = loc.translate('person2').truncatedForThreePlayers;
                      playerThreeController.text = loc.translate('person3').truncatedForThreePlayers;
                    },
                    icon: const Icon(HugeIcons.strokeRoundedUndo),
                    label: Text(loc.translate('resetPlayerNames')),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                  ),
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: _getDialogPadding(context),
          actions: [
            OverflowBar(
              alignment: MainAxisAlignment.spaceEvenly,
              spacing: isSmallScreen ? 8 : 16,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(context).pop({
                        'playerOne': playerOneController.text.trim(),
                        'playerTwo': playerTwoController.text.trim(),
                        'playerThree': playerThreeController.text.trim(),
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    minimumSize: isSmallScreen ? const Size(90, 40) : const Size(100, 40),
                    padding:
                        isSmallScreen
                            ? const EdgeInsets.symmetric(horizontal: 8)
                            : const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    loc.translate('save'),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 16 : 18,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    minimumSize: isSmallScreen ? const Size(90, 40) : const Size(100, 40),
                    padding:
                        isSmallScreen
                            ? const EdgeInsets.symmetric(horizontal: 8)
                            : const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    loc.translate('cancel'),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 16 : 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _playerOneName = result['playerOne']!.truncatedForThreePlayers;
        _playerTwoName = result['playerTwo']!.truncatedForThreePlayers;
        _playerThreeName = result['playerThree']!.truncatedForThreePlayers;
      });

      ref.read(settingsProvider.notifier).state = AppSettings(
        goalScore: _goalScore,
        stigljaValue: _stigljaValue,
        teamOneName: _teamOneName,
        teamTwoName: _teamTwoName,
        isThreePlayerMode: _isThreePlayerMode,
        playerOneName: _playerOneName,
        playerTwoName: _playerTwoName,
        playerThreeName: _playerThreeName,
      );

      await _localStorageService.saveSettings(_buildSettingsMap(_getCurrentLanguageString()));
    }
  }

  Widget _buildPlayerNameField(
    TextEditingController controller,
    String label,
    GlobalKey<FormState> formKey,
    AppLocalizations loc, {
    int maxLength = kThreePlayerNameMaxLength,
  }) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final hasText = value.text.isNotEmpty;
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w500,
            ),
            suffixIcon:
                hasText
                    ? IconButton(
                      onPressed: () => controller.clear(),
                      icon: Icon(
                        HugeIcons.strokeRoundedCancel01,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        size: 20,
                      ),
                      splashRadius: 20,
                    )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            errorStyle: const TextStyle(fontSize: 0, height: 0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (_) => formKey.currentState?.validate(),
          style: const TextStyle(fontFamily: 'Nunito', fontSize: 16),
          textCapitalization: TextCapitalization.words,
          maxLength: maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return loc.translate('emptyPlayerName');
            }
            return null;
          },
        );
      },
    );
  }

  Future<void> _toggleThreePlayerMode(bool value) async {
    setState(() {
      _isThreePlayerMode = value;
    });

    ref.read(settingsProvider.notifier).state = AppSettings(
      goalScore: _goalScore,
      stigljaValue: _stigljaValue,
      teamOneName: _teamOneName,
      teamTwoName: _teamTwoName,
      isThreePlayerMode: _isThreePlayerMode,
      playerOneName: _playerOneName,
      playerTwoName: _playerTwoName,
      playerThreeName: _playerThreeName,
    );

    await _localStorageService.saveSettings(_buildSettingsMap(_getCurrentLanguageString()));
  }

  Future<void> _showThemeOptions(BuildContext context) async {
    final currentSettings = ref.read(themeSettingsProvider);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return ThemePickerBottomSheet(
          currentSettings: currentSettings,
          onThemeSettingsChanged: (newSettings) {
            ref.read(themeSettingsProvider.notifier).updateThemeSettings(newSettings);
          },
        );
      },
    );
  }

  Future<void> _shareApp() async {
    const String appStoreUrl = 'https://apps.apple.com/app/bela-blok/id1234567890';
    const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.belablok.app';

    const String shareMessage =
        'Check out Bela Blok - the perfect app for belote score tracking! 🎴\n\n'
        'Download now:\n'
        '📱 iOS: $appStoreUrl\n'
        '🤖 Android: $playStoreUrl';

    // Get the render box to calculate share position origin for iOS
    final RenderBox? box = _shareTileKey.currentContext?.findRenderObject() as RenderBox?;
    Rect? rect;
    if (box != null && box.hasSize) {
      rect = box.localToGlobal(Offset.zero) & box.size;
    }

    await Share.share(shareMessage, sharePositionOrigin: rect);
  }

  void _toggleWakelock(bool value) async {
    setState(() {
      _keepScreenOn = value;
    });
    if (value) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(ref.watch(languageProvider));
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        title: Text(
          loc.translate('settings'),
          style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
        ),
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: Icon(HugeIcons.strokeRoundedArrowLeft01, size: 30),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedChampion),
                title: Text(
                  loc.translate('gameTo'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: Text(
                  _goalScore.toString(),
                  style: const TextStyle(fontSize: 14, fontFamily: 'Nunito'),
                ),
                onTap: () => _showGoalOptionsDialog(context, loc),
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedCards02),
                title: Text(
                  loc.translate('stigljaValue'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: Text(
                  _stigljaValue.toString(),
                  style: const TextStyle(fontSize: 14, fontFamily: 'Nunito'),
                ),
                onTap: () => _showStigljaOptionsDialog(context, loc),
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedUserEdit01),
                title: Text(
                  _isThreePlayerMode ? loc.translate('playerNames') : loc.translate('teamNames'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                onTap:
                    () =>
                        _isThreePlayerMode
                            ? _showPlayerNamesDialog(context, loc)
                            : _showTeamNamesDialog(context, loc),
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedUserMultiple),
                title: Text(
                  loc.translate('threePlayerMode'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: Transform.scale(
                  scale: 0.9,
                  child: Switch(value: _isThreePlayerMode, onChanged: _toggleThreePlayerMode),
                ),
                onTap: () => _toggleThreePlayerMode(!_isThreePlayerMode),
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedIdea01),
                title: Text(
                  loc.translate('keepScreenOn'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: Transform.scale(
                  scale: 0.9,
                  child: Switch(value: _keepScreenOn, onChanged: _toggleWakelock),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedPaintBoard),
                title: Text(
                  loc.translate('design'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                onTap: () => _showThemeOptions(context),
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedLanguageSkill),
                title: Text(
                  loc.translate('language'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: Text(
                  ref.watch(languageProvider).languageCode == 'en'
                      ? 'English'
                      : ref.watch(languageProvider).languageCode == 'de'
                      ? 'Deutsch'
                      : 'Hrvatski',
                  style: const TextStyle(fontSize: 14, fontFamily: 'Nunito'),
                ),
                onTap: () async {
                  await _showLanguageOptionsDialog(context, loc);
                  setState(() {});
                },
              ),
              const DeleteHistoryTile(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Divider(color: Colors.grey.withOpacity(0.8)),
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedQrCode),
                title: Text(
                  loc.translate('transferGame'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) => const GameTransferBottomSheet(),
                  );
                },
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedBookOpen01),
                title: Text(
                  loc.translate('rules'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                onTap: () => _launchURL(rulesUrl),
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedBookOpen02),
                title: Text(
                  loc.translate('unspokenRules'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                onTap: () => _launchURL(unspokenRulesUrl),
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedBug02),
                title: Text(
                  loc.translate('reportProblem'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                onTap: () => _reportProblem(),
              ),
              ListTile(
                key: _shareTileKey,
                leading: const Icon(HugeIcons.strokeRoundedShare01),
                title: Text(
                  loc.translate('shareApp'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                onTap: () => _shareApp(),
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedInformationSquare),
                title: Text(
                  loc.translate('aboutApp'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AboutAppScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
