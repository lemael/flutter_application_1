import 'package:flutter/material.dart';

import 'login_page.dart';
import 'producteur/register_producer.dart';
import 'revendeur/register_vendor.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. LES IMAGES DE FOND (SÉPARÉES EN HAUT ET BAS POUR LE RESPONSIVE)
          Column(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/champ.png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover, // Remplit tout l'espace sans déformer
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Titre avec ombre pour la lisibilité
                const Text(
                  "MAMENCERISE",
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const Text(
                  "Vos denrées alimentaires bio",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                  ),
                ),

                const SizedBox(height: 60),

                // Les Boutons avec effet de clic InkWell
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSquareButton(
                      context,
                      label: "JE SUIS\nREVENDEUR",
                      icon: Icons.shopping_basket_outlined,
                      color: const Color(0xFF1E5631), // Vert foncé
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterVendorPage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    _buildSquareButton(
                      context,
                      label: "JE SUIS\nPRODUCTEUR",
                      icon: Icons.agriculture,
                      color: const Color(0xFFE67E22), // Orange
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterProducerPage(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Lien de connexion
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  ),
                  child: const Text(
                    "Déjà membre ? Se connecter",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FONCTION POUR CRÉER LES BOUTONS AVEC EFFET DE CLIC VISUEL
  Widget _buildSquareButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color:
          Colors.transparent, // Important pour voir l'ombre du Ink en dessous
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20), // L'arrondi de l'effet de clic
        child: Ink(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.3,
                ), // Syntaxe moderne sans warning
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
      ),
    );
  }
}
