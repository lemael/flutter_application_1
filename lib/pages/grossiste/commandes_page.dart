import 'package:flutter/material.dart';

import '../../services/order_storage_service.dart';

class CommandesPage extends StatefulWidget {
  final String grossisteEmail;
  const CommandesPage({super.key, required this.grossisteEmail});

  @override
  State<CommandesPage> createState() => _CommandesPageState();
}

class _CommandesPageState extends State<CommandesPage> {
  List<Map<String, dynamic>> _commandes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCommandes();
  }

  Future<void> _loadCommandes() async {
    setState(() => _loading = true);
    final orders =
        await OrderStorageService.getOrdersByGrossiste(widget.grossisteEmail);
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

  String _formatDateShort(String? iso) {
    if (iso == null) return '—';
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
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

  void _showOrderDetail(Map<String, dynamic> commande) {
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
              // En-tête
              Row(
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      color: Color(0xFF1A3A5C), size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      produit['type'] ?? '—',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A3A5C)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 6),

              // Statut
              Row(
                children: [
                  const Text('Statut : ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor(commande['status'] as String?),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      commande['status'] ?? '—',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _detailRow(Icons.calendar_today_outlined, 'Commandé le',
                  _formatDate(commande['commandeAt'] as String?)),
              _detailRow(Icons.scale_outlined, 'Quantité',
                  produit['quantite'] ?? '—'),
              if (produit['prix'] != null)
                _detailRow(Icons.attach_money, 'Prix',
                    '${produit['prix']} FCFA'),
              if (produit['variete'] != null &&
                  (produit['variete'] as String).isNotEmpty)
                _detailRow(Icons.label_outline, 'Variété',
                    produit['variete'] as String),
              _detailRow(
                  Icons.eco_outlined, 'État', _etatLabel(produit['etat'])),
              _detailRow(Icons.location_on_outlined, 'Lieu d\'origine',
                  produit['lieu'] ?? '—'),
              _detailRow(
                  Icons.domain,
                  'Entreprise',
                  (produit['nomEntreprise'] as String?)?.isNotEmpty == true
                      ? produit['nomEntreprise'] as String
                      : produit['producerEmail'] ?? '—'),
              if (produit['dateRecolte'] != null)
                _detailRow(Icons.agriculture_outlined, 'Date de récolte',
                    _formatDateShort(produit['dateRecolte'] as String?)),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A5C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Fermer'),
                ),
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

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1A3A5C)),
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
      appBar: AppBar(
        title: const Text('Mes Commandes'),
        backgroundColor: const Color(0xFF1A3A5C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCommandes,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _commandes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune commande pour le moment.',
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Achetez des produits depuis le Catalogue.',
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _commandes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final c = _commandes[index];
                    final produit =
                        c['produit'] as Map<String, dynamic>? ?? {};
                    final status = c['status'] as String? ?? 'en attente';

                    return GestureDetector(
                      onTap: () => _showOrderDetail(c),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // Icône statut
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _statusColor(status)
                                      .withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.receipt_long_outlined,
                                  color: _statusColor(status),
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Infos
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      produit['type'] ?? '—',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      produit['quantite'] ?? '—',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (produit['prix'] != null) ...[
                                          Text(
                                            '${produit['prix']} FCFA',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1A3A5C),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                        ],
                                        Text(
                                          _formatDate(
                                              c['commandeAt'] as String?),
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Badge statut
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Icon(Icons.chevron_right,
                                      color: Colors.grey, size: 18),
                                ],
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
}
