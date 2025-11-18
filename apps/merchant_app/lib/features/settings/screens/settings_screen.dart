import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import '../../../config/providers.dart';

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// Language provider
final languageProvider = StateProvider<String>((ref) => 'en');

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.store,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Merchant Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '9851234567',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile edit coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Appearance Section
          _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: AppColors.primary,
            ),
            title: const Text('Theme'),
            subtitle: Text(
              themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
            ),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).state =
                    value ? ThemeMode.dark : ThemeMode.light;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Dark mode enabled'
                          : 'Light mode enabled',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.primary),
            title: const Text('Language'),
            subtitle: Text(language == 'en' ? 'English' : 'नेपाली'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageDialog(context, ref, language);
            },
          ),

          const Divider(),

          // Business Section
          _SectionHeader(title: 'Business'),
          ListTile(
            leading: const Icon(Icons.business, color: AppColors.primary),
            title: const Text('Business Information'),
            subtitle: const Text('Update your business details'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Business info coming soon!'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long, color: AppColors.primary),
            title: const Text('Invoice Settings'),
            subtitle: const Text('Customize your invoice'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invoice settings coming soon!'),
                ),
              );
            },
          ),

          const Divider(),

          // Data & Privacy
          _SectionHeader(title: 'Data & Privacy'),
          ListTile(
            leading: const Icon(Icons.backup, color: AppColors.primary),
            title: const Text('Backup Data'),
            subtitle: const Text('Backup to cloud'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup feature coming soon!'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download, color: AppColors.primary),
            title: const Text('Export Data'),
            subtitle: const Text('Download your data'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export feature coming soon!'),
                ),
              );
            },
          ),

          const Divider(),

          // Support & About
          _SectionHeader(title: 'Support & About'),
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppColors.primary),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help center coming soon!'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy policy coming soon!'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.primary),
            title: const Text('About'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showAboutDialog(context);
            },
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              _showLogoutDialog(context, ref);
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, String currentLanguage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  ref.read(languageProvider.notifier).state = value;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Language changed to English'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('नेपाली (Nepali)'),
              value: 'ne',
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  ref.read(languageProvider.notifier).state = value;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('भाषा नेपालीमा परिवर्तन भयो'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.store, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Fonepay Khata Book'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Version 1.0.0'),
            const SizedBox(height: 8),
            const Text('A complete digital bookkeeping solution for merchants.'),
            const SizedBox(height: 16),
            const Text(
              '© 2025 Fonepay',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Clear secure storage
              final secureStorage = ref.read(secureStorageProvider);
              await secureStorage.delete(key: 'accessToken');
              await secureStorage.delete(key: 'refreshToken');

              if (!context.mounted) return;

              // Navigate to login
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
