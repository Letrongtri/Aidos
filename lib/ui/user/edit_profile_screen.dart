import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/repository/user_repository.dart';
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
          title: const Text('Xác nhận Xóa Tài khoản'),
          content: const Text(
            'Bạn có chắc không? Hành động này không thể hoàn tác.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
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

  Future<void> _showLogoutDialog(BuildContext context) async {
    final userRepo = UserRepository();

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc muốn đăng xuất không?'),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await userRepo.logout(); // gọi hàm logout
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(
                    context,
                  ).pushReplacementNamed('/login'); // quay về login
                }
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
          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildHeader(context, viewModel),
                  const Divider(thickness: 1, color: Colors.grey),
                  _buildForm(context, viewModel),
                  const SizedBox(height: 20),

                  // 🔹 Logout button
                  TextButton(
                    onPressed: () => _showLogoutDialog(context),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 🔹 Delete account button
                  TextButton(
                    onPressed: () =>
                        _showDeleteConfirmationDialog(context, viewModel),
                    child: const Text(
                      'Delete Account',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (viewModel.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              viewModel.user.name,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "@${viewModel.user.username}",
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: CircleAvatar(
              backgroundImage: AssetImage(viewModel.user.avatarUrl),
              radius: 20,
            ),
          ),
          const Divider(height: 1),

          // Bio
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bio', style: TextStyle(color: Colors.black)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: viewModel.bioController,
                  decoration: InputDecoration(
                    hintText: 'Thêm tiểu sử...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.black54,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Link
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Link', style: TextStyle(color: Colors.black)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: viewModel.linkController,
                  decoration: InputDecoration(
                    hintText: 'Thêm liên kết...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.black54,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Private profile
          SwitchListTile(
            title: const Text(
              'Private profile',
              style: TextStyle(color: Colors.black),
            ),
            value: viewModel.isPrivateProfile,
            onChanged: (value) => viewModel.setPrivateProfile(value),
          ),
        ],
      ),
    );
  }
}
