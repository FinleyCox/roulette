import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'purchase_manager.dart';

class PresetManager {
  static const String _key = 'saved_presets';

  static Future<List<Map<String, dynamic>>> getPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // Returns true if saved, false if limit reached
  static Future<bool> savePreset(String name, Map<String, dynamic> data) async {
    final presets = await getPresets();
    final limit = PurchaseManager().getPresetLimit();

    if (presets.length >= limit) {
      return false; // Limit reached
    }

    presets.add({
      'name': name,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(presets));
    return true;
  }

  static Future<void> deletePreset(int index) async {
    final presets = await getPresets();
    if (index >= 0 && index < presets.length) {
      presets.removeAt(index);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(presets));
    }
  }
}
