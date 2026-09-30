import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/history_helper.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController controller = MobileScannerController();

  String? scannedValue;
  String? scannedFormat;

  bool isTorchOn = false;
Future<void> onDetect(BarcodeCapture capture) async {
    if (scannedValue != null) {
      return;
    }

    if (capture.barcodes.isEmpty) {
      return;
    }

    final Barcode barcode = capture.barcodes.first;

    final String? value = barcode.rawValue;

    if (value == null || value.isEmpty) {
      return;
    }

    setState(() {
  scannedValue = value;
  scannedFormat = barcode.format.name;
});

await HistoryHelper.saveHistory(
  type: '${barcode.format.name} Scanned',
  value: value,
);

controller.stop();
  }

  void scanAgain() {
    setState(() {
      scannedValue = null;
      scannedFormat = null;
    });

    controller.start();
  }

  Future<void> shareResult() async {
    if (scannedValue == null) return;

    await SharePlus.instance.share(
      ShareParams(
        text:
            'Scanned Code\n\nType: $scannedFormat\nValue: $scannedValue',
      ),
    );
  }

  void copyResult() {
    if (scannedValue == null) return;

    // Clipboard will be added in the next improvement.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Result detected successfully'),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Barcode Scanner',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Flash',
            onPressed: () async {
              await controller.toggleTorch();

              setState(() {
                isTorchOn = !isTorchOn;
              });
            },
            icon: Icon(
              isTorchOn
                  ? Icons.flash_on_rounded
                  : Icons.flash_off_rounded,
            ),
          ),

          IconButton(
            tooltip: 'Switch Camera',
            onPressed: () {
              controller.switchCamera();
            },
            icon: const Icon(
              Icons.flip_camera_ios_rounded,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildScanner(),

          _buildScannerOverlay(),

          if (scannedValue != null)
            _buildResultBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    if (kIsWeb) {
      return MobileScanner(
        controller: controller,
        onDetect: onDetect,
      );
    }

    return MobileScanner(
      controller: controller,
      onDetect: onDetect,
    );
  }

  Widget _buildScannerOverlay() {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 280,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: 0.65,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Place QR or barcode inside the box',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBottomSheet() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          30,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF059669),
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      'Code Detected',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7FB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type: $scannedFormat',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SelectableText(
                      scannedValue!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF111827),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: shareResult,
                      icon: const Icon(
                        Icons.share_rounded,
                      ),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          50,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: scanAgain,
                      icon: const Icon(
                        Icons.qr_code_scanner_rounded,
                      ),
                      label: const Text('Scan Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(
                          double.infinity,
                          50,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
