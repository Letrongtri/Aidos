import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.panelController});

  final PanelController panelController;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    widget.panelController.close();
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  'Edit profile',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Color.fromARGB(255, 20, 132, 237),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, color: Colors.black),

          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  width: double.infinity,
                  height: 400,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text(
                          'Name',
                          style: TextStyle(color: Colors.black),
                        ),

                        subtitle: const Text(
                          'username',
                          style: TextStyle(color: Colors.black),
                        ),
                        trailing: InkWell(
                          onTap: () {},
                          child: const CircleAvatar(
                            backgroundImage: AssetImage(
                              'assets/images/logo.png',
                            ),
                            radius: 20,
                          ),
                        ),
                      ),
                      const Divider(color: Colors.black),
                      ListTile(
                        title: const Text(
                          'Bio',
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: TextFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Bio needs to be here...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const Divider(color: Colors.black),
                      ListTile(
                        title: const Text(
                          'Link',
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: TextFormField(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Yourlink/@yourlink',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const Divider(color: Colors.black),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Private profile',
                              style: TextStyle(color: Colors.black),
                            ),
                            Switch(
                              value: isChecked,
                              onChanged: (value) {
                                setState(() {
                                  isChecked = value;
                                });
                              },
                              activeColor: Colors.black,
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
        ],
      ),
    );
  }
}
