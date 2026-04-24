import 'storage_helper.dart';

class ProfileStorageService {
  static const String _key = 'profiles.json';

  static Future<Map<String, dynamic>> _readAll() async {
    return StorageHelper.read(_key, defaultValue: {});
  }

  static Future<void> _writeAll(Map<String, dynamic> data) async {
    await StorageHelper.write(_key, data);
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
