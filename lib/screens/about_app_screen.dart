import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

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
                'O aplikaciji',
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
              const SizedBox(height: 24),
              Text(
                'Značajke',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              const _FeatureItem(
                icon: HugeIcons.strokeRoundedChampion,
                title: 'Upravljanje rezultatima',
                description:
                    'Jednostavno unosite i pratite rezultate svakog kruga igre bele, kako bi bili uvijek informirani.',
              ),
              const _FeatureItem(
                icon: HugeIcons.strokeRoundedCards02,
                title: 'Pregled povijesti',
                description:
                    'Brzi pregled svih odigranih partija uz vremenski zapis i detaljan statistički prikaz.',
              ),
              const _FeatureItem(
                icon: HugeIcons.strokeRoundedUserEdit01,
                title: 'Prilagodba timova',
                description: 'Lako imenovanje timova i prilagodba izgleda prema vašim željama.',
              ),
              const SizedBox(height: 24),
              Text(
                'Dodatne informacije',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
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
                'Autor',
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
                              'Developer',
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

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 27, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
