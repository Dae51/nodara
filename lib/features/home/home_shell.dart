import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nodara/features/applications/my_applications_screen.dart';
import 'package:nodara/features/explore/explore_screen.dart';
import 'package:nodara/features/notifications/notifications_provider.dart';
import 'package:nodara/features/notifications/notifications_screen.dart';
import 'package:nodara/features/profile/profile_screen.dart';

/// Navegación inferior del voluntario.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index = widget.initialIndex;

  void _select(int index) {
    if (_index == index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationsProvider>().unreadCount;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          ExploreScreen(onOpenApplications: () => _select(1)),
          MyApplicationsScreen(onOpenNotifications: () => _select(2)),
          const NotificationsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          const NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Postulaciones',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications),
            ),
            label: 'Avisos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
