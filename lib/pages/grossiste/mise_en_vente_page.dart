import 'package:flutter/material.dart';

import '../../services/order_storage_service.dart';
import '../../services/vente_storage_service.dart';

class MiseEnVentePage extends StatefulWidget {
  final String grossisteEmail;
  const MiseEnVentePage({super.key, required this.grossisteEmail});

  @override
  State<MiseEnVentePage> createState() => _MiseEnVentePageState();
}

class _MiseEnVentePageState extends State<MiseEnVentePage> {
  List<Map<String, dynamic>> _ventes = [];
  // Produits achetés par le grossiste (depuis orders.json)
  List<Map<String, dynamic>> _produitsAchetes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final ventes =
        await VenteStorageService.getVentesByGrossiste(widget.grossisteEmail);
    final commandes =
        await OrderStorageService.getOrdersByGrossiste(widget.grossisteEmail);
    // Extraire les produits uniques depuis les commandes
    final seen = <String>{};
    final produits = <Map<String, dynamic>>[];
    for (final c in commandes) {
      final p = c['produit'] as Map<String, dynamic>? ?? {};
      final key = '${p['type']}_${p['variete']}';
      if (!seen.contains(key)) {
        seen.add(key);
        produits.add(Map<String, dynamic>.from(p));
      }
    }
    setState(() {
      _ventes = ventes;
      _produitsAchetes = produits;
      _loading = false;
    });
  }

  Future<void> _loadVentes() => _loadData();

  // ─── Formulaire d'ajout ─────────────────────────────────────────────────────

  void _showAddDialog() {
    if (_produitsAchetes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Aucun produit acheté. Achetez d\'abord des produits dans le Catalogue.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Map<String, dynamic>? selectedProduit;
    final quantiteController = TextEditingController();
    final quantiteUniteController = TextEditingController(text: 'kg');
    final prixController = TextEditingController();
    String etat = 'frais';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.sell_outlined, color: Color(0xFF1A3A5C)),
              SizedBox(width: 8),
              Text('Mettre en vente',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A3A5C))),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Sélection du produit acheté ──────────────────────────
                  DropdownButtonFormField<Map<String, dynamic>>(
                    decoration: _inputDecoration('Produit acheté *'),
                    isExpanded: true,
                    value: selectedProduit,
                    hint: const Text('Choisir un produit'),
                    items: _produitsAchetes.map((p) {
                      final label = [
                        p['type'] as String? ?? '',
                        if ((p['variete'] as String?)?.isNotEmpty == true)
                          p['variete'] as String,
                      ].join(' — ');
                      return DropdownMenuItem(
                        value: p,
                        child: Text(label,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    validator: (v) =>
                        v == null ? 'Sélectionnez un produit' : null,
                    onChanged: (v) =>
                        setDialogState(() => selectedProduit = v),
                  ),
                  const SizedBox(height: 12),

                  // ── Quantité + unité ─────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: quantiteController,
                          decoration: _inputDecoration('Quantité à vendre *'),
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Requis'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: quantiteUniteController,
                          decoration: _inputDecoration('Unité'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Prix de vente ────────────────────────────────────────
                  TextFormField(
                    controller: prixController,
                    decoration: _inputDecoration('Prix de vente (FCFA) *'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Requis';
                      if (double.tryParse(v.trim()) == null) return 'Invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── État du produit ──────────────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('État du produit',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: [
                          _etatChip(setDialogState, etat, 'frais',
                              '🥦 Frais', Colors.green, (v) => etat = v),
                          _etatChip(setDialogState, etat, 'maturation',
                              '🌿 Maturation', Colors.orange,
                              (v) => etat = v),
                          _etatChip(setDialogState, etat, 'sec', '🍂 Sec',
                              Colors.brown, (v) => etat = v),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler',
                  style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3A5C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Mettre en vente'),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final quantiteStr =
                    '${quantiteController.text.trim()} ${quantiteUniteController.text.trim()}'
                        .trim();
                await VenteStorageService.saveVente(
                  grossisteEmail: widget.grossisteEmail,
                  vente: {
                    'type': selectedProduit!['type'],
                    'variete': selectedProduit!['variete'] ?? '',
                    'quantite': quantiteStr,
                    'prix':
                        double.tryParse(prixController.text.trim()) ?? 0,
                    'etat': etat,
                    // Infos traçabilité depuis la commande originale
                    'producerEmail': selectedProduit!['producerEmail'],
                    'nomEntreprise': selectedProduit!['nomEntreprise'],
                    'lieu': selectedProduit!['lieu'],
                    'dateRecolte': selectedProduit!['dateRecolte'],
                  },
                );
                if (ctx.mounted) Navigator.pop(ctx);
                _loadData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _etatChip(
    StateSetter setDialogState,
    String current,
    String value,
    String label,
    Color color,
    void Function(String) onSelect,
  ) {
    final selected = current == value;
    return GestureDetector(
      onTap: () => setDialogState(() => onSelect(value)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(220) : color.withAlpha(30),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  // ─── Détail / actions sur une vente ─────────────────────────────────────────

  void _showVenteDetail(Map<String, dynamic> vente) {
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
              Row(
                children: [
                  const Icon(Icons.sell_outlined,
                      color: Color(0xFF1A3A5C), size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      vente['type'] as String? ?? '—',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _statusBadge(vente['status'] as String? ?? 'disponible'),
                ],
              ),
              const Divider(height: 24),
              _detailRow('Variété', vente['variete'] as String? ?? '—'),
              _detailRow('Quantité', vente['quantite'] as String? ?? '—'),
              _detailRow(
                  'Prix',
                  '${(vente['prix'] as num?)?.toStringAsFixed(0) ?? '—'} FCFA'),
              _detailRow('État', vente['etat'] as String? ?? '—'),
              _detailRow('Mise en vente',
                  _formatDate(vente['createdAt'] as String?)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if ((vente['status'] as String?) == 'disponible') ...[
                    OutlinedButton.icon(
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.green, size: 18),
                      label: const Text('Marquer vendu',
                          style: TextStyle(color: Colors.green)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                      ),
                      onPressed: () async {
                        await VenteStorageService.markAsVendu(
                            vente['id'] as String);
                        if (mounted) Navigator.pop(context);
                        _loadVentes();
                      },
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 18),
                      label: const Text('Supprimer',
                          style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Supprimer'),
                            content: const Text(
                                'Voulez-vous retirer ce produit de la vente ?'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Non')),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Oui',
                                      style:
                                          TextStyle(color: Colors.white))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await VenteStorageService.deleteVente(
                              vente['id'] as String);
                          if (mounted) Navigator.pop(context);
                          _loadVentes();
                        }
                      },
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.grey)),
          ),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'disponible':
        color = const Color(0xFF1A3A5C);
        break;
      case 'vendu':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withAlpha(30),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(12)),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
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

  String _formatDate(String? iso) {
    if (iso == null) return '—';
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '—';
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Mise en vente'),
        backgroundColor: const Color(0xFF1A3A5C),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Ajouter un produit en vente',
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: _showAddDialog,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A3A5C)))
          : _ventes.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ventes.length,
                  itemBuilder: (context, index) {
                    final vente = _ventes[index];
                    return _buildVenteCard(vente);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sell_outlined,
              size: 80, color: const Color(0xFF1A3A5C).withAlpha(80)),
          const SizedBox(height: 16),
          const Text(
            'Aucun produit en vente',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Appuyez sur + pour mettre un produit en vente',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3A5C),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Mettre en vente'),
            onPressed: _showAddDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildVenteCard(Map<String, dynamic> vente) {
    final status = vente['status'] as String? ?? 'disponible';
    final isVendu = status == 'vendu';
    final etatColor = _etatColor(vente['etat'] as String?);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: isVendu ? 1 : 3,
      color: isVendu ? Colors.grey.shade100 : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showVenteDetail(vente),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône état
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isVendu
                      ? Colors.grey.withAlpha(40)
                      : etatColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: isVendu ? Colors.grey : etatColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // Infos produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vente['type'] as String? ?? '—',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color:
                            isVendu ? Colors.grey : const Color(0xFF1A3A5C),
                        decoration: isVendu
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    if ((vente['variete'] as String?)?.isNotEmpty == true)
                      Text(
                        vente['variete'] as String,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.scale_outlined,
                            size: 13,
                            color: isVendu ? Colors.grey : Colors.blueGrey),
                        const SizedBox(width: 3),
                        Text(
                          vente['quantite'] as String? ?? '—',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Prix + badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(vente['prix'] as num?)?.toStringAsFixed(0) ?? '—'} FCFA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isVendu
                          ? Colors.grey
                          : const Color(0xFF1A3A5C),
                    ),
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
