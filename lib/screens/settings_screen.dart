import 'package:bela_blok/widgets/delete_history_tile.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final String rulesUrl = 'https://hr.wikipedia.org/wiki/Belot#Pravila';
  final String unpublishedRulesUrl = 'https://belaibelot.blogspot.com/p/n-e-p-i-s-n-pravila-bele.html';
  bool _keepScreenOn = true;
  int _goalScore = 1001;

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  //todo testiraj na uredaju
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

  Future<void> _showGoalOptions(BuildContext context) async {
    final options = [501, 701, 1001];
    await showModalBottomSheet(
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
                      setState(() {
                        _goalScore = option;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
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
                trailing: const Text('90'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedUserEdit01),
                title: const Text('Imena timova'),
                trailing: const Text('Mi Vi'),
                onTap: () {},
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
