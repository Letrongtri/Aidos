import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.userId, this.size = 45});

  final String userId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundImage: NetworkImage(
        "https://robohash.org/${Uri.encodeComponent(userId)}.png?set=set2&size=200x200",
      ),
    );
  }
}
