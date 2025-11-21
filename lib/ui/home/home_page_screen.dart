import 'package:ct312h_project/viewmodels/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _onItemTapped(int index) {
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    // Lấy Theme
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    int unreadCount = context.watch<NotificationManager>().unreadCount;

    final isDetail = GoRouterState.of(
      context,
    ).uri.toString().contains('/posts/');

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: isDetail
            ? null
            : BottomNavigationBar(
                currentIndex: navigationShell.currentIndex,

                backgroundColor: colorScheme.surface,

                selectedItemColor: colorScheme.secondary,

                unselectedItemColor: colorScheme.onSurface.withOpacity(0.5),
                showSelectedLabels: false,
                showUnselectedLabels: false,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,

                elevation: 0,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: "Feed",
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: "Search",
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.add_box_outlined),
                    activeIcon: Icon(Icons.add_box),
                    label: "Post",
                  ),
                  BottomNavigationBarItem(
                    icon: Badge(
                      isLabelVisible: unreadCount > 0,
                      label: Text(unreadCount.toString()),

                      backgroundColor: colorScheme.error,
                      textColor: colorScheme.onError,
                      child: const Icon(Icons.notifications),
                    ),
                    label: "Notification",
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: "Profile",
                  ),
                ],
              ),
      ),
    );
  }
}
