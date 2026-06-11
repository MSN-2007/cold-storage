import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/domain/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;

    final isExpert = user?.appMode == 'expert';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Configuration'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User profile card summary
          if (user != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(user.name[0], style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text('Role: ${user.role.toUpperCase()}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          Text(user.email.isNotEmpty ? user.email : user.phone, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Preferences section
          Text('App Preferences', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Expert Mode Interface'),
                  subtitle: const Text('Show full NDIR sensor indexes (O₂, Ethylene, CO) alongside Temperature.'),
                  value: isExpert,
                  onChanged: (val) {
                    ref.read(authStateProvider.notifier).toggleAppMode();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(val ? 'Expert view enabled.' : 'Simple view (farmer-friendly) active.')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Preferred Language'),
                  subtitle: const Text('English (US)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showLanguageDialog(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // System management
          Text('System Administration', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('Audit Trail Logs'),
                  subtitle: const Text('Compliance tracking of target changes & device access.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/audit'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.grass),
                  title: const Text('Crop Profiles Library'),
                  subtitle: const Text('Browse environmental storage guidelines & recipes.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/crop-profiles'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.analytics_outlined),
                  title: const Text('Compliance Reports'),
                  subtitle: const Text('Generate compliant temperature audits & invoices.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/reports'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Logout
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.red.shade900,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Log Out Account', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                trailing: const Icon(Icons.check, color: Colors.blue),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('हिन्दी (Hindi)'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('ਪੰਜਾਬੀ (Punjabi)'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
