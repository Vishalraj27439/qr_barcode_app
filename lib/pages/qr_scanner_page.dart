import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/history_helper.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final ImagePicker _picker = ImagePicker();

  String? scannedValue;
  bool isScanning = false;

  Future<void> pickAndScanImage() async {
    if (kIsWeb) {
      _showMessage(
        'QR scanning from image is not available on Web yet.',
      );
      return;
    }

    try {
      setState(() {
        isScanning = true;
        scannedValue = null;
      });

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) {
        setState(() {
          isScanning = false;
        });
        return;
      }

      final BarcodeCapture? result =
          await MobileScannerPlatform.instance.analyzeImage(
        image.path,
        formats: const [
          BarcodeFormat.qrCode,
        ],
      );

      if (!mounted) return;

      setState(() {
        isScanning = false;
      });

      if (result == null || result.barcodes.isEmpty) {
        _showMessage(
          'No QR code found in this image.',
        );
        return;
      }

      final String? value = result.barcodes.first.rawValue;

      if (value == null || value.isEmpty) {
        _showMessage(
          'QR code found, but no readable data was detected.',
        );
        return;
      }

      setState(() {
        scannedValue = value;
      });
      await HistoryHelper.saveHistory(
  type: 'QR Scanned',
  value: value,
);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isScanning = false;
      });

      _showMessage(
        'Unable to scan this image.',
      );

      debugPrint('QR image scan error: $e');
    }
  }

  void clearResult() {
    setState(() {
      scannedValue = null;
    });
  }

  Future<void> shareResult() async {
    if (scannedValue == null || scannedValue!.isEmpty) {
      return;
    }

    await SharePlus.instance.share(
      ShareParams(
        text: 'Scanned QR Code:\n$scannedValue',
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Scan QR from Image',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 700;

            return SingleChildScrollView(
              padding: EdgeInsets.all(
                isDesktop ? 32 : 18,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 800,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildScannerCard(),
                      if (scannedValue != null) ...[
                        const SizedBox(height: 20),
                        _buildResultCard(),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF059669).withValues(
              alpha: 0.10,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(
            Icons.image_search_rounded,
            size: 38,
            color: Color(0xFF059669),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Scan QR Code from Image',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Select an image containing a QR code and we will read its content.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildScannerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
              ),
            ),
            child: isScanning
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Scanning image...',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        size: 85,
                        color: Color(0xFFD1D5DB),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Select a QR image',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isScanning
                  ? null
                  : pickAndScanImage,
              icon: const Icon(
                Icons.photo_library_rounded,
              ),
              label: const Text(
                'Choose Image',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                minimumSize: const Size(
                  double.infinity,
                  54,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF059669),
              ),
              SizedBox(width: 8),
              Text(
                'QR Code Detected',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: SelectableText(
              scannedValue!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.5,
              ),
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
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              OutlinedButton(
                onPressed: clearResult,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(50, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
