import 'package:ct312h_project/ui/user/edit_profile_screen.dart';
import 'package:ct312h_project/ui/user/widgets/profile_actions.dart';
import 'package:ct312h_project/ui/user/widgets/profile_header.dart';
import 'package:ct312h_project/viewmodels/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          return DefaultTabController(
            length: 3,
            child: Scaffold(
              body: SlidingUpPanel(
                controller: viewModel.panelController,
                minHeight: 0,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                panelBuilder: (ScrollController sc) {
                  if (viewModel.user == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return EditProfileScreen(
                    panelController: viewModel.panelController,
                    user: viewModel.user!,
                  );
                },

                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        if (viewModel.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (viewModel.user != null)
                          ProfileHeader(user: viewModel.user!),
                        if (viewModel.user != null)
                          ProfileActions(
                            onEditProfile: viewModel.openEditPanel,
                          ),

                        const SizedBox(height: 25),
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
                              Center(child: Text('Your posts here')),
                              Center(child: Text('Your replies here')),
                              Center(child: Text('Your reposts here')),
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
        },
      ),
    );
  }
}
