import 'storage_helper.dart';

class RevendeurOrderStorageService {
  static const String _key = 'revendeur_orders.json';

  static Future<Map<String, dynamic>> _readAll() async {
    return StorageHelper.read(_key, defaultValue: {'commandes': []});
  }

  static Future<void> _writeAll(Map<String, dynamic> data) async {
    await StorageHelper.write(_key, data);
  }

  /// Sauvegarde une commande passée par un revendeur
  static Future<void> saveOrder({
    required String revendeurEmail,
    required Map<String, dynamic> vente,
  }) async {
    final data = await _readAll();
    final commandes = data['commandes'] as List<dynamic>;

    commandes.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'revendeurEmail': revendeurEmail,
      'commandeAt': DateTime.now().toIso8601String(),
      'status': 'en attente',
      'produit': {
        'id': vente['id'],
        'type': vente['type'],
        'variete': vente['variete'],
        'quantite': vente['quantite'],
        'prix': vente['prix'],
        'etat': vente['etat'],
        'grossisteEmail': vente['grossisteEmail'],
        'producerEmail': vente['producerEmail'],
        'nomEntreprise': vente['nomEntreprise'],
        'lieu': vente['lieu'],
      },
    });

    data['commandes'] = commandes;
    await _writeAll(data);
  }

  /// Récupère toutes les commandes d'un revendeur (plus récentes en premier)
  static Future<List<Map<String, dynamic>>> getOrdersByRevendeur(
      String revendeurEmail) async {
    final data = await _readAll();
    final commandes = (data['commandes'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .where((c) => c['revendeurEmail'] == revendeurEmail)
        .toList();
    commandes.sort((a, b) {
      final da = DateTime.tryParse(a['commandeAt'] as String? ?? '') ??
          DateTime(2000);
      final db = DateTime.tryParse(b['commandeAt'] as String? ?? '') ??
          DateTime(2000);
      return db.compareTo(da);
    });
    return commandes;
  }
}
