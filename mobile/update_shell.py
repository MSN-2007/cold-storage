import os

main_shell_content = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/auth_provider.dart';
import '../theme/app_theme.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _getCurrentIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/devices')) return 1;
    if (location.startsWith('/alerts')) return 2;
    if (location.startsWith('/goods')) return 3;
    if (location.startsWith('/reports')) return 4;
    if (location.startsWith('/technician')) return 5;
    if (location.startsWith('/settings')) return 6;
    return 0; // default to dashboard
  }

  void _onNavigate(int index) {
    switch (index) {
      case 0: context.go('/dashboard'); break;
      case 1: context.go('/devices'); break;
      case 2: context.go('/alerts'); break;
      case 3: context.go('/goods'); break;
      case 4: context.go('/reports'); break;
      case 5: context.go('/technician'); break;
      case 6: context.go('/settings'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getCurrentIndex(location);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(currentIndex: currentIndex, onNavigate: _onNavigate),
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: widget.child,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex > 3 ? 3 : currentIndex,
        onDestinationSelected: (idx) {
          if (idx == 3 && currentIndex > 3) {
            _onNavigate(6); // Go to settings/more
          } else {
            _onNavigate(idx);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.sensors_outlined), selectedIcon: Icon(Icons.sensors), label: 'Storages'),
          NavigationDestination(
            icon: Badge(label: Text('8'), child: Icon(Icons.notifications_outlined)),
            selectedIcon: Badge(label: Text('8'), child: Icon(Icons.notifications)),
            label: 'Alerts',
          ),
          NavigationDestination(icon: Icon(Icons.menu), selectedIcon: Icon(Icons.menu_open), label: 'More'),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigate;

  const _Sidebar({required this.currentIndex, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: CSColors.sidebarDark,
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.ac_unit, color: CSColors.accent, size: 28),
                const SizedBox(width: 12),
                Text('ColdSmart', style: CSTextStyles.titleLarge.copyWith(color: Colors.white, fontSize: 22)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Nav Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _NavItem(icon: Icons.home_outlined, title: 'Dashboard', isSelected: currentIndex == 0, onTap: () => onNavigate(0)),
                _NavItem(icon: Icons.inventory_2_outlined, title: 'My Storages', isSelected: currentIndex == 1, onTap: () => onNavigate(1)),
                _NavItem(icon: Icons.notifications_outlined, title: 'Alerts', isSelected: currentIndex == 2, onTap: () => onNavigate(2), badgeCount: 8),
                _NavItem(icon: Icons.all_inbox_outlined, title: 'Inventory', isSelected: currentIndex == 3, onTap: () => onNavigate(3)),
                _NavItem(icon: Icons.bar_chart_outlined, title: 'Reports', isSelected: currentIndex == 4, onTap: () => onNavigate(4)),
                _NavItem(icon: Icons.build_circle_outlined, title: 'Technician', isSelected: currentIndex == 5, onTap: () => onNavigate(5)),
                _NavItem(icon: Icons.settings_outlined, title: 'Settings', isSelected: currentIndex == 6, onTap: () => onNavigate(6)),
                _NavItem(icon: Icons.help_outline, title: 'FAQ', isSelected: false, onTap: () {}),
              ],
            ),
          ),
          // Bottom Actions
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/devices/add'),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add Device', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.eco, color: CSColors.success),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('App Mode', style: CSTextStyles.labelSmall.copyWith(color: Colors.white70)),
                            Text('Simple', style: CSTextStyles.bodyMedium.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('ColdSmart v1.0.0', style: CSTextStyles.labelSmall.copyWith(color: Colors.white38)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;

  const _NavItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? CSColors.primaryLight.withOpacity(0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white60, size: 22),
            const SizedBox(width: 16),
            Text(title, style: CSTextStyles.titleMedium.copyWith(color: isSelected ? Colors.white : Colors.white70)),
            const Spacer(),
            if (badgeCount != null && badgeCount! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: CSColors.critical, borderRadius: BorderRadius.circular(10)),
                child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
"""

with open(r"c:\work\cold_v1.0.1\mobile\lib\core\shell\main_shell.dart", "w", encoding="utf-8") as f:
    f.write(main_shell_content)
print("Updated main_shell.dart")
