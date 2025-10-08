import 'package:ct312h_project/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  PanelController panelController = PanelController();
  bool isPanelOpen = false;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SlidingUpPanel(
          controller: panelController,
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          panelBuilder: (ScrollController sc) {
            return EditProfileScreen(panelController: panelController);
          },
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text('Trai đẹp vct'),
                    subtitle: Text('@traidepvct'),
                    contentPadding: EdgeInsets.all(0),
                    trailing: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/logo.png'),
                      radius: 25,
                    ),
                  ),
                  Text('Bio needs to be here...'),
                  Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Text(
                      '100 followers',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            panelController.open();
                            setState(() => isPanelOpen = true);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 150,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Edit Profile'),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (isPanelOpen) {
                              panelController.close();
                            } else {
                              panelController.open();
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 150,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Share Profile'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  TabBar(
                    labelColor: Colors.white,
                    indicatorColor: Colors.white,
                    tabs: [
                      Tab(text: 'Post'),
                      Tab(text: 'Replied'),
                      Tab(text: 'Reposts'),
                    ],
                  ),
                  Expanded(
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
  }
}
