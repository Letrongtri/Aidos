import 'package:ct312h_project/app/app_route.dart';
import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/ui/shared/app_images.dart';
import 'package:ct312h_project/ui/shared/full_image_viewer.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:ct312h_project/utils/generate.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DetailPostContent extends StatefulWidget {
  const DetailPostContent({super.key, required this.post});
  final Post post;

  @override
  State<DetailPostContent> createState() => _DetailPostContentState();
}

class _DetailPostContentState extends State<DetailPostContent> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final postsManager = context.watch<PostsManager>();
    final isReposted = postsManager.hasUserReposted(widget.post.id);
    final isLiked = widget.post.isLiked ?? false;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final post = widget.post;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Avatar(userId: widget.post.userId, size: 40),
            const SizedBox(width: 8),
            Text(
              widget.post.user?.username ??
                  Generate.generateUsername(widget.post.userId),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[300],
              ),
            ),

            if (post.topic != null)
              Row(
                children: [
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  TextButton(
                    onPressed: () {
                      context.goNamed(
                        AppRouteName.search.name,
                        queryParameters: {'q': post.topic!.name},
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      post.topic!.name,

                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),

            const Spacer(),
            Text(
              Format.getTimeDifference(post.created),
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(post.content, style: textTheme.bodyLarge),
        if (post.images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            child: _buildImageSlider(context, post.images, post.id),
          ),
        const SizedBox(height: 4),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                context.read<PostsManager>().onLikePostPressed(post.id);
              },
              style: TextButton.styleFrom(
                foregroundColor: isLiked
                    ? colorScheme.error
                    : colorScheme.onSurface,
              ),
              label: Text(
                Format.getCountNumber(post.likes),
                style: textTheme.bodyMedium?.copyWith(
                  color: isLiked ? colorScheme.error : colorScheme.onSurface,
                ),
              ),
              icon: Icon(isLiked ? Icons.favorite : Icons.favorite_outline),
            ),
            const SizedBox(width: 4),
            TextButton.icon(
              onPressed: () {
                context.pushNamed(
                  AppRouteName.detailPost.name,
                  pathParameters: {'id': post.id},
                  extra: {'focusComment': true},
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
              ),
              label: Text(
                Format.getCountNumber(post.comments),
                style: textTheme.bodyMedium,
              ),
              icon: const Icon(Icons.mode_comment_outlined),
            ),
            const SizedBox(width: 4),
            TextButton.icon(
              onPressed: () {
                context.read<PostsManager>().onRepostPressed(post.id);
              },
              style: TextButton.styleFrom(
                foregroundColor: isReposted
                    ? Colors.white
                    : colorScheme.onSurface,
              ),
              label: Text(
                Format.getCountNumber(post.reposts),
                style: textTheme.bodyMedium?.copyWith(
                  color: isReposted ? Colors.white : colorScheme.onSurface,
                ),
              ),
              icon: Icon(isReposted ? Icons.repeat : Icons.repeat_outlined),
            ),
          ],
        ),
        Divider(height: 20, color: colorScheme.onSurface.withOpacity(0.12)),
      ],
    );
  }

  Widget _buildImageSlider(
    BuildContext context,
    List<String> images,
    String postId,
  ) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullImageViewer(
                            images: images,
                            initialIndex: index,
                            postId: postId,
                          ),
                        ),
                      );
                    },
                    child: PostImage(postId: postId, image: images[index]),
                  ),
                ),
              );
            },
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
