import 'package:flutter/material.dart';
import 'package:frontend_dilaundry/config/app_assets.dart';
import 'package:frontend_dilaundry/config/app_constants.dart';
import 'package:frontend_dilaundry/config/app_format.dart';
import 'package:frontend_dilaundry/config/nav.dart';
import 'package:frontend_dilaundry/datasources/auth_datasource.dart';
import 'package:frontend_dilaundry/models/user_model.dart';
import 'package:frontend_dilaundry/pages/auth/login_page.dart';
import 'package:frontend_dilaundry/pages/claim_page.dart';
import 'package:frontend_dilaundry/pages/recommendation_page.dart';

class ProfilePage extends StatelessWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar Akun'),
          content: const Text('Kamu akan keluar dari akun ini. Lanjutkan?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await AuthDatasource.logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tentang Aplikasi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppConstants.appname} adalah aplikasi pemesanan laundry '
                'yang terhubung ke backend Laravel Di Laundry.',
              ),
              const SizedBox(height: 10),
              Text(
                'Alamat API saat ini: ${AppConstants.baseUrl}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundImage: const AssetImage(AppAssets.profile),
                  onBackgroundImageError: (exception, stackTrace) {},
                  child: const Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  user.username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bergabung sejak ${AppFormat.fullDate(user.createdAt)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.recommend_outlined),
                  title: const Text('Rekomendasi Toko'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Nav.push(context, const RecommendationPage());
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.qr_code_2),
                  title: const Text('Klaim Laundry'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Nav.push(context, ClaimPage(user: user));
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Tentang Aplikasi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAbout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Keluar', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ],
      ),
    );
  }
}
