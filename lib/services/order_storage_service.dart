import 'dart:convert';
import 'dart:io';

class OrderStorageService {
  static const String _fileName = 'orders.json';
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
