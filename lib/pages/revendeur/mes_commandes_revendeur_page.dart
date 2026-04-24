import 'package:flutter/material.dart';

import '../../services/revendeur_order_storage_service.dart';

class MesCommandesRevendeurPage extends StatefulWidget {
  final String revendeurEmail;
  const MesCommandesRevendeurPage({super.key, required this.revendeurEmail});

  @override
  State<MesCommandesRevendeurPage> createState() =>
      _MesCommandesRevendeurPageState();
}

class _MesCommandesRevendeurPageState
    extends State<MesCommandesRevendeurPage> {
  List<Map<String, dynamic>> _commandes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCommandes();
  }

  Future<void> _loadCommandes() async {
    setState(() => _loading = true);
    final orders = await RevendeurOrderStorageService.getOrdersByRevendeur(
        widget.revendeurEmail);
    setState(() {
      _commandes = orders;
      _loading = false;
    });
  }

  String _formatDate(String? iso) {
    if (iso == null) return '—';
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '—';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'en attente':
        return Colors.orange;
      case 'confirmée':
        return const Color(0xFF00C853);
      case 'annulée':
        return const Color(0xFFD50000);
      default:
        return Colors.grey;
    }
  }

  Color _etatColor(String? etat) {
    switch (etat) {
      case 'frais':
        return const Color(0xFF00C853);
      case 'maturation':
        return const Color(0xFFFF6D00);
      case 'sec':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  void _showDetail(Map<String, dynamic> commande) {
    final produit = commande['produit'] as Map<String, dynamic>? ?? {};
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined,
                      color: Color(0xFF1E5631), size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      produit['type'] as String? ?? '—',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E5631)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 4),
              _detailRow('Variété', produit['variete'] as String? ?? '—'),
              _detailRow('Quantité', produit['quantite'] as String? ?? '—'),
              _detailRow(
                  'Prix',
                  '${(produit['prix'] as num?)?.toStringAsFixed(0) ?? '—'} FCFA'),
              _detailRow('État',
                  _etatLabel(produit['etat'] as String?)),
              _detailRow('Grossiste',
                  produit['grossisteEmail'] as String? ?? '—'),
              _detailRow(
                  'Producteur',
                  (produit['nomEntreprise'] as String?)?.isNotEmpty == true
                      ? produit['nomEntreprise'] as String
                      : produit['producerEmail'] as String? ?? '—'),
              if ((produit['lieu'] as String?)?.isNotEmpty == true)
                _detailRow('Lieu', produit['lieu'] as String),
              const SizedBox(height: 8),
              _detailRow('Commandé le', _formatDate(commande['commandeAt'] as String?)),
              const SizedBox(height: 12),
              Center(child: _statusBadge(commande['status'] as String? ?? 'en attente', large: true)),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey)),
          ),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13))),
        ],
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

  Widget _statusBadge(String status, {bool large = false}) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: large ? 14 : 8, vertical: large ? 5 : 3),
      decoration: BoxDecoration(
          color: color.withAlpha(30),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(12)),
      child: Text(status,
          style: TextStyle(
              color: color,
              fontSize: large ? 13 : 11,
              fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F2),
      appBar: AppBar(
        title: const Text('Mes Commandes'),
        backgroundColor: const Color(0xFF1E5631),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCommandes,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFF1E5631)))
          : _commandes.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _commandes.length,
                  itemBuilder: (context, index) =>
                      _buildCommandeCard(_commandes[index]),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 80,
              color: const Color(0xFF1E5631).withAlpha(80)),
          const SizedBox(height: 16),
          const Text(
            'Aucune commande pour le moment',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vos commandes passées dans\n"Nouveaux Produits" apparaîtront ici.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCommandeCard(Map<String, dynamic> commande) {
    final produit = commande['produit'] as Map<String, dynamic>? ?? {};
    final status = commande['status'] as String? ?? 'en attente';
    final etatColor = _etatColor(produit['etat'] as String?);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showDetail(commande),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Icône état
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: etatColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.shopping_bag_outlined,
                    color: etatColor, size: 24),
              ),
              const SizedBox(width: 12),

              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produit['type'] as String? ?? '—',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1E5631)),
                    ),
                    if ((produit['variete'] as String?)?.isNotEmpty == true)
                      Text(produit['variete'] as String,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.store_outlined,
                            size: 12, color: Colors.blueGrey),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            produit['grossisteEmail'] as String? ?? '—',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.blueGrey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatDate(commande['commandeAt'] as String?),
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Prix + statut
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(produit['prix'] as num?)?.toStringAsFixed(0) ?? '—'} F',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E5631)),
                  ),
                  const SizedBox(height: 6),
                  _statusBadge(status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
