import 'package:ct312h_project/app/app_route.dart';
import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/ui/shared/avatar.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:ct312h_project/utils/generate.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DetailPostContent extends StatelessWidget {
  const DetailPostContent({super.key, required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    final postsManager = context.watch<PostsManager>();
    final isReposted = postsManager.hasUserReposted(post.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Avatar(userId: post.userId, size: 25),
            SizedBox(width: 8),
            Text(
              post.user?.username ?? Generate.generateUsername(post.userId),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Text(
              Format.getTimeDifference(post.created),
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(post.content),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                context.read<PostsManager>().onLikePostPressed(post.id);
              },
              label: Text(Format.getCountNumber(post.likes)),
              icon: Icon(
                post.isLiked ?? false ? Icons.favorite : Icons.favorite_outline,
                color: post.isLiked ?? false ? Colors.red : Colors.white,
              ),
            ),
            SizedBox(width: 4),
            TextButton.icon(
              onPressed: () {
                context.goNamed(
                  AppRouteName.detailPost.name,
                  pathParameters: {'id': post.id},
                  extra: {'focusComment': true},
                );
              },
              label: Text(Format.getCountNumber(post.comments)),
              icon: Icon(Icons.mode_comment_outlined),
            ),
            SizedBox(width: 4),
            TextButton.icon(
              onPressed: () {
                context.read<PostsManager>().onRepostPressed(post.id);
              },
              label: Text(Format.getCountNumber(post.reposts)),
              icon: Icon(
                isReposted ? Icons.repeat : Icons.repeat_outlined,
                color: isReposted ? Colors.green : Colors.white,
              ),
            ),
          ],
        ),
        Divider(height: 20, color: Colors.grey),
      ],
    );
  }
}
