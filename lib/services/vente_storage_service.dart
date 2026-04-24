import 'storage_helper.dart';

class VenteStorageService {
  static const String _key = 'ventes.json';

  static Future<Map<String, dynamic>> _readAll() async {
    return StorageHelper.read(_key, defaultValue: {'ventes': []});
  }

  static Future<void> _writeAll(Map<String, dynamic> data) async {
    await StorageHelper.write(_key, data);
  }

  /// Enregistre un produit mis en vente par un grossiste
  static Future<void> saveVente({
    required String grossisteEmail,
    required Map<String, dynamic> vente,
  }) async {
    final data = await _readAll();
    data.putIfAbsent('ventes', () => <dynamic>[]);
    final ventes = data['ventes'] as List<dynamic>;

    vente['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    vente['grossisteEmail'] = grossisteEmail;
    vente['createdAt'] = DateTime.now().toIso8601String();
    vente['status'] = 'disponible';

    ventes.add(vente);
    data['ventes'] = ventes;
    await _writeAll(data);
  }

  /// Retourne les ventes d'un grossiste (ordre anti-chronologique)
  static Future<List<Map<String, dynamic>>> getVentesByGrossiste(
      String email) async {
    final data = await _readAll();
    final ventes = (data['ventes'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .where((v) => v['grossisteEmail'] == email)
        .toList();
    // Plus récent en premier
    ventes.sort((a, b) {
      final da = DateTime.tryParse(a['createdAt'] as String? ?? '') ??
          DateTime(2000);
      final db = DateTime.tryParse(b['createdAt'] as String? ?? '') ??
          DateTime(2000);
      return db.compareTo(da);
    });
    return ventes;
  }

  /// Retourne toutes les ventes disponibles (tous grossistes)
  static Future<List<Map<String, dynamic>>> getAllVentes(
      {bool onlyDisponible = true}) async {
    final data = await _readAll();
    final ventes = (data['ventes'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    if (onlyDisponible) {
      return ventes
          .where((v) => (v['status'] as String?) == 'disponible')
          .toList();
    }
    return ventes;
  }

  /// Supprime une vente par son id
  static Future<void> deleteVente(String id) async {
    final data = await _readAll();
    final ventes = (data['ventes'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .where((v) => v['id'] != id)
        .toList();
    data['ventes'] = ventes;
    await _writeAll(data);
  }

  /// Met une vente en statut "vendu"
  static Future<void> markAsVendu(String id) async {
    final data = await _readAll();
    final ventes = (data['ventes'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    for (final v in ventes) {
      if (v['id'] == id) {
        v['status'] = 'vendu';
        break;
      }
    }
    data['ventes'] = ventes;
    await _writeAll(data);
  }
}
