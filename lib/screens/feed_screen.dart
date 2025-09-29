import 'package:ct312h_project/screens/posts/single_post.dart';
import 'package:flutter/material.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        toolbarHeight: 40,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Image.asset("assets/images/logo.png", width: 30),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(height: 10),
                SinglePost(),
                SinglePost(),
                SinglePost(),
                SinglePost(),
                SinglePost(),
                SinglePost(),
                SinglePost(),
                SinglePost(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
