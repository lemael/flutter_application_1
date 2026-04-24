import 'package:flutter/material.dart';

import '../messagerie/messagerie_page.dart';
import '../profil/profile_page.dart';
import 'catalogue_page.dart';
import 'commandes_page.dart';
import 'mise_en_vente_page.dart';

class WholesalerHomePage extends StatelessWidget {
  const WholesalerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Espace Grossiste"),
        backgroundColor: const Color(0xFF1A3A5C), // Bleu Grossiste
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bonjour, Grossiste !",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Gérez vos stocks et vos commandes en gros.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildMenuCard(
                    context,
                    title: "Catalogue",
                    icon: Icons.inventory_2_outlined,
                    color: const Color(0xFF1A3A5C),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CataloguePage(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    title: "Commandes",
                    icon: Icons.receipt_long_outlined,
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CommandesPage(
                          grossisteEmail: 'test@grossiste.com',
                        ),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    title: "Mise en vente",
                    icon: Icons.sell_outlined,
                    color: const Color(0xFF2E7D32),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MiseEnVentePage(
                          grossisteEmail: 'test@grossiste.com',
                        ),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    title: "Messagerie",
                    icon: Icons.chat_bubble_outline,
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MessageriePage(
                          myEmail: 'test@grossiste.com',
                          themeColor: const Color(0xFF1A3A5C),
                          contactNames: const {
                            // Producteurs
                            'bertrand.nguema@facilitar.cm': 'Bertrand Nguema',
                            'solange.mbarga@facilitar.cm': 'Solange Mbarga',
                            'herve.fomekong@facilitar.cm': 'Hervé Fomekong',
                            'marie.abena@facilitar.cm': 'Marie Abena',
                            'test@prod.com': 'Producteur Test',
                            // Revendeurs
                            'jeannette.ngobilong@facilitar.cm':
                                'Jeannette Ngo Bilong',
                            'ibrahim.bello@facilitar.cm': 'Ibrahim Bello',
                            'sylvie.owona@facilitar.cm': 'Sylvie Owona',
                            'roger.kamdem@facilitar.cm': 'Roger Kamdem',
                            'florence.ateba@facilitar.cm': 'Florence Ateba',
                            'oumarou.samba@facilitar.cm': 'Oumarou Samba',
                            'nadege.eyenga@facilitar.cm': 'Nadège Eyenga',
                            'emmanuel.fouda@facilitar.cm': 'Emmanuel Fouda',
                            'test@vendor.com': 'Revendeur Test',
                          },
                        ),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    title: "Mon Profil",
                    icon: Icons.person_outline,
                    color: Colors.teal,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfilePage(
                          email: 'test@grossiste.com',
                          defaultName: 'Grossiste Test',
                          userType: 'Grossiste',
                          themeColor: Color(0xFF1A3A5C),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      elevation: 3,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
