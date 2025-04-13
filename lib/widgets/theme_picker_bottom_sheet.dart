import 'package:bela_blok/models/theme_settings.dart';
import 'package:bela_blok/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_localizations.dart';

class ThemePickerBottomSheet extends ConsumerStatefulWidget {
  final ThemeSettings currentSettings;
  final Function(ThemeSettings) onThemeSettingsChanged; // Callback to update provider state

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

  // Immediately update provider state with current settings.
  void _updateProviderImmediately() {
    final newSettings = ThemeSettings(
      themeType: _themeType,
      colorPalette: _colorPalette,
      useSystemTheme: _useSystemTheme,
    );
    widget.onThemeSettingsChanged(newSettings);
  }

  // Finalize and apply changes before closing.
  void _applyChanges() {
    final newSettings = ThemeSettings(
      themeType: _themeType,
      colorPalette: _colorPalette,
      useSystemTheme: _useSystemTheme,
    );
    widget.onThemeSettingsChanged(newSettings);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= 360 || screenSize.height <= 600;
    final gridItemHeight = isSmallScreen ? 70.0 : 80.0;
    final gridSpacing = 12.0;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: isSmallScreen ? 12 : 20,
        right: isSmallScreen ? 12 : 20,
        top: isSmallScreen ? 12 : 20,
        bottom: isSmallScreen ? 12 : 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.translate('themeSettings'),
                style: isSmallScreen ? theme.textTheme.titleMedium : theme.textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _applyChanges,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 16),
          SwitchListTile(
            title: Text(
              loc.translate('systemTheme'),
              style: isSmallScreen ? theme.textTheme.bodyMedium : theme.textTheme.bodyLarge,
            ),
            dense: isSmallScreen,
            value: _useSystemTheme,
            onChanged: (value) {
              setState(() {
                _useSystemTheme = value;
              });
              _updateProviderImmediately();
            },
          ),
          ListTile(
            dense: isSmallScreen,
            title: Text(
              loc.translate('darkMode'),
              style: TextStyle(
                color: _useSystemTheme ? Theme.of(context).disabledColor : null,
                fontSize: isSmallScreen ? 14 : null,
              ),
            ),
            trailing: Switch(
              value: _themeType == ThemeType.dark,
              onChanged:
                  _useSystemTheme
                      ? null
                      : (value) {
                        setState(() {
                          _themeType = value ? ThemeType.dark : ThemeType.light;
                        });
                        _updateProviderImmediately();
                      },
            ),
          ),
          const Divider(),
          SizedBox(height: isSmallScreen ? 4 : 8),
          // Color palette selection.
          Text(
            loc.translate('colorPalette'),
            style: isSmallScreen ? theme.textTheme.titleSmall : theme.textTheme.titleMedium,
          ),
          SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: gridSpacing,
            crossAxisSpacing: gridSpacing,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildColorPaletteItem(
                palette: ColorPalette.green,
                title: loc.translate('colorGreen'),
                primaryColor: lightPaletteColors[ColorPalette.green]!['primary']!,
                secondaryColor: lightPaletteColors[ColorPalette.green]!['secondary']!,
                accentColor: lightPaletteColors[ColorPalette.green]!['tertiary']!,
                height: gridItemHeight,
                isSmallScreen: isSmallScreen,
              ),
              _buildColorPaletteItem(
                palette: ColorPalette.blue,
                title: loc.translate('colorBlue'),
                primaryColor: lightPaletteColors[ColorPalette.blue]!['primary']!,
                secondaryColor: lightPaletteColors[ColorPalette.blue]!['secondary']!,
                accentColor: lightPaletteColors[ColorPalette.blue]!['tertiary']!,
                height: gridItemHeight,
                isSmallScreen: isSmallScreen,
              ),
              _buildColorPaletteItem(
                palette: ColorPalette.red,
                title: loc.translate('colorRed'),
                primaryColor: lightPaletteColors[ColorPalette.red]!['primary']!,
                secondaryColor: lightPaletteColors[ColorPalette.red]!['secondary']!,
                accentColor: lightPaletteColors[ColorPalette.red]!['tertiary']!,
                height: gridItemHeight,
                isSmallScreen: isSmallScreen,
              ),
              _buildColorPaletteItem(
                palette: ColorPalette.purple,
                title: loc.translate('colorPurple'),
                primaryColor: lightPaletteColors[ColorPalette.purple]!['primary']!,
                secondaryColor: lightPaletteColors[ColorPalette.purple]!['secondary']!,
                accentColor: lightPaletteColors[ColorPalette.purple]!['tertiary']!,
                height: gridItemHeight,
                isSmallScreen: isSmallScreen,
              ),
              _buildColorPaletteItem(
                palette: ColorPalette.orange,
                title: loc.translate('colorOrange'),
                primaryColor: lightPaletteColors[ColorPalette.orange]!['primary']!,
                secondaryColor: lightPaletteColors[ColorPalette.orange]!['secondary']!,
                accentColor: lightPaletteColors[ColorPalette.orange]!['tertiary']!,
                height: gridItemHeight,
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(isSmallScreen ? 40 : 50),
              padding:
                  isSmallScreen
                      ? const EdgeInsets.symmetric(vertical: 8)
                      : const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _applyChanges,
            child: Text(loc.translate('apply')),
          ),
          SizedBox(height: isSmallScreen ? 6 : 10), // Add extra space at the bottom
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
    required double height,
    required bool isSmallScreen,
  }) {
    final isSelected = _colorPalette == palette;
    return GestureDetector(
      onTap: () {
        setState(() {
          _colorPalette = palette;
        });
        _updateProviderImmediately();
      },
      child: Column(
        children: [
          Container(
            height: height,
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
          SizedBox(height: isSmallScreen ? 2 : 4),
          Text(
            title,
            style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
