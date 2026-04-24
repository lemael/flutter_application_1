import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de confidentialité',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Politique de confidentialité — FACILITAR',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Dernière mise à jour : Janvier 2025',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          _section(
            number: '1',
            title: 'Types de données que nous collectons',
            content:
                'Dans le cadre de l\'utilisation de l\'application FACILITAR, nous collectons les informations suivantes :\n\n'
                '• Données d\'identification : nom, prénom, adresse email, numéro de téléphone.\n\n'
                '• Données professionnelles : type d\'activité (Producteur, Grossiste, Revendeur), localisation, nom de l\'entreprise.\n\n'
                '• Données de transaction : historique des commandes, produits achetés ou vendus, prix et quantités.\n\n'
                '• Données de communication : messages échangés entre utilisateurs via la messagerie intégrée.\n\n'
                '• Données techniques : adresse IP, type d\'appareil, version de l\'application, journaux d\'utilisation.',
          ),
          _section(
            number: '2',
            title: 'Utilisation de vos données personnelles',
            content:
                'Les données collectées sont utilisées aux fins suivantes :\n\n'
                '• Fournir et améliorer les fonctionnalités de l\'application.\n\n'
                '• Faciliter les transactions commerciales entre producteurs, grossistes et revendeurs.\n\n'
                '• Envoyer des notifications relatives à vos commandes, ventes et messages.\n\n'
                '• Assurer la sécurité des comptes et prévenir les fraudes.\n\n'
                '• Respecter les obligations légales et réglementaires applicables au Cameroun.\n\n'
                '• Améliorer l\'expérience utilisateur grâce à des analyses statistiques anonymisées.',
          ),
          _section(
            number: '3',
            title: 'Conservation et suppression de vos données',
            content:
                'Vos données personnelles sont conservées pour la durée nécessaire à l\'accomplissement des finalités définies dans cette politique :\n\n'
                '• Données de compte : conservées tant que votre compte est actif. Supprimées 30 jours après la clôture du compte.\n\n'
                '• Données de transaction : conservées 5 ans conformément aux obligations comptables et fiscales en vigueur.\n\n'
                '• Données de messagerie : conservées 2 ans après le dernier message échangé.\n\n'
                'Vous pouvez demander la suppression de vos données à tout moment en contactant notre équipe support. Nous traiterons votre demande dans un délai de 30 jours ouvrables.\n\n'
                'Pour exercer vos droits (accès, rectification, suppression, portabilité), contactez-nous à : support@facilitar.cm',
          ),
          _section(
            number: '4',
            title: 'Partage des données',
            content:
                'FACILITAR ne vend pas vos données personnelles à des tiers. Les données peuvent être partagées uniquement dans les cas suivants :\n\n'
                '• Avec les autres utilisateurs de la plateforme dans le cadre normal des transactions commerciales.\n\n'
                '• Avec nos prestataires techniques (hébergement, sécurité) sous contrat de confidentialité.\n\n'
                '• Sur demande des autorités compétentes dans le cadre légal applicable.',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              'En utilisant FACILITAR, vous acceptez cette politique de confidentialité. '
              'Pour toute question, contactez-nous à support@facilitar.cm ou au +237 677 000 000.',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _section({
    required String number,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3E50),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
                fontSize: 13.5, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
