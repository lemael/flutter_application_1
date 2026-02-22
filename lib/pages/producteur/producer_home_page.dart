import 'package:flutter/material.dart';

class ProducerHomePage extends StatelessWidget {
  const ProducerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tableau de bord Producteur"),
        backgroundColor: const Color(0xFFE67E22), // Orange Producteur
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context), // Retour à l'accueil
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bienvenue, Producteur !",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 colonnes
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  // BOUTON : CRÉATION DE PRODUIT
                  _buildMenuCard(
                    context,
                    title: "Créer un produit",
                    icon: Icons.add_circle_outline,
                    color: Colors.green,
                    onTap: () {
                      print("Aller vers Création de produit");
                    },
                  ),
                  // BOUTON : LISTE DES PRODUITS
                  _buildMenuCard(
                    context,
                    title: "Mes produits",
                    icon: Icons.inventory_2_outlined,
                    color: Colors.blue,
                    onTap: () {
                      print("Aller vers Liste des produits");
                    },
                  ),
                  // BOUTON : CHAT
                  _buildMenuCard(
                    context,
                    title: "Messagerie",
                    icon: Icons.chat_outlined,
                    color: Colors.orange,
                    onTap: () {
                      print("Aller vers le Chat");
                    },
                  ),
                  // BOUTON : PROFIL (Optionnel mais utile)
                  _buildMenuCard(
                    context,
                    title: "Mon Profil",
                    icon: Icons.person_outline,
                    color: Colors.purple,
                    onTap: () {
                      print("Aller vers Profil");
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

  // Widget pour créer les cartes du menu
  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      elevation: 4,
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
