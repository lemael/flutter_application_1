import 'package:flutter/material.dart';

class RegisterProducerPage extends StatelessWidget {
  const RegisterProducerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inscription Producteur"),
        backgroundColor: const Color(
          0xFFE67E22,
        ), // Rappel de la couleur orange producteur
      ),
      body: SingleChildScrollView(
        // Ajouté pour éviter les erreurs de pixel si le clavier s'affiche
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.agriculture, size: 80, color: Color(0xFFE67E22)),
            const SizedBox(height: 20),

            TextField(
              decoration: const InputDecoration(
                labelText: 'Nom de l\'exploitation',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              decoration: const InputDecoration(
                labelText: 'Localisation',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // CHAMP MOT DE PASSE
            TextField(
              obscureText: true, // Masque le texte
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // CONFIRMATION MOT DE PASSE
            TextField(
              obscureText: true, // Masque le texte
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // Logique de création de compte à venir
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67E22),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Créer mon compte"),
            ),
          ],
        ),
      ),
    );
  }
}
