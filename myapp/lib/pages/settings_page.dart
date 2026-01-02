import 'package:flutter/material.dart';
import '../services/storage_service.dart';

const customGreen = Color(0xFF4A6B3E);

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres", style: TextStyle(color: customGreen)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: customGreen),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: customGreen,
              ),
            ),
            const SizedBox(height: 15),
            _buildSettingTile(
              title: 'Alertes système',
              subtitle: 'Recevoir des notifications pour les alertes',
              value: true,
              onChanged: (value) {
                // TODO: Save notification preference
              },
            ),
            const SizedBox(height: 10),
            _buildSettingTile(
              title: 'Mises à jour',
              subtitle: 'Notifications pour les mises à jour de l\'application',
              value: false,
              onChanged: (value) {
                // TODO: Save notification preference
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'Général',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: customGreen,
              ),
            ),
            const SizedBox(height: 15),
            _buildActionTile(
              title: 'Langue',
              subtitle: 'Français',
              icon: Icons.language,
              onTap: () {
                // TODO: Language selection
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sélection de langue à venir')),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              title: 'Thème',
              subtitle: 'Clair',
              icon: Icons.brightness_6,
              onTap: () {
                // TODO: Theme selection
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sélection de thème à venir')),
                );
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'Compte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: customGreen,
              ),
            ),
            const SizedBox(height: 15),
            _buildActionTile(
              title: 'Changer le mot de passe',
              subtitle: 'Mettre à jour votre mot de passe',
              icon: Icons.lock,
              onTap: () {
                Navigator.pushNamed(context, '/forgot-password');
              },
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              title: 'Supprimer le compte',
              subtitle: 'Supprimer définitivement votre compte',
              icon: Icons.delete_outline,
              onTap: () {
                _showDeleteAccountDialog(context);
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'À propos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: customGreen,
              ),
            ),
            const SizedBox(height: 15),
            _buildActionTile(
              title: 'Version',
              subtitle: '1.0.0',
              icon: Icons.info_outline,
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              title: 'Politique de confidentialité',
              subtitle: 'Lire notre politique',
              icon: Icons.privacy_tip_outlined,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Politique de confidentialité à venir')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: customGreen.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: customGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: customGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: customGreen.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: customGreen, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: customGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: customGreen),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Suppression de compte à implémenter'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

