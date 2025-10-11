import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/viewmodels/edit_profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({
    super.key,
    required this.panelController,
    required this.user,
  });

  final PanelController panelController;
  final User user;

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    EditProfileViewModel viewModel,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete Account'),
          content: const Text('Are you sure? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await viewModel.deleteAccount();

                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                panelController.close();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditProfileViewModel(user: user),
      child: Consumer<EditProfileViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _buildHeader(context, viewModel),
                const Divider(thickness: 1, color: Colors.grey),
                Expanded(child: _buildForm(context, viewModel)),
                if (viewModel.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EditProfileViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: panelController.close,
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
            onPressed: viewModel.isLoading
                ? null
                : () async {
                    final success = await viewModel.saveProfile();
                    if (success) {
                      panelController.close();
                    }
                  },
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
    );
  }

  Widget _buildForm(BuildContext context, EditProfileViewModel viewModel) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      children: [
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(viewModel.user.name),
                subtitle: Text(viewModel.user.username),
                trailing: CircleAvatar(
                  backgroundImage: AssetImage(viewModel.user.avatarUrl),
                  radius: 20,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Bio'),
                subtitle: TextFormField(
                  controller: viewModel.bioController,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Link'),
                subtitle: TextFormField(
                  controller: viewModel.linkController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Add link...',
                  ),
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Private profile'),
                value: viewModel.isPrivateProfile,
                onChanged: (value) => viewModel.setPrivateProfile(value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => _showDeleteConfirmationDialog(context, viewModel),
          child: const Text(
            'Delete Account',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
