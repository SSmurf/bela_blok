import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final String rulesUrl = 'https://hr.wikipedia.org/wiki/Belot#Pravila';
  final String unpublishedRulesUrl = 'https://belaibelot.blogspot.com/p/n-e-p-i-s-n-pravila-bele.html';

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
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
                trailing: Text('1001'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedCards02),
                title: const Text('Vrijednost štiglje'),
                trailing: Text('90'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedUserEdit01),
                title: const Text('Imena timova'),
                trailing: Text('Mi Vi'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedPaintBoard),
                title: const Text('Dizajn'),
                trailing: Text('Light mode'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedIdea01),
                title: const Text('Drzi zaslon upaljen'),
                trailing: Switch(value: true, onChanged: (bool value) {}),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedLanguageSquare),
                title: const Text('Jezik'),
                trailing: Text('Hrvatski'),
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
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedDelete01),
                title: const Text('Izbrisi povijest igara'),
                trailing: Icon(HugeIcons.strokeRoundedArrowRight01),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedInformationSquare),
                title: const Text('O aplikaciji'),
                trailing: Icon(HugeIcons.strokeRoundedArrowRight01),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
