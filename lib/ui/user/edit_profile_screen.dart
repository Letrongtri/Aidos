import 'package:ct312h_project/app/app_route.dart';
import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/ui/shared/app_images.dart';
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

  Future<void> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.only(
          left: 24,
          top: 24,
          right: 24,
          bottom: 10,
        ),
        contentPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 10),
        actionsPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: TextButton.styleFrom(foregroundColor: confirmColor),
            child: Text(
              confirmText,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: confirmColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileManager>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context, vm, textTheme, colorScheme),
            Divider(color: colorScheme.onSurface.withOpacity(0.12)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '@${vm.user?.username ?? ''}',
                style: textTheme.bodyLarge,
              ),
              trailing: Avatar(userId: vm.user!.id, size: 25),
            ),
            Divider(color: colorScheme.onSurface.withOpacity(0.12)),
            _form(context, vm, textTheme, colorScheme),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      _showConfirmDialog(
                        context,
                        title: 'Log out',
                        content: 'Are you sure you want to log out?',
                        confirmText: 'Log out',
                        confirmColor: const Color(0xFFFF3B30),
                        onConfirm: () async {
                          await vm.logout();
                          if (context.mounted) {
                            context.pushReplacementNamed(
                              AppRouteName.auth.name,
                            );
                          }
                        },
                      );
                    },
                    child: Text(
                      'Logout',
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showConfirmDialog(
                        context,
                        title: 'Confirm account deletion',
                        content: 'Are you sure? This action cannot be undone.',
                        confirmText: 'Delete',
                        confirmColor: const Color(0xFFFF3B30),
                        onConfirm: () async {
                          await vm.deleteAccount();
                          if (context.mounted) {
                            context.pushReplacementNamed(
                              AppRouteName.auth.name,
                            );
                          }
                        },
                      );
                    },
                    child: Text(
                      'Delete Account',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (vm.isLoading)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.secondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header(
    BuildContext context,
    ProfileManager vm,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: panelController.close,
          child: Text(
            'Cancel',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          'Edit profile',
          style: textTheme.titleLarge?.copyWith(fontSize: 18),
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

                  if (ok && context.mounted) {
                    showAppSnackBar(context, message: 'Profile updated!');
                    if (panelController.isAttached) {
                      panelController.close();
                    }
                  }
                },
          child: Text(
            'Done',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _form(
    BuildContext context,
    ProfileManager vm,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        _inputField('Username', vm.usernameController, textTheme, colorScheme),
        Divider(color: colorScheme.onSurface.withOpacity(0.12)),
        _inputField(
          'Email (cannot be changed)',
          vm.emailController,
          textTheme,
          colorScheme,
          enabled: false,
        ),
        Divider(color: colorScheme.onSurface.withOpacity(0.12)),
        _inputField(
          'Old Password',
          vm.oldPasswordController,
          textTheme,
          colorScheme,
          obscure: true,
        ),
        Divider(color: colorScheme.onSurface.withOpacity(0.12)),
        _inputField(
          'New Password',
          vm.newPasswordController,
          textTheme,
          colorScheme,
          obscure: true,
        ),
        _inputField(
          'Confirm Password',
          vm.confirmPasswordController,
          textTheme,
          colorScheme,
          obscure: true,
        ),
      ],
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller,
    TextTheme textTheme,
    ColorScheme colorScheme, {
    bool obscure = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        enabled: enabled,
        style: textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          filled: true,
          fillColor: colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: colorScheme.onSurface.withOpacity(0.12),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: colorScheme.onSurface.withOpacity(0.12),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colorScheme.secondary),
          ),
        ),
      ),
    );
  }
}
