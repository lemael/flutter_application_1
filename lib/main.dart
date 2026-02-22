import 'package:flutter/material.dart';

import 'pages/home_page.dart'; // Import important pour lier les fichiers

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mamencerise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePage(), // On appelle la page définie dans l'autre fichier
    );
  }
}
