import 'package:bela_blok/models/app_settings.dart';
import 'package:bela_blok/providers/settings_provider.dart';
import 'package:bela_blok/services/local_storage_service.dart';
import 'package:bela_blok/widgets/delete_history_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final String rulesUrl = 'https://hr.wikipedia.org/wiki/Belot#Pravila';
  final String unpublishedRulesUrl = 'https://belaibelot.blogspot.com/p/n-e-p-i-s-n-pravila-bele.html';
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

  Future<void> _showGoalOptions(BuildContext context) async {
    const options = [501, 701, 1001];
    final int? selectedOption = await showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                options.map((option) {
                  return ListTile(
                    title: Text(option.toString()),
                    trailing: _goalScore == option ? const Icon(Icons.check, color: Colors.green) : null,
                    onTap: () {
                      Navigator.pop(ctx, option);
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
    if (selectedOption != null) {
      setState(() {
        _goalScore = selectedOption;
      });
      ref.read(settingsProvider.notifier).state = AppSettings(
        goalScore: _goalScore,
        stigljaValue: _stigljaValue,
        teamOneName: _teamOneName,
        teamTwoName: _teamTwoName,
      );
      await _localStorageService.saveSettings({'goalScore': _goalScore, 'stigljaValue': _stigljaValue});
    }
  }

  Future<void> _showStigljaOptions(BuildContext context) async {
    const options = [90, 100];
    final int? selectedOption = await showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                options.map((option) {
                  return ListTile(
                    title: Text(option.toString()),
                    trailing: _stigljaValue == option ? const Icon(Icons.check, color: Colors.green) : null,
                    onTap: () {
                      Navigator.pop(ctx, option);
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
    if (selectedOption != null) {
      setState(() {
        _stigljaValue = selectedOption;
      });
      ref.read(settingsProvider.notifier).state = AppSettings(
        goalScore: _goalScore,
        stigljaValue: _stigljaValue,
        teamOneName: _teamOneName,
        teamTwoName: _teamTwoName,
      );
      await _localStorageService.saveSettings({'goalScore': _goalScore, 'stigljaValue': _stigljaValue});
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
          title: const Text('Imena timova'),
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
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Odustani')),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final teamOne = teamOneController.text.trim();
                  final teamTwo = teamTwoController.text.trim();

                  Navigator.of(context).pop({'teamOne': teamOne, 'teamTwo': teamTwo});
                }
              },
              child: const Text('Spremi'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Postavke')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedChampion),
                title: const Text('Igra se do'),
                trailing: Text(_goalScore.toString()),
                onTap: () => _showGoalOptions(context),
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedCards02),
                title: const Text('Vrijednost štiglje'),
                trailing: Text(_stigljaValue.toString()),
                onTap: () => _showStigljaOptions(context),
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedUserEdit01),
                title: const Text('Imena timova'),
                trailing: Text(_formatTeamNames(_teamOneName, _teamTwoName), overflow: TextOverflow.ellipsis),
                onTap: () => _showTeamNamesDialog(context),
              ),

              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedPaintBoard),
                title: const Text('Dizajn'),
                trailing: const Text('Light mode'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedIdea01),
                title: const Text('Drži zaslon upaljen'),
                trailing: Switch(value: _keepScreenOn, onChanged: _toggleWakelock),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedLanguageSquare),
                title: const Text('Jezik'),
                trailing: const Text('Hrvatski'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedBookOpen01),
                title: const Text('Pravila bele'),
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                onTap: () => _launchURL(rulesUrl),
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedBookOpen02),
                title: const Text('Nepisana pravila bele'),
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                onTap: () => _launchURL(unpublishedRulesUrl),
              ),
              const DeleteHistoryTile(),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedInformationSquare),
                title: const Text('O aplikaciji'),
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
