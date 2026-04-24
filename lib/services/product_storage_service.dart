import 'dart:convert';
import 'dart:io';

class ProductStorageService {
  static const String _fileName = 'products.json';
  static const String _dataDir =
      '/home/mael/Dokumente/idee/flutter_application_1/data';

  // Retourne le fichier JSON dans le dossier "data" du projet
  static Future<File> _getFile() async {
    final dataDir = Directory(_dataDir);
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }
    return File('$_dataDir/$_fileName');
  }

  // Lit toutes les données
  static Future<Map<String, dynamic>> _readAll() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return {};
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  // Écrit toutes les données
  static Future<void> _writeAll(Map<String, dynamic> data) async {
    final file = await _getFile();
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
  }

  /// Sauvegarde un produit pour un producteur donné
  static Future<void> saveProduct({
    required String producerEmail,
    required Map<String, dynamic> product,
  }) async {
    final data = await _readAll();

    // Structure : { "producers": { "email": { "products": [...] } } }
    data.putIfAbsent('producers', () => <String, dynamic>{});
    final producers = data['producers'] as Map<String, dynamic>;

    producers.putIfAbsent(
      producerEmail,
      () => <String, dynamic>{'products': <dynamic>[]},
    );
    final producerData = producers[producerEmail] as Map<String, dynamic>;
    final products = producerData['products'] as List<dynamic>;

    // Ajoute un id unique, la date de création et le statut
    product['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    product['createdAt'] = DateTime.now().toIso8601String();
    product['status'] = 'actif';

    products.add(product);
    await _writeAll(data);
  }

  /// Récupère tous les produits d'un producteur
  static Future<List<Map<String, dynamic>>> getProductsByProducer(
      String producerEmail) async {
    final data = await _readAll();
    final producers = data['producers'] as Map<String, dynamic>? ?? {};
    final producerData =
        producers[producerEmail] as Map<String, dynamic>? ?? {};
    final products = producerData['products'] as List<dynamic>? ?? [];
    return products.cast<Map<String, dynamic>>();
  }

  /// Met à jour les champs quantite et/ou prix d'un produit
  static Future<void> updateProduct({
    required String producerEmail,
    required String productId,
    String? newQuantite,
    double? newPrix,
  }) async {
    final data = await _readAll();
    final producers = data['producers'] as Map<String, dynamic>? ?? {};
    final producerData =
        producers[producerEmail] as Map<String, dynamic>? ?? {};
    final products = producerData['products'] as List<dynamic>? ?? [];

    for (final p in products) {
      final product = p as Map<String, dynamic>;
      if (product['id'] == productId) {
        if (newQuantite != null) product['quantite'] = newQuantite;
        if (newPrix != null) {
          product['prixPrecedent'] = product['prix'];
          product['prix'] = newPrix;
        }
        break;
      }
    }
    await _writeAll(data);
  }

  /// Supprime un produit définitivement
  static Future<void> deleteProduct({
    required String producerEmail,
    required String productId,
  }) async {
    final data = await _readAll();
    final producers = data['producers'] as Map<String, dynamic>? ?? {};
    final producerData =
        producers[producerEmail] as Map<String, dynamic>? ?? {};
    final products = producerData['products'] as List<dynamic>? ?? [];
    // Marque comme supprimé (pour garder une trace) plutôt que de retirer physiquement
    for (final p in products) {
      final product = p as Map<String, dynamic>;
      if (product['id'] == productId) {
        product['status'] = 'supprimé';
        break;
      }
    }
    // Retire vraiment du JSON
    products.removeWhere((p) => (p as Map)['id'] == productId);
    await _writeAll(data);
  }

  /// Marque un produit comme épuisé (soldOut)
  static Future<void> markAsSoldOut({
    required String producerEmail,
    required String productId,
  }) async {
    final data = await _readAll();
    final producers = data['producers'] as Map<String, dynamic>? ?? {};
    final producerData =
        producers[producerEmail] as Map<String, dynamic>? ?? {};
    final products = producerData['products'] as List<dynamic>? ?? [];

    for (final p in products) {
      final product = p as Map<String, dynamic>;
      if (product['id'] == productId) {
        product['soldOut'] = true;
        product['status'] = 'sold out';
        break;
      }
    }
    await _writeAll(data);
  }

  /// Récupère tous les produits de tous les producteurs (sauf soldOut)
  static Future<List<Map<String, dynamic>>> getAllProducts(
      {bool includeSoldOut = false}) async {
    final data = await _readAll();
    final producers = data['producers'] as Map<String, dynamic>? ?? {};
    final List<Map<String, dynamic>> all = [];
    for (final entry in producers.entries) {
      final producerData = entry.value as Map<String, dynamic>? ?? {};
      final products = producerData['products'] as List<dynamic>? ?? [];
      for (final p in products) {
        final product = Map<String, dynamic>.from(p as Map);
        if (!includeSoldOut && product['soldOut'] == true) continue;
        product['producerEmail'] = entry.key;
        all.add(product);
      }
    }
    return all;
  }

  /// Retourne le chemin du fichier (utile pour debug)
  static Future<String> getFilePath() async {
    final file = await _getFile();
    return file.path;
  }
}
