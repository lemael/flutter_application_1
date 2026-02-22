import 'package:flutter/material.dart';

class VendorHomePage extends StatelessWidget {
  const VendorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Espace Revendeur"),
        backgroundColor: const Color(0xFF1E5631), // Vert Revendeur
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
              "Bonjour, Revendeur !",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Trouvez les meilleurs produits bio pour vos clients.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  // BOUTON : ANNONCES DE NOUVEAUX PRODUITS
                  _buildMenuCard(
                    context,
                    title: "Nouveaux Produits",
                    icon: Icons
                        .campaign_outlined, // Icône pour les annonces/campagnes
                    color: Colors.redAccent,
                    onTap: () {
                      print("Voir les annonces de produits");
                    },
                  ),
                  // BOUTON : MESSAGERIE
                  _buildMenuCard(
                    context,
                    title: "Messagerie",
                    icon: Icons.chat_bubble_outline,
                    color: Colors.blue,
                    onTap: () {
                      print("Ouvrir les messages");
                    },
                  ),
                  // BOUTON : PROFIL
                  _buildMenuCard(
                    context,
                    title: "Mon Profil",
                    icon: Icons.person_outline,
                    color: Colors.teal,
                    onTap: () {
                      print("Voir mon profil");
                    },
                  ),
                  // BOUTON : MES COMMANDES (Optionnel pour remplir la grille)
                  _buildMenuCard(
                    context,
                    title: "Mes Commandes",
                    icon: Icons.shopping_bag_outlined,
                    color: Colors.orange,
                    onTap: () {
                      print("Voir les commandes");
                    },
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
