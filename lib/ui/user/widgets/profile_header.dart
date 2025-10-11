import 'package:ct312h_project/models/user.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final User user;
  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(user.name),
          subtitle: Text(user.username),
          contentPadding: EdgeInsets.zero,
          trailing: CircleAvatar(
            backgroundImage: AssetImage(user.avatarUrl),
            radius: 25,
          ),
        ),
        Text(user.bio),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            '${user.followerCount} followers',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
