import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/viewmodels/pofile_manager.dart';
import 'package:flutter/material.dart';
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

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey[900],
        content: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileManager>();

    final hasAvatar =
        vm.user?.avatarUrl != null && vm.user!.avatarUrl!.isNotEmpty;

    final ImageProvider avatarProvider = hasAvatar
        ? NetworkImage(vm.user!.avatarUrl!)
        : const AssetImage('assets/images/default_avatar.png');

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
                trailing: CircleAvatar(
                  backgroundImage: avatarProvider,
                  radius: 25,
                ),
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
                        Navigator.of(
                          context,
                        ).pushReplacementNamed('/login'); // chuyển về login
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
                    _showSnack(context, err);
                    return;
                  }

                  final ok = await vm.saveProfile(
                    oldPassword: vm.oldPasswordController.text.trim(),
                    newPassword: vm.newPasswordController.text.trim(),
                    confirmPassword: vm.confirmPasswordController.text.trim(),
                  );

                  _showSnack(
                    context,
                    ok ? 'Profile updated!' : 'Failed to update profile',
                  );

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
