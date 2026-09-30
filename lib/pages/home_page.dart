import 'package:flutter/material.dart';
import 'package:qr_app/pages/barcode_generator_page.dart';
import 'package:qr_app/pages/barcode_scanner_page.dart';
import 'package:qr_app/pages/history_page.dart';
import 'package:qr_app/pages/qr_generator_page.dart';
import 'package:qr_app/pages/qr_scanner_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'QR Barcode Tools',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF171717),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
            icon: const Icon(Icons.history_rounded, color: Color(0xFF171717)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            int crossAxisCount = 2;

            if (width >= 900) {
              crossAxisCount = 4;
            } else if (width >= 600) {
              crossAxisCount = 2;
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: width >= 600 ? 32 : 16,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'QR & Barcode Tools',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Generate, scan and manage QR codes and barcodes easily.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF6B7280),
                        ),
                      ),

                      const SizedBox(height: 28),

                      GridView.count(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: width >= 900
                            ? 1.35
                            : width >= 600
                            ? 1.10
                            : 0.85,
                        children: [
                          _ToolCard(
                            icon: Icons.qr_code_2_rounded,
                            title: 'QR Code Generator',
                            subtitle: 'Create QR codes instantly',
                            iconColor: const Color(0xFF2563EB),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const QrGeneratorPage(),
                                ),
                              );
                            },
                          ),

                          _ToolCard(
                            icon: Icons.barcode_reader,
                            title: 'Barcode Generator',
                            subtitle: 'Generate professional barcodes',
                            iconColor: const Color(0xFF7C3AED),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BarcodeGeneratorPage(),
                                ),
                              );
                            },
                          ),

                          _ToolCard(
                            icon: Icons.image_search_rounded,
                            title: 'Scan QR from Image',
                            subtitle: 'Read QR codes from images',
                            iconColor: const Color(0xFF059669),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const QrScannerPage(),
                                ),
                              );
                            },
                          ),

                          _ToolCard(
                            icon: Icons.qr_code_scanner_rounded,
                            title: 'Barcode Scanner',
                            subtitle: 'Scan using your camera',
                            iconColor: const Color(0xFFEA580C),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BarcodeScannerPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.security_rounded,
                              color: Color(0xFF2563EB),
                              size: 28,
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fast & Private',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Your codes can be generated and scanned directly on your device.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),

              const Spacer(),

              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
