import 'package:flutter/material.dart';

import '../../services/product_storage_service.dart';

class CreateProductPage extends StatefulWidget {
  final String producerEmail;
  const CreateProductPage({super.key, required this.producerEmail});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Suggestions produits camerounais
  static const List<String> _produitsSuggestions = [
    // Légumes & feuilles
    'Ndolé (feuilles amères)',
    'Feuilles de manioc',
    'Feuilles de patate douce',
    'Gombo',
    'Épinards africains (Folong)',
    'Okrika (légume-feuille)',
    'Taro (macabo)',
    'Plantain',
    'Plantain mûr',
    // Tubercules & féculents
    'Manioc',
    'Igname',
    'Patate douce',
    'Macabo',
    'Colocasse',
    // Fruits
    'Avocat',
    'Mangue',
    'Papaye',
    'Ananas',
    'Safou (prune africaine)',
    'Noix de coco',
    'Goyave',
    // Céréales & légumineuses
    'Maïs',
    'Niébé (haricot blanc local)',
    'Arachides (cacahuètes)',
    'Soja',
    // Épices & condiments
    'Poivre de Penja (blanc)',
    'Poivre de Penja (noir)',
    'Graines de djansang',
    'Graines d\'egusi (courge)',
    'Graines de mbongo',
    'Njansan',
    'Ogiri (graines fermentées)',
    // Produits transformés
    'Huile de palme rouge',
    'Huile de noix de coco',
    'Farine de manioc (Gari)',
    'Farine de plantain',
    'Bâtons de manioc (Bâton de manioc)',
    'Miondo',
  ];

  // Informations produit
  final _typeController = TextEditingController();
  final _varieteController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _prixController = TextEditingController();
  final _nomEntrepriseController = TextEditingController();
  String _etatProduit = 'frais';

  // Cycle de production
  DateTime? _dateSemence;
  DateTime? _dateRecolte;

  // Origine & logistique
  final _lieuController = TextEditingController();
  final _stockageController = TextEditingController();
  final List<String> _photos = []; // chemin des photos sélectionnées

  @override
  void dispose() {
    _typeController.dispose();
    _varieteController.dispose();
    _quantiteController.dispose();
    _prixController.dispose();
    _nomEntrepriseController.dispose();
    _lieuController.dispose();
    _stockageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isSemence) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFE67E22)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isSemence) {
          _dateSemence = picked;
        } else {
          _dateRecolte = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Choisir une date';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final product = {
        'type': _typeController.text,
        'variete': _varieteController.text,
        'quantite': _quantiteController.text,
        'prix': double.tryParse(_prixController.text.replaceAll(',', '.')) ?? 0.0,
        'nomEntreprise': _nomEntrepriseController.text,
        'etat': _etatProduit,
        'dateSemence': _dateSemence?.toIso8601String(),
        'dateRecolte': _dateRecolte?.toIso8601String(),
        'lieu': _lieuController.text,
        'stockage': _stockageController.text,
        'photos': _photos,
      };

      await ProductStorageService.saveProduct(
        producerEmail: widget.producerEmail,
        product: product,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Produit mis en vente avec succès !"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mise en Vente"),
        backgroundColor: const Color(0xFFE67E22),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── SECTION 1 ──────────────────────────────────────────
              _sectionTitle("1. Informations sur le Produit"),
              const SizedBox(height: 12),

              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _produitsSuggestions;
                  }
                  return _produitsSuggestions.where(
                    (p) => p.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                  );
                },
                onSelected: (String selection) {
                  _typeController.text = selection;
                },
                fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                  // Synchronise avec notre controller
                  controller.text = _typeController.text;
                  controller.addListener(() => _typeController.text = controller.text);
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Type de produit *',
                      hintText: 'Ex: Ndolé, Plantain, Safou...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.eco_outlined),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ obligatoire' : null,
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return InkWell(
                              onTap: () => onSelected(option),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Text(option),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _varieteController,
                decoration: const InputDecoration(
                  labelText: 'Variété',
                  hintText: 'Préciser si nécessaire',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _quantiteController,
                decoration: const InputDecoration(
                  labelText: 'Quantité / Nombre *',
                  hintText: 'Ex: 50 cagettes, 100 kg, 200 régimes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale_outlined),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _prixController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Prix *',
                  hintText: 'Ex: 5000 FCFA',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'FCFA',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _nomEntrepriseController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'entreprise *',
                  hintText: 'Nom de votre exploitation ou société',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.domain),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 14),

              const Text(
                'État du produit *',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              ...[
                ('frais', 'Frais (récolté le jour même)'),
                ('maturation', 'En cours de maturation'),
                ('sec', 'Sec / Transformé'),
              ].map(
                (e) => RadioListTile<String>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.$2),
                  value: e.$1,
                  groupValue: _etatProduit,
                  activeColor: const Color(0xFFE67E22),
                  onChanged: (v) => setState(() => _etatProduit = v!),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),

              // ── SECTION 2 ──────────────────────────────────────────
              _sectionTitle("2. Cycle de Production"),
              const SizedBox(height: 12),

              _datePicker(
                label: 'Date de semence',
                hint:
                    'Utile pour estimer la qualité organique et le cycle de croissance.',
                value: _dateSemence,
                onTap: () => _pickDate(context, true),
              ),
              const SizedBox(height: 14),

              _datePicker(
                label: 'Date de récolte *',
                hint:
                    'Indispensable pour calculer la durée de vie chez le grossiste.',
                value: _dateRecolte,
                onTap: () => _pickDate(context, false),
                required: true,
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),

              // ── SECTION 3 ──────────────────────────────────────────
              _sectionTitle("3. Origine et Logistique"),
              const SizedBox(height: 12),

              TextFormField(
                controller: _lieuController,
                decoration: const InputDecoration(
                  labelText: 'Lieu de production *',
                  hintText: 'Nom de la plantation ou localisation',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _stockageController,
                decoration: const InputDecoration(
                  labelText: 'Conditions de stockage actuelles',
                  hintText: 'Ex: Température ambiante, sous abri, chambre froide',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warehouse_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 14),

              // Photos
              const Text(
                'Photos du lot',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              const Text(
                'Rien ne rassure plus un grossiste qu\'une photo réelle de l\'état du stock.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: intégrer image_picker
                  setState(() => _photos.add('photo_${_photos.length + 1}'));
                },
                icon: const Icon(Icons.camera_alt_outlined,
                    color: Color(0xFFE67E22)),
                label: const Text(
                  'Ajouter une photo',
                  style: TextStyle(color: Color(0xFFE67E22)),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE67E22)),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              if (_photos.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _photos
                      .map(
                        (p) => Chip(
                          label: Text(p),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () =>
                              setState(() => _photos.remove(p)),
                        ),
                      )
                      .toList(),
                ),
              ],

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE67E22),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "METTRE EN VENTE",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE67E22),
      ),
    );
  }

  Widget _datePicker({
    required String label,
    required String hint,
    required DateTime? value,
    required VoidCallback onTap,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (required ? ' *' : ''),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(hint, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: Color(0xFFE67E22), size: 20),
                const SizedBox(width: 10),
                Text(
                  _formatDate(value),
                  style: TextStyle(
                    color: value == null ? Colors.grey : Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
