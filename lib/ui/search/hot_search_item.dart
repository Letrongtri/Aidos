import 'package:flutter/material.dart';

class HotSearchItem extends StatelessWidget {
  const HotSearchItem({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("find");
      },
      child: ListTile(
        trailing: Icon(Icons.trending_up),
        title: Text("Flutter"),
      ),
    );
  }
}
