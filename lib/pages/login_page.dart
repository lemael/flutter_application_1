import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Connexion Mamencerise'),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Producteur"),
              Tab(text: "Revendeur"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLoginForm(context, "Producteur"),
            _buildLoginForm(context, "Revendeur"),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, String type) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 30),
          TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, child: Text("Se connecter ($type)")),
        ],
      ),
    );
  }
}
