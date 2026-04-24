import 'storage_helper.dart';

class OrderStorageService {
  static const String _key = 'orders.json';

  static Future<Map<String, dynamic>> _readAll() async {
    return StorageHelper.read(_key, defaultValue: {'commandes': []});
  }

  static Future<void> _writeAll(Map<String, dynamic> data) async {
    await StorageHelper.write(_key, data);
  }

  /// Sauvegarde une commande passée par un grossiste
  static Future<void> saveOrder({
    required String grossisteEmail,
    required Map<String, dynamic> product,
  }) async {
    final data = await _readAll();
    final commandes = data['commandes'] as List<dynamic>;

    commandes.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'grossisteEmail': grossisteEmail,
      'commandeAt': DateTime.now().toIso8601String(),
      'status': 'en attente',
      'produit': {
        'id': product['id'],
        'type': product['type'],
        'variete': product['variete'],
        'quantite': product['quantite'],
        'prix': product['prix'],
        'nomEntreprise': product['nomEntreprise'],
        'producerEmail': product['producerEmail'],
        'lieu': product['lieu'],
        'etat': product['etat'],
        'dateRecolte': product['dateRecolte'],
      },
    });

    await _writeAll(data);
  }

  /// Récupère toutes les commandes d'un grossiste
  static Future<List<Map<String, dynamic>>> getOrdersByGrossiste(
      String grossisteEmail) async {
    final data = await _readAll();
    final commandes = data['commandes'] as List<dynamic>? ?? [];
    return commandes
        .cast<Map<String, dynamic>>()
        .where((c) => c['grossisteEmail'] == grossisteEmail)
        .toList()
        .reversed
        .toList(); // les plus récentes en premier
  }
}
