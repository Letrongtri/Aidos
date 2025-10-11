// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ct312h_project/ui/shared/avatar.dart';
import 'package:ct312h_project/ui/shared/show_post_actions_bottom_sheet.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:ct312h_project/viewmodels/post_item_view_model.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SinglePostItem extends StatelessWidget {
  const SinglePostItem({super.key, required this.post});
  final PostItemViewModel post;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.goNamed('detail', pathParameters: {'id': post.id});
      },
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(userId: post.userId, size: 45),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          post.username,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        if (post.topicName != null)
                          Row(
                            children: [
                              SizedBox(width: 4),
                              Icon(Icons.chevron_right),
                              TextButton(
                                onPressed: () {
                                  context.goNamed(
                                    'search',
                                    queryParameters: {'q': post.topicName},
                                  );
                                },
                                child: Text(
                                  post.topicName!,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        Spacer(),
                        Text(Format.getTimeDifference(post.createdAt)),
                        IconButton(
                          onPressed: () {
                            showPostActionsBottomSheet(
                              context,
                              onUpdate: () {},
                            );
                          },
                          icon: Icon(Icons.more_horiz),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(post.content),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                context.read<PostsManager>().onLikePostPressed(
                                  post.id,
                                );
                              },
                              label: Text(
                                Format.getCountNumber(post.likeCount),
                              ),
                              icon: Icon(
                                post.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                color: post.isLiked ? Colors.red : Colors.white,
                              ),
                            ),
                            SizedBox(width: 5),
                            TextButton.icon(
                              onPressed: () {
                                context.goNamed(
                                  'detail',
                                  pathParameters: {'id': post.id},
                                  extra: {'focusComment': true},
                                );
                              },
                              label: Text(
                                Format.getCountNumber(post.commentCount),
                              ),
                              icon: Icon(Icons.mode_comment_outlined),
                            ),
                            SizedBox(width: 5),
                            TextButton.icon(
                              onPressed: () {},
                              label: Text(
                                Format.getCountNumber(post.repostCount),
                              ),
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
      ),
    );
  }
}
