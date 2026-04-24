import 'package:flutter/material.dart';

import '../../services/profile_storage_service.dart';

class EditProfilePage extends StatefulWidget {
  final String email;
  final String userType;
  final Color themeColor;
  final Map<String, dynamic> currentProfile;

  const EditProfilePage({
    super.key,
    required this.email,
    required this.userType,
    required this.themeColor,
    required this.currentProfile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  late final TextEditingController _nomCtrl;
  late final TextEditingController _prenomCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _telCtrl;
  late final TextEditingController _adresseCtrl;
  late final TextEditingController _localisationCtrl;
  late final TextEditingController _entrepriseCtrl;
  String _genre = 'Masculin';

  @override
  void initState() {
    super.initState();
    final p = widget.currentProfile;
    _nomCtrl = TextEditingController(text: p['nom'] ?? '');
    _prenomCtrl = TextEditingController(text: p['prenom'] ?? '');
    _emailCtrl = TextEditingController(text: widget.email);
    _telCtrl = TextEditingController(text: p['telephone'] ?? '');
    _adresseCtrl = TextEditingController(text: p['adresse'] ?? '');
    _localisationCtrl = TextEditingController(text: p['localisation'] ?? '');
    _entrepriseCtrl = TextEditingController(text: p['entreprise'] ?? '');
    _genre = (p['genre'] as String?) ?? 'Masculin';
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _adresseCtrl.dispose();
    _localisationCtrl.dispose();
    _entrepriseCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final updated = {
      ...widget.currentProfile,
      'nom': _nomCtrl.text.trim(),
      'prenom': _prenomCtrl.text.trim(),
      'telephone': _telCtrl.text.trim(),
      'adresse': _adresseCtrl.text.trim(),
      'localisation': _localisationCtrl.text.trim(),
      'entreprise': _entrepriseCtrl.text.trim(),
      'genre': _genre,
    };
    await ProfileStorageService.saveProfile(widget.email, updated);
    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        title: const Text('Modifier mon profil',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar placeholder
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: widget.themeColor.withAlpha(40),
                      child: Icon(Icons.person,
                          size: 48, color: widget.themeColor),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: widget.themeColor,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildField(
                controller: _nomCtrl,
                label: 'Nom',
                icon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _prenomCtrl,
                label: 'Prénom',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _emailCtrl,
                label: 'Email',
                icon: Icons.email_outlined,
                readOnly: true,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _telCtrl,
                label: 'Téléphone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                hint: '+237 6XX XXX XXX',
              ),
              const SizedBox(height: 14),

              if (widget.userType == 'Grossiste' ||
                  widget.userType == 'Revendeur') ...[
                _buildField(
                  controller: _entrepriseCtrl,
                  label: 'Nom entreprise / Commerce',
                  icon: Icons.store_outlined,
                ),
                const SizedBox(height: 14),
              ],

              _buildField(
                controller: _localisationCtrl,
                label: 'Ville / Région',
                icon: Icons.location_city_outlined,
                hint: 'Ex: Yaoundé, Centre',
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _adresseCtrl,
                label: 'Adresse',
                icon: Icons.home_outlined,
              ),
              const SizedBox(height: 14),

              // Genre dropdown
              DropdownButtonFormField<String>(
                value: _genre,
                decoration: InputDecoration(
                  labelText: 'Genre',
                  prefixIcon: Icon(Icons.wc_outlined,
                      color: widget.themeColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: widget.themeColor, width: 2),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Masculin',
                      child: Text('Masculin')),
                  DropdownMenuItem(
                      value: 'Féminin', child: Text('Féminin')),
                  DropdownMenuItem(
                      value: 'Autre', child: Text('Autre')),
                ],
                onChanged: (v) => setState(() => _genre = v!),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text('ENREGISTRER',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            Icon(icon, color: readOnly ? Colors.grey : widget.themeColor),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.themeColor, width: 2),
        ),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade100 : null,
      ),
    );
  }
}
