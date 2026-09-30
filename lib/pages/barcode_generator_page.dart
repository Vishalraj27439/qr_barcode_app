import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/history_helper.dart';

class BarcodeGeneratorPage extends StatefulWidget {
  const BarcodeGeneratorPage({super.key});

  @override
  State<BarcodeGeneratorPage> createState() => _BarcodeGeneratorPageState();
}

class _BarcodeGeneratorPageState extends State<BarcodeGeneratorPage> {
  final TextEditingController _controller = TextEditingController();

  String barcodeData = '';

  String selectedType = 'Code 128';

  final List<String> barcodeTypes = [
    'Code 128',
    'Code 39',
    'EAN-13',
    'EAN-8',
    'UPC-A',
  ];

  Barcode get selectedBarcode {
    switch (selectedType) {
      case 'Code 39':
        return Barcode.code39();

      case 'EAN-13':
        return Barcode.ean13();

      case 'EAN-8':
        return Barcode.ean8();

      case 'UPC-A':
        return Barcode.upcA();

      case 'Code 128':
      default:
        return Barcode.code128();
    }
  }

  Future<void> generateBarcode() async {
    final value = _controller.text.trim();

    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter barcode value')),
      );
      return;
    }

    if (selectedType == 'EAN-13' && value.length != 12 && value.length != 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('EAN-13 requires 12 or 13 digits')),
      );
      return;
    }

    if (selectedType == 'EAN-8' && value.length != 7 && value.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('EAN-8 requires 7 or 8 digits')),
      );
      return;
    }

    if (selectedType == 'UPC-A' && value.length != 11 && value.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('UPC-A requires 11 or 12 digits')),
      );
      return;
    }
    setState(() {
      barcodeData = value;
    });
    await HistoryHelper.saveHistory(
      type: '$selectedType Generated',
      value: value,
    );
  }

  void clearBarcode() {
    _controller.clear();

    setState(() {
      barcodeData = '';
    });
  }

  Future<void> shareBarcode() async {
    if (barcodeData.isEmpty) return;

    await SharePlus.instance.share(
      ShareParams(text: 'Barcode Type: $selectedType\nBarcode: $barcodeData'),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Barcode Generator',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 700;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 32 : 18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 950),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildInputSection()),
                            const SizedBox(width: 24),
                            Expanded(child: _buildBarcodeSection()),
                          ],
                        )
                      : Column(
                          children: [
                            _buildInputSection(),
                            const SizedBox(height: 24),
                            _buildBarcodeSection(),
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

  Widget _buildInputSection() {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Barcode Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Select a barcode type and enter the value.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),

          const SizedBox(height: 20),

          const Text(
            'Barcode Type',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: selectedType,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            items: barcodeTypes.map((type) {
              return DropdownMenuItem<String>(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                selectedType = value;
                barcodeData = '';
              });
            },
          ),

          const SizedBox(height: 18),

          const Text(
            'Barcode Value',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Example: 123456789012',
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF7C3AED),
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: generateBarcode,
                  icon: const Icon(Icons.barcode_reader),
                  label: const Text('Generate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              OutlinedButton(
                onPressed: clearBarcode,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(52, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeSection() {
    return _CardContainer(
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Your Barcode',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 300),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: barcodeData.isEmpty
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.barcode_reader,
                        size: 90,
                        color: Color(0xFFD1D5DB),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Your barcode will appear here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BarcodeWidget(
                        barcode: selectedBarcode,
                        data: barcodeData,
                        width: 320,
                        height: 140,
                        drawText: true,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        selectedType,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
          ),

          if (barcodeData.isNotEmpty) ...[
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: shareBarcode,
                icon: const Icon(Icons.share_rounded),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;

  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
