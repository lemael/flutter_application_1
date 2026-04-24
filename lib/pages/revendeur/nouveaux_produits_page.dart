import 'package:flutter/material.dart';

import '../../services/revendeur_order_storage_service.dart';
import '../../services/vente_storage_service.dart';

class NouveauxProduitsPage extends StatefulWidget {
  const NouveauxProduitsPage({super.key});

  @override
  State<NouveauxProduitsPage> createState() => _NouveauxProduitsPageState();
}

class _NouveauxProduitsPageState extends State<NouveauxProduitsPage> {
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;
  String _filter = 'tous'; // tous, frais, maturation, sec

  static const double _chartHeight = 200;
  static const double _barWidth = 40;
  static const double _barSpacing = 14;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    final all = await VenteStorageService.getAllVentes();
    setState(() {
      _products = all;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_filter == 'tous') return _products;
    return _products.where((p) => p['etat'] == _filter).toList();
  }

  double _parseQuantity(String? qStr) {
    if (qStr == null || qStr.isEmpty) return 50;
    final match = RegExp(r'\d+(\.\d+)?').firstMatch(qStr);
    if (match != null) return double.tryParse(match.group(0)!) ?? 50;
    return 50;
  }

  Color _barColor(Map<String, dynamic> product) {
    final prix = product['prix'];
    final prixPrec = product['prixPrecedent'];
    if (prix != null && prixPrec != null) {
      final p = (prix as num).toDouble();
      final pp = (prixPrec as num).toDouble();
      if (p > pp) return const Color(0xFF00C853);
      if (p < pp) return const Color(0xFFD50000);
      return Colors.grey;
    }
    switch (product['etat'] as String? ?? '') {
      case 'frais':
        return const Color(0xFF00C853);
      case 'maturation':
        return const Color(0xFFFF6D00);
      case 'sec':
        return const Color(0xFFD50000);
      default:
        return Colors.grey;
    }
  }

  IconData _trendIcon(Map<String, dynamic> product) {
    final prix = product['prix'];
    final prixPrec = product['prixPrecedent'];
    if (prix != null && prixPrec != null) {
      final p = (prix as num).toDouble();
      final pp = (prixPrec as num).toDouble();
      if (p > pp) return Icons.trending_up;
      if (p < pp) return Icons.trending_down;
    }
    return Icons.trending_flat;
  }

  void _showOrderDialog(Map<String, dynamic> product) {
    final color = _barColor(product);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Icon(_trendIcon(product), color: color, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        product['type'] ?? '—',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _dialogRow(Icons.scale_outlined, 'Quantité disponible',
                  product['quantite'] ?? '—'),
              if (product['variete'] != null &&
                  (product['variete'] as String).isNotEmpty)
                _dialogRow(Icons.label_outline, 'Variété',
                    product['variete'] as String),
              if (product['prix'] != null)
                _dialogRow(Icons.attach_money, 'Prix',
                    '${product['prix']} FCFA'),
              if (product['prixPrecedent'] != null)
                _dialogRow(Icons.history, 'Prix précédent',
                    '${product['prixPrecedent']} FCFA'),
              _dialogRow(
                  Icons.eco_outlined,
                  'État',
                  _etatLabel(product['etat'])),
              _dialogRow(
                  Icons.store_outlined,
                  'Grossiste',
                  product['grossisteEmail'] as String? ?? '—'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD50000)),
                        foregroundColor: const Color(0xFFD50000),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Annuler',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await RevendeurOrderStorageService.saveOrder(
                          revendeurEmail: 'test@vendor.com',
                          vente: product,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Commande envoyée : ${product['type']} — ${product['quantite']}'),
                              backgroundColor: const Color(0xFF1E5631),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E5631),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Commander',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _etatLabel(String? etat) {
    switch (etat) {
      case 'frais':
        return 'Frais';
      case 'maturation':
        return 'En maturation';
      case 'sec':
        return 'Sec / Transformé';
      default:
        return etat ?? '—';
    }
  }

  Widget _dialogRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1E5631)),
          const SizedBox(width: 8),
          Text('$label : ',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1F13),
      appBar: AppBar(
        title: const Text('Nouveaux Produits'),
        backgroundColor: const Color(0xFF1E5631),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                _filterChip('tous', 'Tous'),
                const SizedBox(width: 8),
                _filterChip('frais', 'Frais'),
                const SizedBox(width: 8),
                _filterChip('maturation', 'En maturation'),
                const SizedBox(width: 8),
                _filterChip('sec', 'Sec / Transformé'),
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E5631)))
          : _filteredProducts.isEmpty
              ? _emptyState()
              : _buildChart(),
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1E5631)
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF1E5631)
                : Colors.white.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_outlined, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'Aucun produit disponible pour le moment.',
            style: TextStyle(color: Colors.grey[500], fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final products = _filteredProducts;
    final quantities =
        products.map((p) => _parseQuantity(p['quantite'] as String?)).toList();
    final maxQty = quantities.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Légende
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
          child: Row(
            children: [
              _legendItem(const Color(0xFF00C853), 'Hausse / Frais'),
              const SizedBox(width: 16),
              _legendItem(const Color(0xFFD50000), 'Baisse / Sec'),
              const SizedBox(width: 16),
              _legendItem(const Color(0xFFFF6D00), 'Maturation'),
              const Spacer(),
              Text(
                '${products.length} produit${products.length > 1 ? "s" : ""}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Barres
        Expanded(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    5,
                    (_) => Divider(
                      color: Colors.white.withOpacity(0.07),
                      height: 1,
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(products.length, (i) {
                    final p = products[i];
                    final qty = quantities[i];
                    final normalizedHeight =
                        (_chartHeight * (qty / maxQty)).clamp(20.0, _chartHeight);
                    final color = _barColor(p);
                    return GestureDetector(
                      onTap: () => _showOrderDialog(p),
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: i < products.length - 1
                                ? _barSpacing
                                : 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Prix en haut
                            Text(
                              p['prix'] != null ? '${p['prix']} F' : '—',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Icon(_trendIcon(p), color: color, size: 14),
                            const SizedBox(height: 2),
                            // Barre
                            Container(
                              width: _barWidth,
                              height: normalizedHeight,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: null,
                            ),
                            const SizedBox(height: 6),
                            // Nom
                            SizedBox(
                              width: _barWidth + 10,
                              child: Text(
                                (p['type'] as String? ?? '')
                                    .split(' ')
                                    .first,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
