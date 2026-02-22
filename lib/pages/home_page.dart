import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. LES IMAGES DE FOND (SÉPARÉES EN DEUX)
          Row(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/champ.png',
                  width: double.infinity, // Prend toute la largeur
                  height: double.infinity, // Prend toute la hauteur du Expanded
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Image.asset(
                  'assets/marche.png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),

          // 2. LE CONTENU (TITRE ET BOUTONS)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Le Titre et Sous-titre
              const Text(
                "MAMENCERISE",
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                "Vos denrées alimentaires bio",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),

              const SizedBox(height: 60), // Espace avant les boutons
              // Les Boutons côte à côte
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // BOUTON REVENDEUR
                  _buildSquareButton(
                    context,
                    label: "JE SUIS\nREVENDEUR",
                    icon: Icons.shopping_basket_outlined,
                    color: const Color(0xFF1E5631), // Vert foncé
                  ),

                  const SizedBox(width: 20), // Espace entre les deux boutons
                  // BOUTON PRODUCTEUR
                  _buildSquareButton(
                    context,
                    label: "JE SUIS\nPRODUCTEUR",
                    icon: Icons.agriculture,
                    color: const Color(0xFFE67E22), // Orange
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Lien de connexion en bas
              TextButton(
                onPressed: () {}, // On ajoutera la navigation plus tard
                child: const Text(
                  "Déjà membre ? Se connecter",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // FONCTION POUR CRÉER LES BOUTONS CARRÉS (Évite de répéter le code)
  Widget _buildSquareButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        print("Clic sur $label");
        // Navigator.push(...) ira ici
      },
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20), // L'arrondi des coins
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
