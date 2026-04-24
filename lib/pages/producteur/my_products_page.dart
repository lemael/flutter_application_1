import 'dart:io';

import 'package:flutter/material.dart';

import '../../services/product_storage_service.dart';

class MyProductsPage extends StatefulWidget {
  final String producerEmail;
  const MyProductsPage({super.key, required this.producerEmail});

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products =
        await ProductStorageService.getProductsByProducer(widget.producerEmail);
    setState(() {
      _products = products;
      _loading = false;
    });
  }

  String _formatDate(String? iso) {
    if (iso == null) return '—';
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return '—';
    }
  }

  void _showProductDetail(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // En-tête
              Row(
                children: [
                  const Icon(Icons.eco_outlined,
                      color: Color(0xFFE67E22), size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      product['type'] ?? '—',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE67E22),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Photos
              if ((product['photos'] as List?)?.isNotEmpty == true) ...[
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: (product['photos'] as List).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final path = (product['photos'] as List)[i] as String;
                      final file = File(path);
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: file.existsSync()
                            ? Image.file(file,
                                width: 120, height: 120, fit: BoxFit.cover)
                            : Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported,
                                    color: Colors.grey),
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              _detailRow('Variété', product['variete']),
              _detailRow('Quantité', product['quantite']),
              if (product['prix'] != null)
                _detailRow('Prix', '${product['prix']} FCFA'),
              _detailRow('État', _etatLabel(product['etat'])),
              const SizedBox(height: 8),
              const Text(
                'Cycle de production',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFFE67E22)),
              ),
              _detailRow('Date de semence', _formatDate(product['dateSemence'])),
              _detailRow('Date de récolte', _formatDate(product['dateRecolte'])),
              const SizedBox(height: 8),
              const Text(
                'Origine & logistique',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFFE67E22)),
              ),
              _detailRow('Lieu', product['lieu']),
              _detailRow('Stockage', product['stockage']),
              const SizedBox(height: 8),
              _detailRow('Enregistré le', _formatDate(product['createdAt'])),
              if (product['soldOut'] == true) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('SOLD OUT',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
              const SizedBox(height: 20),

              // ── BOUTONS D'ACTION ──────────────────────────────────
              if (product['soldOut'] != true) ...[
                // Modifier
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined,
                        color: Color(0xFFE67E22)),
                    label: const Text('Modifier',
                        style: TextStyle(color: Color(0xFFE67E22))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE67E22)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditDialog(product);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Sold Out
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.block_outlined, color: Colors.orange),
                    label: const Text('Sold Out',
                        style: TextStyle(color: Colors.orange)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await ProductStorageService.markAsSoldOut(
                        producerEmail: widget.producerEmail,
                        productId: product['id'] as String,
                      );
                      await _loadProducts();
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Supprimer
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Supprimer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD50000),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Supprimer ce produit ?'),
                          content: Text(
                              'Le produit "${product['type']}" sera supprimé définitivement du catalogue.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler')),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Supprimer',
                                  style: TextStyle(color: Color(0xFFD50000))),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ProductStorageService.deleteProduct(
                          producerEmail: widget.producerEmail,
                          productId: product['id'] as String,
                        );
                        if (mounted) Navigator.pop(context);
                        await _loadProducts();
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> product) {
    final qCtrl =
        TextEditingController(text: product['quantite'] as String? ?? '');
    final pCtrl = TextEditingController(
        text: product['prix'] != null ? '${product['prix']}' : '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Modifier — ${product['type']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qCtrl,
              decoration: const InputDecoration(
                labelText: 'Quantité',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.scale_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: pCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Prix (FCFA)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                suffixText: 'FCFA',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67E22),
                foregroundColor: Colors.white),
            onPressed: () async {
              final newPrix =
                  double.tryParse(pCtrl.text.replaceAll(',', '.'));
              await ProductStorageService.updateProduct(
                producerEmail: widget.producerEmail,
                productId: product['id'] as String,
                newQuantite:
                    qCtrl.text.isNotEmpty ? qCtrl.text : null,
                newPrix: newPrix,
              );
              if (mounted) Navigator.pop(context);
              await _loadProducts();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  String _etatLabel(String? etat) {
    switch (etat) {
      case 'frais':
        return 'Frais (récolté le jour même)';
      case 'maturation':
        return 'En cours de maturation';
      case 'sec':
        return 'Sec / Transformé';
      default:
        return etat ?? '—';
    }
  }

  Widget _detailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label :',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes produits'),
        backgroundColor: const Color(0xFFE67E22),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun produit pour le moment.',
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final p = _products[index];
                    final photos = p['photos'] as List? ?? [];
                    final hasPhoto =
                        photos.isNotEmpty && File(photos[0]).existsSync();
                    final isSoldOut = p['soldOut'] == true;

                    return GestureDetector(
                      onTap: () => _showProductDetail(p),
                      child: Opacity(
                        opacity: isSoldOut ? 0.5 : 1.0,
                        child: Card(
                          elevation: 3,
                          color: isSoldOut ? Colors.grey[200] : Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              // Photo ou placeholder
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                child: hasPhoto
                                    ? Image.file(
                                        File(photos[0] as String),
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 90,
                                        height: 90,
                                        color: isSoldOut
                                            ? Colors.grey[300]
                                            : const Color(0xFFFFF3E0),
                                        child: Icon(Icons.eco_outlined,
                                            color: isSoldOut
                                                ? Colors.grey
                                                : const Color(0xFFE67E22),
                                            size: 40),
                                      ),
                              ),
                              const SizedBox(width: 14),
                              // Infos
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              p['type'] ?? '—',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isSoldOut
                                                    ? Colors.grey
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),
                                          if (isSoldOut)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Text(
                                                  'SOLD OUT',
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (p['variete'] != null &&
                                          (p['variete'] as String).isNotEmpty)
                                        Text(
                                          p['variete'] as String,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black54),
                                        ),
                                      const SizedBox(height: 4),
                                      if (p['prix'] != null)
                                        Text(
                                          '${p['prix']} FCFA',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFE67E22)),
                                        ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                              Icons.calendar_today_outlined,
                                              size: 14,
                                              color: isSoldOut
                                                  ? Colors.grey
                                                  : const Color(0xFFE67E22)),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Récolte : ${_formatDate(p['dateRecolte'])}',
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isSoldOut
                                              ? Colors.grey
                                              : _etatColor(p['etat']),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          isSoldOut
                                              ? 'Épuisé'
                                              : _etatLabel(p['etat']),
                                          style: const TextStyle(
                                              fontSize: 11, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.chevron_right,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Color _etatColor(String? etat) {
    switch (etat) {
      case 'frais':
        return Colors.green;
      case 'maturation':
        return Colors.orange;
      case 'sec':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}
