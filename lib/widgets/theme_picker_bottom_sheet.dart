import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/theme_settings.dart';
import '../utils/theme.dart';

class ThemePickerBottomSheet extends ConsumerStatefulWidget {
  final ThemeSettings currentSettings;
  final Function(ThemeSettings) onThemeSettingsChanged;

  const ThemePickerBottomSheet({
    super.key,
    required this.currentSettings,
    required this.onThemeSettingsChanged,
  });

  @override
  ConsumerState<ThemePickerBottomSheet> createState() => _ThemePickerBottomSheetState();
}

class _ThemePickerBottomSheetState extends ConsumerState<ThemePickerBottomSheet> {
  late ThemeType _themeType;
  late ColorPalette _colorPalette;
  late bool _useSystemTheme;

  @override
  void initState() {
    super.initState();
    _themeType = widget.currentSettings.themeType;
    _colorPalette = widget.currentSettings.colorPalette;
    _useSystemTheme = widget.currentSettings.useSystemTheme;
  }

  void _applyChanges() {
    widget.onThemeSettingsChanged(
      ThemeSettings(themeType: _themeType, colorPalette: _colorPalette, useSystemTheme: _useSystemTheme),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Postavke teme', style: theme.textTheme.titleLarge),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const SizedBox(height: 16),

          // Use system theme toggle
          SwitchListTile(
            title: const Text('Koristi sistemsku temu'),
            subtitle: const Text('Prati postavke uređaja'),
            value: _useSystemTheme,
            onChanged: (value) {
              setState(() {
                _useSystemTheme = value;
              });
            },
          ),

          // Light/Dark mode toggle (enabled only if not using system theme)
          if (!_useSystemTheme)
            ListTile(
              title: const Text('Tamni način rada'),
              trailing: Switch(
                value: _themeType == ThemeType.dark,
                onChanged: (value) {
                  setState(() {
                    _themeType = value ? ThemeType.dark : ThemeType.light;
                  });
                },
              ),
            ),

          const Divider(),
          const SizedBox(height: 8),

          // Color palette picker
          Text('Izbor boje aplikacije', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Green palette
              _buildColorPaletteItem(
                palette: ColorPalette.green,
                title: 'Zelena',
                primaryColor: lightPaletteColors[ColorPalette.green]!['primary']!,
                secondaryColor: lightPaletteColors[ColorPalette.green]!['secondary']!,
                accentColor: lightPaletteColors[ColorPalette.green]!['tertiary']!,
              ),

              // Blue palette
              _buildColorPaletteItem(
                palette: ColorPalette.blue,
                title: 'Plava',
                primaryColor: lightPaletteColors[ColorPalette.blue]!['primary']!,
                secondaryColor: lightPaletteColors[ColorPalette.blue]!['secondary']!,
                accentColor: lightPaletteColors[ColorPalette.blue]!['tertiary']!,
              ),

              // Red palette
              _buildColorPaletteItem(
                palette: ColorPalette.red,
                title: 'Crvena',
                primaryColor: lightPaletteColors[ColorPalette.red]!['primary']!,
                secondaryColor: lightPaletteColors[ColorPalette.red]!['secondary']!,
                accentColor: lightPaletteColors[ColorPalette.red]!['tertiary']!,
              ),

              // Purple palette
              _buildColorPaletteItem(
                palette: ColorPalette.purple,
                title: 'Ljubičasta',
                primaryColor: lightPaletteColors[ColorPalette.purple]!['primary']!,
                secondaryColor: lightPaletteColors[ColorPalette.purple]!['secondary']!,
                accentColor: lightPaletteColors[ColorPalette.purple]!['tertiary']!,
              ),

              // Gold palette
              _buildColorPaletteItem(
                palette: ColorPalette.gold,
                title: 'Zlatna',
                primaryColor: lightPaletteColors[ColorPalette.gold]!['primary']!,
                secondaryColor: lightPaletteColors[ColorPalette.gold]!['secondary']!,
                accentColor: lightPaletteColors[ColorPalette.gold]!['tertiary']!,
              ),
            ],
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            onPressed: _applyChanges,
            child: const Text('Primijeni'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPaletteItem({
    required ColorPalette palette,
    required String title,
    required Color primaryColor,
    required Color secondaryColor,
    required Color accentColor,
  }) {
    final isSelected = _colorPalette == palette;

    return GestureDetector(
      onTap: () {
        setState(() {
          _colorPalette = palette;
        });
      },
      child: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Column(
                children: [
                  Expanded(flex: 2, child: Container(color: primaryColor)),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: Container(color: secondaryColor)),
                        Expanded(child: Container(color: accentColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
