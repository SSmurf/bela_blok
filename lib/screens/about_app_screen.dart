import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
          onPressed: () => Navigator.pop(context),
        ),
        surfaceTintColor: Theme.of(context).colorScheme.surfaceDim,
        title: const Text(
          'O aplikaciji',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Općenito',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              Text(
                'Bela Blok je aplikacija namijenjena ljubiteljima igre bele. Aplikacija omogućuje jednostavno vođenje rezultata, pregled povijesti partija te prilagodbu izgleda prema vašem ukusu. Sve je osmišljeno s lakoćom korištenja, a dizajn koristi moderne principe kako bi vam pružio ugodno iskustvo.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              Text(
                'Aplikacija koristi lokalnu pohranu kako bi zadržala vaše postavke i podatke o igri. Svi podaci ostaju privatni i pohranjuju se unutar uređaja.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 24),
              Text(
                'Drugi bela blokovi',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              Text(
                'Isprobajte i ostale aplikacije za praćenje rezultata u beli. One su bila inspiracija ovoj aplikacijii.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 16),
              ListTile(
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                title: const Text('Bela Blok Pro - Fran Grgić', style: TextStyle(fontFamily: 'Nunito')),
                onTap:
                    () =>
                        _launchUrl('https://apps.apple.com/hr/app/bela-blok-pro-belote-tracker/id1508462578'),
              ),
              ListTile(
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                title: const Text('Bela blok - Jakopec', style: TextStyle(fontFamily: 'Nunito')),
                onTap: () => _launchUrl('https://apps.apple.com/hr/app/bela-blok/id463442397'),
              ),
              ListTile(
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                title: const Text('Bela Blok - Domagoj Bunoza', style: TextStyle(fontFamily: 'Nunito')),
                onTap: () => _launchUrl('https://apps.apple.com/hr/app/bela-blok/id6475651480'),
              ),
              const SizedBox(height: 24),
              Text(
                'Developer',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(HugeIcons.strokeRoundedUser, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Anton Pomper',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
                            ),
                            Text(
                              'Student FER-a',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
