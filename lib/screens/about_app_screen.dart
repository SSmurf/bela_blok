import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_localizations.dart';

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
    final loc = AppLocalizations.of(context)!;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        title: Text(
          loc.translate('aboutApp'),
          style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('general'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              Text(
                loc.translate('aboutDesc1'),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              Text(
                loc.translate('aboutDesc2'),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 24),
              Text(
                loc.translate('otherAppsTitle'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              Text(
                loc.translate('otherAppsDesc'),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 16),
              ListTile(
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                title: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '"Bela Blok Pro" - ', style: TextStyle(fontFamily: 'Nunito')),
                      const TextSpan(
                        text: 'Fran Grgić',
                        style: TextStyle(fontFamily: 'Nunito', fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                onTap:
                    () =>
                        _launchUrl('https://apps.apple.com/hr/app/bela-blok-pro-belote-tracker/id1508462578'),
              ),
              ListTile(
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                title: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '"Bela blok" - ', style: TextStyle(fontFamily: 'Nunito')),
                      const TextSpan(
                        text: 'Tomislav Jakopec',
                        style: TextStyle(fontFamily: 'Nunito', fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                onTap: () => _launchUrl('https://apps.apple.com/hr/app/bela-blok/id463442397'),
              ),
              ListTile(
                trailing: const Icon(HugeIcons.strokeRoundedArrowRight01),
                title: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '"Bela Blok" - ', style: TextStyle(fontFamily: 'Nunito')),
                      const TextSpan(
                        text: 'Domagoj Bunoza',
                        style: TextStyle(fontFamily: 'Nunito', fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                onTap: () => _launchUrl('https://apps.apple.com/hr/app/bela-blok/id6475651480'),
              ),
              const SizedBox(height: 24),
              Text(
                loc.translate('developer'),
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
                            // Text(
                            //   loc.translate('ferStudent'),
                            //   style: Theme.of(
                            //     context,
                            //   ).textTheme.bodyMedium?.copyWith(color: onSurfaceColor, fontFamily: 'Nunito'),
                            // ),
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
