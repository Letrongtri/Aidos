import 'package:ct312h_project/ui/posts/post_screen.dart';
// import 'package:ct312h_project/ui/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  // int _selectedIndex = 0;
  // final tabs = ['/home/feed', '/home/search'];

  // List<Widget> pages = [];
  PanelController panelController = PanelController();

  // @override
  // void initState() {
  //   // pages = [
  //   //   const FeedScreen(),
  //   //   SearchScreen(),
  //   //   PostScreen(panelController: panelController),
  //   //   const Center(child: Text("Favorite")),
  //   //   const ProfileScreen(),
  //   // ];

  //   super.initState();
  // }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Tab Post mở panel
      panelController.isPanelOpen
          ? panelController.close()
          : panelController.open();
    } else {
      panelController.close();
      // Dùng navigationShell thay vì context.go()
      widget.navigationShell.goBranch(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDetail = GoRouterState.of(
      context,
    ).uri.toString().contains('/posts');

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SlidingUpPanel(
          controller: panelController,
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          panelBuilder: (ScrollController sc) {
            return PostScreen(panelController: panelController);
          },
          body: widget.navigationShell,
        ),
        bottomNavigationBar: isDetail
            ? null
            : BottomNavigationBar(
                currentIndex: widget.navigationShell.currentIndex,
                selectedItemColor: Colors.white,
                unselectedItemColor: const Color.fromARGB(255, 120, 120, 120),
                showSelectedLabels: false,
                showUnselectedLabels: false,
                onTap: _onItemTapped,
                // type: BottomNavigationBarType.fixed,
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
