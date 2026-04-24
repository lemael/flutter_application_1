import 'package:flutter/material.dart';

import '../../services/profile_storage_service.dart';
import 'edit_profile_page.dart';
import 'notifications_settings_page.dart';
import 'privacy_policy_page.dart';

class ProfilePage extends StatefulWidget {
  final String email;
  final String defaultName;
  final String userType; // 'Producteur' | 'Revendeur' | 'Grossiste'
  final Color themeColor;
  final String? nomEntreprise;

  const ProfilePage({
    super.key,
    required this.email,
    required this.defaultName,
    required this.userType,
    required this.themeColor,
    this.nomEntreprise,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> _profile = {};
  bool _loading = true;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await ProfileStorageService.getProfile(widget.email);
    setState(() {
      _profile = p;
      _darkMode = (p['darkMode'] as bool?) ?? false;
      _loading = false;
    });
  }

  String get _displayName =>
      (_profile['nom'] as String?)?.isNotEmpty == true
          ? '${_profile['nom']} ${_profile['prenom'] ?? ''}'.trim()
          : widget.defaultName;

  String get _displayPhone =>
      (_profile['telephone'] as String?) ?? '+237 — — — — —';

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color get _background =>
      _darkMode ? const Color(0xFF1A1A2E) : Colors.grey.shade100;
  Color get _surface =>
      _darkMode ? const Color(0xFF16213E) : Colors.white;
  Color get _textPrimary => _darkMode ? Colors.white : Colors.black87;
  Color get _textSecondary =>
      _darkMode ? Colors.white54 : Colors.grey.shade600;
  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: _darkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _darkMode ? const Color(0xFF0F3460) : widget.themeColor,
          foregroundColor: Colors.white,
          title: const Text('Mon Profil',
              style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => NotificationsSettingsPage(
                        themeColor: widget.themeColor)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
        ),
        body: _loading
            ? Center(
                child: CircularProgressIndicator(color: widget.themeColor))
            : ListView(
                children: [
                  // ─── En-tête profil ─────────────────────────────────────
                  Container(
                    color: _darkMode
                        ? const Color(0xFF0F3460)
                        : widget.themeColor,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 3),
                              ),
                              child: CircleAvatar(
                                radius: 44,
                                backgroundColor:
                                    Colors.white.withAlpha(40),
                                child: Text(
                                  _initials(_displayName),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.camera_alt,
                                    size: 16,
                                    color: widget.themeColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.email,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _displayPhone,
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  // ─── Rôle badge ─────────────────────────────────────────
                  Container(
                    color: _surface,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.themeColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: widget.themeColor.withAlpha(80)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_outlined,
                                  size: 14, color: widget.themeColor),
                              const SizedBox(width: 4),
                              Text(
                                widget.userType,
                                style: TextStyle(
                                    color: widget.themeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (widget.nomEntreprise != null)
                          Text(
                            widget.nomEntreprise!,
                            style: TextStyle(
                                color: _textSecondary, fontSize: 12),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ─── Section Compte ──────────────────────────────────────
                  _sectionHeader('Compte'),
                  _profileTile(
                    icon: Icons.person_outline,
                    title: 'Modifier mon profil',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(
                            email: widget.email,
                            userType: widget.userType,
                            themeColor: widget.themeColor,
                            currentProfile: _profile,
                          ),
                        ),
                      );
                      _loadProfile();
                    },
                  ),
                  _profileTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    trailing: _badge('04'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => NotificationsSettingsPage(
                              themeColor: widget.themeColor)),
                    ),
                  ),
                  _profileTile(
                    icon: Icons.language_outlined,
                    title: 'Langue',
                    trailingText: 'Français',
                    onTap: () => _showLanguageDialog(),
                  ),

                  const SizedBox(height: 8),

                  // ─── Section Préférences ─────────────────────────────────
                  _sectionHeader('Préférences'),
                  _profileTile(
                    icon: Icons.lock_outline,
                    title: 'Sécurité',
                    onTap: () => _showSecurityDialog(),
                  ),
                  Container(
                    color: _surface,
                    child: ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.purple.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.dark_mode_outlined,
                            color: Colors.purple, size: 20),
                      ),
                      title: Text('Thème',
                          style: TextStyle(
                              color: _textPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 14)),
                      subtitle: Text(
                          _darkMode ? 'Mode sombre' : 'Mode clair',
                          style: TextStyle(
                              color: _textSecondary, fontSize: 12)),
                      trailing: Switch(
                        value: _darkMode,
                        activeColor: widget.themeColor,
                        onChanged: (v) async {
                          setState(() => _darkMode = v);
                          final updated =
                              Map<String, dynamic>.from(_profile);
                          updated['darkMode'] = v;
                          _profile = updated;
                          await ProfileStorageService.saveProfile(
                              widget.email, updated);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ─── Section Support ─────────────────────────────────────
                  _sectionHeader('Support'),
                  _profileTile(
                    icon: Icons.help_outline,
                    title: 'Aide & Support',
                    onTap: () => _showHelpDialog(),
                  ),
                  _profileTile(
                    icon: Icons.mail_outline,
                    title: 'Nous contacter',
                    onTap: () => _showContactDialog(),
                  ),
                  _profileTile(
                    icon: Icons.policy_outlined,
                    title: 'Politique de confidentialité',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyPage()),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ─── Déconnexion ─────────────────────────────────────────
                  Container(
                    color: _surface,
                    child: ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.logout,
                            color: Colors.red, size: 20),
                      ),
                      title: const Text('Déconnexion',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      onTap: () => Navigator.of(context)
                          .popUntil((r) => r.isFirst),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _textSecondary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    String? trailingText,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      color: _surface,
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: widget.themeColor.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: widget.themeColor, size: 20),
        ),
        title: Text(title,
            style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 14)),
        trailing: trailing ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailingText != null)
                  Text(trailingText,
                      style: TextStyle(
                          color: _textSecondary, fontSize: 12)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right,
                    color: _textSecondary, size: 20),
              ],
            ),
        onTap: onTap,
      ),
    );
  }

  Widget _badge(String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: widget.themeColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(count,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right, color: _textSecondary, size: 20),
      ],
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Français', 'English', 'العربية'].map((lang) {
            return RadioListTile<String>(
              value: lang,
              groupValue: 'Français',
              title: Text(lang),
              activeColor: widget.themeColor,
              onChanged: (_) => Navigator.pop(context),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sécurité'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.key_outlined),
              title: const Text('Changer le mot de passe'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.fingerprint),
              title: const Text('Authentification biométrique'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'))
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aide & Support'),
        content: const Text(
            'Pour toute assistance, consultez notre FAQ ou contactez notre équipe via la section "Nous contacter".'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'))
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nous contacter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.email_outlined, size: 16),
              const SizedBox(width: 8),
              const Text('support@facilitar.cm',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.phone_outlined, size: 16),
              const SizedBox(width: 8),
              const Text('+237 677 000 000',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ]),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'))
        ],
      ),
    );
  }
}
