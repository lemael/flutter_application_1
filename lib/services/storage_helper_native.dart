import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<Map<String, dynamic>> nativeRead(
  String key,
  Map<String, dynamic> fallback,
  Future<Map<String, dynamic>> Function(String, Map<String, dynamic>) loadAsset,
) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$key');
    if (!await file.exists()) {
      // Première fois : charge depuis les assets et sauvegarde localement
      final data = await loadAsset(key, fallback);
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
      return data;
    }
    return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  } catch (_) {
    return fallback;
  }
}

Future<void> nativeWrite(String key, Map<String, dynamic> data) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$key');
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
}
