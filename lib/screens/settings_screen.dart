import 'package:bela_blok/models/app_settings.dart';
import 'package:bela_blok/providers/settings_provider.dart';
import 'package:bela_blok/screens/about_app_screen.dart';
import 'package:bela_blok/services/local_storage_service.dart';
import 'package:bela_blok/utils/app_localizations.dart';
import 'package:bela_blok/widgets/delete_history_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../providers/theme_provider.dart';
import '../widgets/theme_picker_bottom_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final String rulesUrl = 'https://hr.wikipedia.org/wiki/Belot#Pravila';
  // final String unpublishedRulesUrl = 'https://belaibelot.blogspot.com/p/n-e-p-i-s-n-pravila-bele.html';
  final String unspokenRulesUrl =
      'https://nepisanapravilabele.blogspot.com/2025/04/nepisana-pravila-bele.html';
  bool _keepScreenOn = true;
  int _goalScore = 1001;
  int _stigljaValue = 90;
  String _teamOneName = 'Mi';
  String _teamTwoName = 'Vi';
  String _selectedLanguage = 'Hrvatski';

  final LocalStorageService _localStorageService = LocalStorageService();

  Locale get _currentLocale {
    switch (_selectedLanguage) {
      case 'English':
        return const Locale('en');
      case 'Deutsch':
        return const Locale('de');
      case 'Hrvatski':
      default:
        return const Locale('hr');
    }
  }

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
      setState(() {
        _goalScore = settings.goalScore;
        _stigljaValue = settings.stigljaValue;
        _teamOneName = settings.teamOneName;
        _teamTwoName = settings.teamTwoName;
      });
      ref.read(settingsProvider.notifier).state = settings;
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _showGoalOptionsDialog(BuildContext context, AppLocalizations loc) async {
    // Store the original goal in case the dialog is dismissed.
    final int originalGoal = _goalScore;
    // Ensure the selected option is one of the predefined values.
    int selectedOption = (_goalScore == 501 || _goalScore == 701 || _goalScore == 1001) ? _goalScore : 1001;

    final result = await showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              // No title.
              content: SingleChildScrollView(
                child: Column(
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
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(loc.translate('cancel'), style: const TextStyle(fontSize: 18)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _goalScore = selectedOption;
                    });
                    ref.read(settingsProvider.notifier).state = AppSettings(
                      goalScore: _goalScore,
                      stigljaValue: _stigljaValue,
                      teamOneName: _teamOneName,
                      teamTwoName: _teamTwoName,
                    );
                    _localStorageService.saveSettings({
                      'goalScore': _goalScore,
                      'stigljaValue': _stigljaValue,
                    });
                    Navigator.of(context).pop(_goalScore);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(loc.translate('save'), style: const TextStyle(fontSize: 18)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _goalScore = result;
      });
      ref.read(settingsProvider.notifier).state = AppSettings(
        goalScore: _goalScore,
        stigljaValue: _stigljaValue,
        teamOneName: _teamOneName,
        teamTwoName: _teamTwoName,
      );
      await _localStorageService.saveSettings({'goalScore': _goalScore, 'stigljaValue': _stigljaValue});
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
            return AlertDialog(
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
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(loc.translate('cancel'), style: const TextStyle(fontSize: 18)),
                ),
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
                    );
                    _localStorageService.saveSettings({
                      'goalScore': _goalScore,
                      'stigljaValue': _stigljaValue,
                    });
                    Navigator.of(context).pop(_stigljaValue);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(loc.translate('save'), style: const TextStyle(fontSize: 18)),
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
      );
      await _localStorageService.saveSettings({'goalScore': _goalScore, 'stigljaValue': _stigljaValue});
    } else {
      setState(() {
        _stigljaValue = originalStiglja;
      });
    }
  }

  Future<void> _showLanguageOptionsDialog(BuildContext context, AppLocalizations loc) async {
    String selected = _selectedLanguage;
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
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
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(loc.translate('cancel'), style: const TextStyle(fontSize: 18)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(selected);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(loc.translate('save'), style: const TextStyle(fontSize: 18)),
                ),
              ],
            );
          },
        );
      },
    );
    if (result != null) {
      setState(() {
        _selectedLanguage = result;
      });
    }
  }

  Future<void> _showTeamNamesDialog(BuildContext context, AppLocalizations loc) async {
    final teamOneController = TextEditingController(text: _teamOneName);
    final teamTwoController = TextEditingController(text: _teamTwoName);

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            loc.translate('teamNames'),
            style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500, fontSize: 18),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: teamOneController,
                  decoration: InputDecoration(labelText: loc.translate('firstTeam')),
                  textCapitalization: TextCapitalization.words,
                  maxLength: 20,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.translate('emptyTeamName');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: teamTwoController,
                  decoration: InputDecoration(labelText: loc.translate('secondTeam')),
                  textCapitalization: TextCapitalization.words,
                  maxLength: 20,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.translate('emptyTeamName');
                    }
                    return null;
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
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                loc.translate('cancel'),
                style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ),
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
              ),
              child: Text(
                loc.translate('save'),
                style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500, fontSize: 18),
              ),
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
      );

      await _localStorageService.saveSettings({
        'goalScore': _goalScore,
        'stigljaValue': _stigljaValue,
        'teamOneName': _teamOneName,
        'teamTwoName': _teamTwoName,
      });
    }
  }

  String _formatTeamNames(String teamOne, String teamTwo) {
    final combined = '$teamOne, $teamTwo';
    const halfLimit = 12;

    if (combined.length <= 24) {
      return combined;
    }

    if (teamOne.length <= halfLimit) {
      final remainingSpace = 24 - teamOne.length - 2;
      return '$teamOne, ${teamTwo.substring(0, remainingSpace.clamp(0, teamTwo.length))}...';
    }

    if (teamTwo.length <= halfLimit) {
      final remainingSpace = 24 - teamTwo.length - 2;
      return '${teamOne.substring(0, remainingSpace.clamp(0, teamOne.length))}..., $teamTwo';
    }

    return '${teamOne.substring(0, halfLimit)}..., ${teamTwo.substring(0, halfLimit)}...';
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
    final loc = AppLocalizations(_currentLocale);
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
            physics: const NeverScrollableScrollPhysics(),
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
                  loc.translate('teamNames'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: Text(
                  _formatTeamNames(_teamOneName, _teamTwoName),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontFamily: 'Nunito'),
                ),
                onTap: () => _showTeamNamesDialog(context, loc),
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedLanguageSkill),
                title: Text(
                  loc.translate('language'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: Text(_selectedLanguage, style: const TextStyle(fontSize: 14, fontFamily: 'Nunito')),
                onTap: () async {
                  await _showLanguageOptionsDialog(context, loc);
                  // Force rebuild to have changes reflected.
                  setState(() {});
                },
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
              const DeleteHistoryTile(),
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
