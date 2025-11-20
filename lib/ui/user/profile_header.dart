// lib/ui/user/profile_header.dart
import 'package:ct312h_project/models/user.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final User user;
  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        user.avatarUrl != null && user.avatarUrl!.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: Colors.grey[900],
          backgroundImage: hasAvatar ? NetworkImage(user.avatarUrl!) : null,
          child: !hasAvatar
              ? const Icon(Icons.person, size: 35, color: Colors.white54)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
