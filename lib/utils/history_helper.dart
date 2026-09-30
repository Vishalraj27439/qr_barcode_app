import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HistoryHelper {
  static Future<void> saveHistory({
    required String type,
    required String value,
  }) async {
    if (value.trim().isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    final List<String> oldHistory =
        prefs.getStringList('code_history') ?? [];

    final Map<String, dynamic> newItem = {
      'type': type,
      'value': value,
      'date': DateTime.now().toIso8601String(),
    };

    oldHistory.insert(
      0,
      jsonEncode(newItem),
    );

    // Keep only latest 100 items
    if (oldHistory.length > 100) {
      oldHistory.removeRange(
        100,
        oldHistory.length,
      );
    }

    await prefs.setStringList(
      'code_history',
      oldHistory,
    );
  }
}
