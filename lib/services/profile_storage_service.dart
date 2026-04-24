import 'dart:convert';
import 'dart:io';

class ProfileStorageService {
  static const String _fileName = 'profiles.json';
  static const String _dataDir =
      '/home/mael/Dokumente/idee/flutter_application_1/data';

  static Future<File> _getFile() async {
    final dir = Directory(_dataDir);
    if (!await dir.exists()) await dir.create(recursive: true);
    return File('$_dataDir/$_fileName');
  }

  static Future<Map<String, dynamic>> _readAll() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return {};
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<void> _writeAll(Map<String, dynamic> data) async {
    final file = await _getFile();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  }

  static Future<Map<String, dynamic>> getProfile(String email) async {
    final all = await _readAll();
    return (all[email] as Map<String, dynamic>?) ?? {};
  }

  static Future<void> saveProfile(
      String email, Map<String, dynamic> profile) async {
    final all = await _readAll();
    all[email] = profile;
    await _writeAll(all);
  }
}
