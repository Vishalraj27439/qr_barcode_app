import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> savedHistory =
        prefs.getStringList('code_history') ?? [];

    final List<Map<String, dynamic>> loadedHistory = [];

    for (final item in savedHistory) {
      try {
        final decoded = jsonDecode(item);

        if (decoded is Map) {
          loadedHistory.add(
            Map<String, dynamic>.from(decoded),
          );
        }
      } catch (e) {
        debugPrint('History decode error: $e');
      }
    }

    if (!mounted) return;

    setState(() {
      history = loadedHistory;
    });
  }

  Future<void> deleteItem(int index) async {
    final prefs = await SharedPreferences.getInstance();

    history.removeAt(index);

    final List<String> updatedHistory = history
        .map(
          (item) => jsonEncode(item),
        )
        .toList();

    await prefs.setStringList(
      'code_history',
      updatedHistory,
    );

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('History item deleted'),
      ),
    );
  }

  Future<void> clearAllHistory() async {
    if (history.isEmpty) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear History?'),
          content: const Text(
            'All your saved QR and barcode history will be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('code_history');

    if (!mounted) return;

    setState(() {
      history.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('History cleared'),
      ),
    );
  }

  Future<void> shareItem(Map<String, dynamic> item) async {
    final String type =
        item['type']?.toString() ?? 'Code';

    final String value =
        item['value']?.toString() ?? '';

    await SharePlus.instance.share(
      ShareParams(
        text: '$type\n\n$value',
      ),
    );
  }

  IconData getIcon(String type) {
    final String value = type.toLowerCase();

    if (value.contains('qr')) {
      return Icons.qr_code_2_rounded;
    }

    return Icons.barcode_reader;
  }

  Color getIconColor(String type) {
    final String value = type.toLowerCase();

    if (value.contains('qr')) {
      return const Color(0xFF2563EB);
    }

    return const Color(0xFF7C3AED);
  }

  String formatDate(dynamic dateValue) {
    if (dateValue == null) {
      return '';
    }

    try {
      final date = DateTime.parse(
        dateValue.toString(),
      );

      final String day =
          date.day.toString().padLeft(2, '0');

      final String month =
          date.month.toString().padLeft(2, '0');

      final String year =
          date.year.toString();

      final String hour =
          date.hour.toString().padLeft(2, '0');

      final String minute =
          date.minute.toString().padLeft(2, '0');

      return '$day/$month/$year • $hour:$minute';
    } catch (e) {
      return dateValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'History',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              onPressed: clearAllHistory,
              tooltip: 'Clear History',
              icon: const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.red,
              ),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: history.isEmpty
            ? _buildEmptyState()
            : _buildHistoryList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(
                  alpha: 0.08,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 46,
                color: Color(0xFF2563EB),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'No History Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your generated and scanned QR codes and barcodes will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop =
            constraints.maxWidth >= 800;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1000,
            ),
            child: ListView.separated(
              padding: EdgeInsets.all(
                isDesktop ? 28 : 16,
              ),
              itemCount: history.length,
              separatorBuilder: (_, __) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                final item = history[index];

                return _buildHistoryCard(
                  item,
                  index,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryCard(
    Map<String, dynamic> item,
    int index,
  ) {
    final String type =
        item['type']?.toString() ?? 'Code';

    final String value =
        item['value']?.toString() ?? '';

    final String date =
        formatDate(item['date']);

    final Color iconColor =
        getIconColor(type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              getIcon(type),
              color: iconColor,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),

                if (date.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'share') {
                shareItem(item);
              }

              if (value == 'delete') {
                deleteItem(index);
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(
                        Icons.share_rounded,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text('Share'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: Colors.red,
                      ),
                      SizedBox(width: 10),
                      Text('Delete'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}
