import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  void _onItemTapped(int index) {
    // Chuyển đến branch tương ứng
    // index: 0=Feed, 1=Search, 2=Post, 3=Notification, 4=Profile
    widget.navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    // Ẩn bottom nav khi ở trang detail post
    final isDetail = GoRouterState.of(
      context,
    ).uri.toString().contains('/posts/');

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: isDetail
            ? null
            : BottomNavigationBar(
                currentIndex: widget.navigationShell.currentIndex,
                selectedItemColor: Colors.white,
                unselectedItemColor: const Color.fromARGB(255, 120, 120, 120),
                showSelectedLabels: false,
                showUnselectedLabels: false,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                items: const [
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
                    icon: Icon(Icons.notifications),
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
