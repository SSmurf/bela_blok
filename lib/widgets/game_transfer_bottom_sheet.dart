// lib/widgets/game_transfer_bottom_sheet.dart
import 'package:bela_blok/models/game_transfer.dart';
import 'package:bela_blok/services/qr_service.dart';
import 'package:bela_blok/utils/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:hugeicons/hugeicons.dart';

class GameTransferBottomSheet extends ConsumerStatefulWidget {
  const GameTransferBottomSheet({super.key});

  @override
  ConsumerState<GameTransferBottomSheet> createState() => _GameTransferBottomSheetState();
}

class _GameTransferBottomSheetState extends ConsumerState<GameTransferBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _handleScannedData(String data) {
    if (!_isScanning) return;

    setState(() {
      _isScanning = false;
    });

    try {
      final gameTransfer = GameTransfer.fromQrData(data);
      _showImportConfirmationDialog(gameTransfer);
    } catch (e) {
      _showErrorDialog('Invalid QR code data');
      setState(() {
        _isScanning = true;
      });
    }
  }

  void _showErrorDialog(String message) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(loc.translate('error')),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showImportConfirmationDialog(GameTransfer gameTransfer) {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(loc.translate('importGame')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.translate('importGameConfirmation')),
                const SizedBox(height: 16),
                Text('${loc.translate('teams')}: ${gameTransfer.teamOneName} vs ${gameTransfer.teamTwoName}'),
                Text('${loc.translate('rounds')}: ${gameTransfer.rounds.length}'),
                Text('${loc.translate('goalScore')}: ${gameTransfer.goalScore}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _isScanning = true;
                  });
                },
                child: Text(loc.translate('cancel')),
              ),
              TextButton(
                onPressed: () {
                  QrService.importGame(ref, gameTransfer);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(loc.translate('import')),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final gameTransfer = QrService.createGameTransfer(ref);
    final qrData = gameTransfer.toQrData();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 360;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: theme.colorScheme.primary,
              ),
              labelColor: theme.colorScheme.onPrimary,
              labelStyle: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w500,
                fontSize: isSmallScreen ? 18 : 20,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w500,
                fontSize: isSmallScreen ? 18 : 20,
              ),
              unselectedLabelColor: theme.colorScheme.onSurface,
              tabs: [Tab(text: loc.translate('shareGame')), Tab(text: loc.translate('scanGame'))],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Share Game Tab
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        loc.translate('scanQrToImport'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Nunito',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 280,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '${loc.translate('teams')}: ${gameTransfer.teamOneName} vs ${gameTransfer.teamTwoName}\n'
                        '${loc.translate('rounds')}: ${gameTransfer.rounds.length}',
                        style: const TextStyle(fontSize: 16, fontFamily: 'Nunito'),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Scan Game Tab
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        loc.translate('scanQrToImport'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Nunito',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).colorScheme.primary),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child:
                            _isScanning
                                ? MobileScanner(
                                  controller: _scannerController,
                                  onDetect: (capture) {
                                    final List<Barcode> barcodes = capture.barcodes;
                                    for (final barcode in barcodes) {
                                      if (barcode.rawValue != null) {
                                        _handleScannedData(barcode.rawValue!);
                                        return;
                                      }
                                    }
                                  },
                                )
                                : const Center(child: CircularProgressIndicator()),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _scannerController.toggleTorch();
                        },
                        icon: const Icon(HugeIcons.strokeRoundedFlashlight),
                        label: Text(
                          loc.translate('toggleFlash'),
                          style: const TextStyle(fontFamily: 'Nunito'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
