import 'dart:convert';
import 'dart:io';

class RevendeurOrderStorageService {
  static const String _fileName = 'revendeur_orders.json';
  static const String _dataDir =
      '/home/mael/Dokumente/idee/flutter_application_1/data';

  static Future<File> _getFile() async {
    final dataDir = Directory(_dataDir);
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }
    return File('$_dataDir/$_fileName');
  }

  static Future<Map<String, dynamic>> _readAll() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return {'commandes': []};
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return {'commandes': []};
    }
  }

  static Future<void> _writeAll(Map<String, dynamic> data) async {
    final file = await _getFile();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
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
