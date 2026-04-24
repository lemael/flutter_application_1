import 'package:flutter/material.dart';

import 'grossiste/login_wholesaler_page.dart';
import 'producteur/login_producer_page.dart';
import 'revendeur/login_vendor_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connexion"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Je suis...",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _buildProfileButton(
              context,
              label: "Producteur",
              icon: Icons.agriculture,
              color: const Color(0xFFE67E22),
              page: const LoginProducerPage(),
            ),
            const SizedBox(height: 16),
            _buildProfileButton(
              context,
              label: "Revendeur",
              icon: Icons.store,
              color: const Color(0xFF1E5631),
              page: const LoginVendorPage(),
            ),
            const SizedBox(height: 16),
            _buildProfileButton(
              context,
              label: "Grossiste",
              icon: Icons.warehouse,
              color: const Color(0xFF1A3A5C),
              page: const LoginWholesalerPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      ),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
