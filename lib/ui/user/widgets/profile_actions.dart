import 'package:flutter/material.dart';

class ProfileActions extends StatelessWidget {
  final VoidCallback onEditProfile;
  const ProfileActions({super.key, required this.onEditProfile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: InkWell(
              onTap: onEditProfile,
              child: Container(
                alignment: Alignment.center,
                height: 35,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Edit Profile'),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: () {
                /* TODO: Handle share profile */
              },
              child: Container(
                alignment: Alignment.center,
                height: 35,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Share Profile'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
