import 'package:ct312h_project/ui/user/edit_profile_screen.dart';
import 'package:ct312h_project/ui/user/widgets/profile_header.dart';
import 'package:ct312h_project/viewmodels/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SlidingUpPanel(
          controller: vm.panelController,
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          panelBuilder: (ScrollController sc) {
            if (vm.user == null) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            return EditProfileScreen(
              panelController: vm.panelController,
              user: vm.user!,
            );
          },
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Edit button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.dehaze,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () {
                          if (vm.user != null) {
                            vm.openEditPanel();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Đang tải thông tin người dùng...',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  // Profile header
                  if (vm.isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else if (vm.user != null)
                    ProfileHeader(user: vm.user!),

                  const SizedBox(height: 15),

                  const TabBar(
                    labelColor: Colors.white,
                    indicatorColor: Colors.white,
                    tabs: [
                      Tab(text: 'Post'),
                      Tab(text: 'Replied'),
                      Tab(text: 'Reposts'),
                    ],
                  ),

                  const Expanded(
                    child: TabBarView(
                      children: [
                        Center(
                          child: Text(
                            'Your posts here',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Your replies here',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Your reposts here',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
