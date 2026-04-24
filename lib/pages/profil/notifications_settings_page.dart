import 'package:flutter/material.dart';

class NotificationsSettingsPage extends StatefulWidget {
  final Color themeColor;

  const NotificationsSettingsPage({super.key, required this.themeColor});

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState
    extends State<NotificationsSettingsPage> {
  // Commun
  bool _general = true;
  bool _son = true;
  bool _vibration = false;

  // Système
  bool _majApp = true;
  bool _rappelFacture = false;
  bool _promotions = true;
  bool _reductions = false;
  bool _paiement = true;

  // Autres
  bool _nouveauService = false;
  bool _conseilsPro = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _sectionHeader('Général'),
          _switchTile(
            icon: Icons.notifications_outlined,
            title: 'Général',
            subtitle: 'Toutes les notifications',
            value: _general,
            onChanged: (v) => setState(() => _general = v),
          ),
          _switchTile(
            icon: Icons.volume_up_outlined,
            title: 'Son',
            subtitle: 'Sonnerie lors des notifications',
            value: _son,
            onChanged: (v) => setState(() => _son = v),
          ),
          _switchTile(
            icon: Icons.vibration_outlined,
            title: 'Vibration',
            subtitle: 'Vibrer lors des notifications',
            value: _vibration,
            onChanged: (v) => setState(() => _vibration = v),
          ),

          _sectionHeader('Système & Services'),
          _switchTile(
            icon: Icons.system_update_outlined,
            title: 'Mises à jour app',
            subtitle: 'Être informé des nouvelles versions',
            value: _majApp,
            onChanged: (v) => setState(() => _majApp = v),
          ),
          _switchTile(
            icon: Icons.receipt_long_outlined,
            title: 'Rappel de facture',
            subtitle: 'Rappels de paiements en attente',
            value: _rappelFacture,
            onChanged: (v) => setState(() => _rappelFacture = v),
          ),
          _switchTile(
            icon: Icons.local_offer_outlined,
            title: 'Promotions',
            subtitle: 'Offres spéciales et promotions',
            value: _promotions,
            onChanged: (v) => setState(() => _promotions = v),
          ),
          _switchTile(
            icon: Icons.discount_outlined,
            title: 'Réductions',
            subtitle: 'Alertes de réductions sur les produits',
            value: _reductions,
            onChanged: (v) => setState(() => _reductions = v),
          ),
          _switchTile(
            icon: Icons.payment_outlined,
            title: 'Paiement',
            subtitle: 'Confirmations et alertes de paiement',
            value: _paiement,
            onChanged: (v) => setState(() => _paiement = v),
          ),

          _sectionHeader('Autres'),
          _switchTile(
            icon: Icons.new_releases_outlined,
            title: 'Nouveaux produits',
            subtitle: 'Alertes quand de nouveaux produits sont disponibles',
            value: _nouveauService,
            onChanged: (v) => setState(() => _nouveauService = v),
          ),
          _switchTile(
            icon: Icons.tips_and_updates_outlined,
            title: 'Conseils professionnels',
            subtitle: 'Astuces pour améliorer votre commerce',
            value: _conseilsPro,
            onChanged: (v) => setState(() => _conseilsPro = v),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: widget.themeColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SwitchListTile(
        secondary: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: widget.themeColor.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: widget.themeColor, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        value: value,
        activeColor: widget.themeColor,
        onChanged: onChanged,
      ),
    );
  }
}
