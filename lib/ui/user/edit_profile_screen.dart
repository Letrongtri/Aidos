import 'package:ct312h_project/app/app_route.dart';
import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/ui/shared/avatar.dart';
import 'package:ct312h_project/ui/shared/dialog_utils.dart';
import 'package:ct312h_project/viewmodels/profile_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class EditProfileScreen extends StatelessWidget {
  final PanelController panelController;
  final User user;

  const EditProfileScreen({
    super.key,
    required this.panelController,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileManager>();

    return Container(
      color: Colors.black,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context, vm),
              const Divider(color: Colors.white24),
              ListTile(
                title: Text(
                  '@${vm.user?.username ?? ''}',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: Avatar(userId: vm.user!.id, size: 25),
              ),
              const Divider(color: Colors.white24),
              _form(context, vm),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        await vm.logout();
                        if (context.mounted) {
                          context.pushReplacementNamed(AppRouteName.auth.name);
                        }
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: vm.deleteAccount,
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (vm.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, ProfileManager vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: panelController.close,
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const Text(
          'Edit profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        TextButton(
          onPressed: vm.isLoading
              ? null
              : () async {
                  final err = vm.validateBeforeSave();
                  if (err != null) {
                    if (context.mounted) {
                      showErrorDialog(context, err);
                    }
                    return;
                  }

                  final ok = await vm.saveProfile(
                    oldPassword: vm.oldPasswordController.text.trim(),
                    newPassword: vm.newPasswordController.text.trim(),
                    confirmPassword: vm.confirmPasswordController.text.trim(),
                  );

                  if (ok && context.mounted) {
                    showAppSnackBar(context, message: 'Profile updated!');
                  } else if (!ok && context.mounted) {
                    showErrorDialog(context, 'Failed to update profile');
                  }

                  if (ok) panelController.close();
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
    );
  }

  Widget _form(BuildContext context, ProfileManager vm) {
    return Column(
      children: [
        _inputField('Username', vm.usernameController),
        const Divider(color: Colors.white24),
        _inputField(
          'Email (cannot be changed)',
          vm.emailController,
          enabled: false,
        ),

        const Divider(color: Colors.white24),
        _inputField('Old Password', vm.oldPasswordController, obscure: true),
        const Divider(color: Colors.white24),
        _inputField('New Password', vm.newPasswordController, obscure: true),
        _inputField(
          'Confirm Password',
          vm.confirmPasswordController,
          obscure: true,
        ),
      ],
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        enabled: enabled,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1C1C1C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
