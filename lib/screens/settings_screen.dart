import 'package:bela_blok/models/app_settings.dart';
import 'package:bela_blok/providers/settings_provider.dart';
import 'package:bela_blok/screens/about_app_screen.dart';
import 'package:bela_blok/services/local_storage_service.dart';
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

  Future<void> _showGoalOptionsDialog(BuildContext context) async {
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
                    // "Odbaci": revert to original goal.
                    Navigator.of(context).pop(null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Odbaci', style: TextStyle(fontSize: 18)),
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
                  child: const Text('Spremi', style: TextStyle(fontSize: 18)),
                ),
              ],
            );
          },
        );
      },
    );

    // Process dialog result.
    // If result is not null, apply the new goal; else revert to the original goal.
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

  Future<void> _showStigljaOptionsDialog(BuildContext context) async {
    // Store the original stiglja value in case the dialog is dismissed.
    final int originalStiglja = _stigljaValue;
    // Ensure the selected option is one of the predefined values.
    int selectedOption = (_stigljaValue == 90 || _stigljaValue == 100) ? _stigljaValue : 90;

    final result = await showDialog<int>(
      context: context,
      barrierDismissible: true, // Allow the user to tap outside
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
                    // "Odbaci": revert to original stiglja value.
                    Navigator.of(context).pop(null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Odbaci', style: TextStyle(fontSize: 18)),
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
                  child: const Text('Spremi', style: TextStyle(fontSize: 18)),
                ),
              ],
            );
          },
        );
      },
    );

    // Process dialog result.
    // If result is not null, apply the new stiglja value; otherwise, revert to the original value.
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

  Future<void> _showTeamNamesDialog(BuildContext context) async {
    final teamOneController = TextEditingController(text: _teamOneName);
    final teamTwoController = TextEditingController(text: _teamTwoName);

    // Create keys for form validation
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Imena timova',
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500, fontSize: 18),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: teamOneController,
                  decoration: const InputDecoration(labelText: 'Prvi tim'),
                  textCapitalization: TextCapitalization.words,
                  maxLength: 20,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ime tima ne može biti prazno';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: teamTwoController,
                  decoration: const InputDecoration(labelText: 'Drugi tim'),
                  textCapitalization: TextCapitalization.words,
                  maxLength: 20,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ime tima ne može biti prazno';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    teamOneController.text = 'Mi';
                    teamTwoController.text = 'Vi';
                  },
                  icon: const Icon(HugeIcons.strokeRoundedUndo),
                  label: const Text('Postavi na Mi / Vi'),
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
              child: const Text(
                'Odustani',
                style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500, fontSize: 18),
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
              child: const Text(
                'Spremi',
                style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500, fontSize: 18),
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
    final halfLimit = 12;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        title: const Text('Postavke', style: TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Nunito')),
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
                title: const Text(
                  'Igra se do',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: Text(
                  _goalScore.toString(),
                  style: const TextStyle(fontSize: 14, fontFamily: 'Nunito'),
                ),
                onTap: () => _showGoalOptionsDialog(context),
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedCards02),
                title: const Text(
                  'Vrijednost štiglje',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: Text(
                  _stigljaValue.toString(),
                  style: const TextStyle(fontSize: 14, fontFamily: 'Nunito'),
                ),
                onTap: () => _showStigljaOptionsDialog(context),
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedUserEdit01),
                title: const Text(
                  'Imena timova',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: Text(
                  _formatTeamNames(_teamOneName, _teamTwoName),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontFamily: 'Nunito'),
                ),
                onTap: () => _showTeamNamesDialog(context),
              ),
              // ListTile(
              //   leading: const Icon(HugeIcons.strokeRoundedLanguageSkill),
              //   title: const Text('Jezik'),
              //   trailing: const Text('Hrvatski', style: TextStyle(fontSize: 14, fontFamily: 'Nunito')),
              //   onTap: () {},
              // ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedIdea01),
                title: const Text(
                  'Drži zaslon upaljen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: Transform.scale(
                  scale: 0.9,
                  child: Switch(value: _keepScreenOn, onChanged: _toggleWakelock),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedPaintBoard),
                title: const Text(
                  'Dizajn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                onTap: () => _showThemeOptions(context),
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedBookOpen01),
                title: const Text(
                  'Pravila bele',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                onTap: () => _launchURL(rulesUrl),
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedBookOpen02),
                title: const Text(
                  'Nepisana pravila bele',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                onTap: () => _launchURL(unspokenRulesUrl),
              ),
              const DeleteHistoryTile(),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedInformationSquare),
                title: const Text(
                  'O aplikaciji',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                ),
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AboutAppScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
