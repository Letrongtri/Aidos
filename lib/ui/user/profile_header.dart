// lib/ui/user/profile_header.dart
import 'package:ct312h_project/models/user.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final User user;
  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Lấy Theme từ context
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final hasAvatar =
        user.avatarUrl != null && user.avatarUrl!.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 35,

          backgroundColor: colorScheme.surfaceContainerHighest,
          backgroundImage: hasAvatar ? NetworkImage(user.avatarUrl!) : null,
          child: !hasAvatar
              ? Icon(
                  Icons.person,
                  size: 35,

                  color: colorScheme.onSurface.withOpacity(0.5),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username,

                style: textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                user.email,

                style: textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
