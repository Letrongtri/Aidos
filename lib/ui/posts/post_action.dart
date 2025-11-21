import 'package:ct312h_project/app/app_route.dart';
import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PostAction extends StatelessWidget {
  const PostAction({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final postsManager = context.watch<PostsManager>();
    final isReposted = postsManager.hasUserReposted(post.id);

    return Row(
      children: [
        TextButton.icon(
          onPressed: () {
            context.read<PostsManager>().onLikePostPressed(post.id);
          },
          label: Text(Format.getCountNumber(post.likes)),
          icon: Icon(
            post.isLiked ?? false ? Icons.favorite : Icons.favorite_outline,
            color: (post.isLiked != null && post.isLiked!)
                ? Colors.red
                : Colors.white,
          ),
        ),
        SizedBox(width: 5),
        TextButton.icon(
          onPressed: () {
            context.pushNamed(
              AppRouteName.detailPost.name,
              pathParameters: {'id': post.id},
              extra: {'focusComment': true},
            );
          },
          label: Text(Format.getCountNumber(post.comments)),
          icon: Icon(Icons.mode_comment_outlined),
        ),
        SizedBox(width: 5),
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
    );
  }
}
