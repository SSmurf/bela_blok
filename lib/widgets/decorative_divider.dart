import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../utils/theme.dart';

class DecorativeDivider extends ConsumerWidget {
  const DecorativeDivider({super.key});

  String _getIconForPalette(ColorPalette palette) {
    switch (palette) {
      case ColorPalette.red:
        return 'assets/images/heart.png';
      case ColorPalette.blue:
        return 'assets/images/acorn.png';
      case ColorPalette.orange:
        return 'assets/images/bell.png';
      case ColorPalette.green:
        return 'assets/images/leaf.png';
      default:
        return 'assets/images/heart.png'; // fallback
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeSettingsProvider);
    final iconAsset = _getIconForPalette(themeSettings.colorPalette);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(width: 24, height: 24, child: Image.asset(iconAsset, fit: BoxFit.contain)),
          ),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
