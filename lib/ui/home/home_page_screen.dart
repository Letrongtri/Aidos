import 'package:ct312h_project/viewmodels/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _onItemTapped(int index) {
    // Chuyển đến branch tương ứng
    // index: 0=Feed, 1=Search, 2=Post, 3=Notification, 4=Profile
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount = context.watch<NotificationManager>().unreadCount;

    // Ẩn bottom nav khi ở trang detail post
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
                selectedItemColor: Colors.white,
                unselectedItemColor: const Color.fromARGB(255, 120, 120, 120),
                showSelectedLabels: false,
                showUnselectedLabels: false,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: "Feed",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: "Search",
                  ),
                  BottomNavigationBarItem(icon: Icon(Icons.add), label: "Post"),
                  BottomNavigationBarItem(
                    icon: Badge(
                      isLabelVisible: unreadCount > 0,
                      label: Text(unreadCount.toString()),
                      backgroundColor: Colors.red,
                      child: Icon(Icons.notifications),
                    ),
                    label: "Notification",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: "Profile",
                  ),
                ],
              ),
      ),
    );
  }
}
