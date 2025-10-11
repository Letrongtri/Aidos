import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.panelController});

  final PanelController panelController;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm to delete account'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure to delete it?'),
                SizedBox(height: 8),
                Text(
                  'All of your data can be delete forever',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                print('Account deletion requested!');
                Navigator.of(context).pop();
                widget.panelController.close();
              },
            ),
          ],
        );
      },
    );
  }

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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: [
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                        const Divider(color: Colors.grey, height: 1),
                        ListTile(
                          title: const Text(
                            'Bio',
                            style: TextStyle(color: Colors.black),
                          ),
                          subtitle: TextFormField(
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              hintText: 'Bio needs to be here...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const Divider(color: Colors.grey, height: 1),
                        ListTile(
                          title: const Text(
                            'Link',
                            style: TextStyle(color: Colors.black),
                          ),
                          subtitle: TextFormField(
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              hintText: 'Yourlink/@yourlink',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const Divider(color: Colors.grey, height: 1),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
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
                                  setState(() => isChecked = value);
                                },
                                activeColor: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 20.0,
                          ),
                          child: TextButton(
                            onPressed: () {
                              _showDeleteConfirmationDialog(context);
                            },
                            child: const Text(
                              'Delete Account',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
