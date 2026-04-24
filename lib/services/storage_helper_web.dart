import 'dart:convert';

Future<Map<String, dynamic>> nativeRead(
  String key,
  Map<String, dynamic> fallback,
  Future<Map<String, dynamic>> Function(String, Map<String, dynamic>) loadAsset,
) async {
  // Sur web, cette implémentation n'est jamais appelée (géré par StorageHelper directement)
  return fallback;
}

Future<void> nativeWrite(String key, Map<String, dynamic> data) async {
  // Sur web, cette implémentation n'est jamais appelée
  final _ = jsonEncode(data); // évite unused import warning
}
