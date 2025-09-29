import 'package:flutter/material.dart';

class SinglePost extends StatelessWidget {
  const SinglePost({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(
                "https://robohash.org/${Uri.encodeComponent("username123")}.png?set=set2&size=200x200",
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Trai đẹp vct",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Text("5 min"),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.more_horiz),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Hi everyone! Let's share me your secret ☺️"),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.favorite_outline),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.mode_comment_outlined),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.repeat_outlined),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
