import 'package:ct312h_project/models/user.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final User user;
  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final ImageProvider avatarProvider =
        (user.avatarUrl != null &&
            user.avatarUrl is String &&
            (user.avatarUrl as String).isNotEmpty)
        ? NetworkImage(user.avatarUrl)
        : const AssetImage('assets/images/default_avatar.png');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(backgroundImage: avatarProvider, radius: 35),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              user.username.isNotEmpty ? user.username : 'Anonymous',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
