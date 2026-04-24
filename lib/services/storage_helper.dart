import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: avoid_web_libraries_in_flutter
import 'storage_helper_native.dart'
    if (dart.library.html) 'storage_helper_web.dart';

/// Accès unifié au stockage JSON : localStorage sur web, fichier sur native.
class StorageHelper {
  /// Lit les données du storage. Si vides, charge le fichier asset "data/<key>".
  static Future<Map<String, dynamic>> read(
    String key, {
    Map<String, dynamic>? defaultValue,
  }) async {
    final fallback = defaultValue ?? {};
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString(key);
        if (raw != null && raw.isNotEmpty) {
          return jsonDecode(raw) as Map<String, dynamic>;
        }
        // Première fois : charge depuis les assets bundlés
        return await _loadAsset(key, fallback);
      } else {
        return await nativeRead(key, fallback, _loadAsset);
      }
    } catch (_) {
      return fallback;
    }
  }

  /// Écrit les données dans le storage.
  static Future<void> write(String key, Map<String, dynamic> data) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, jsonEncode(data));
      } else {
        await nativeWrite(key, data);
      }
    } catch (_) {}
  }

  static Future<Map<String, dynamic>> _loadAsset(
    String key,
    Map<String, dynamic> fallback,
  ) async {
    try {
      final raw = await rootBundle.loadString('data/$key');
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return fallback;
    }
  }
}
