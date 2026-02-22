import 'package:flutter/material.dart';

import 'producteur/producer_home_page.dart';
import 'revendeur/vendor_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Contrôleurs pour récupérer le texte saisi
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Ta fonction de connexion avec les identifiants de test
  void _handleLogin(String type) {
    if (type == "Producteur") {
      if (_emailController.text == "test@prod.com" &&
          _passwordController.text == "1234") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProducerHomePage()),
        );
      } else {
        _showError();
      }
    } else if (type == "Revendeur") {
      if (_emailController.text == "test@vendor.com" &&
          _passwordController.text == "1234") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VendorHomePage()),
        );
      } else {
        _showError();
      }
    }
  }

  // Affichage du message d'erreur
  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Email ou mot de passe incorrect"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    // Nettoyage des contrôleurs quand la page est fermée
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Connexion"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.agriculture), text: "Producteur"),
              Tab(icon: Icon(Icons.store), text: "Revendeur"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLoginForm("Producteur"),
            _buildLoginForm("Revendeur"),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(String type) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            type == "Producteur" ? Icons.agriculture : Icons.store,
            size: 80,
            color: type == "Producteur"
                ? Colors.orange
                : const Color(0xFF1E5631),
          ),
          const SizedBox(height: 20),
          Text(
            "Connexion $type",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: type == "Producteur"
                  ? "test@prod.com"
                  : "test@vendor.com",
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mot de passe',
              hintText: "1234",
              border: OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _handleLogin(type),
            style: ElevatedButton.styleFrom(
              backgroundColor: type == "Producteur"
                  ? Colors.orange
                  : const Color(0xFF1E5631),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "SE CONNECTER",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
