import 'package:ct312h_project/app/app_route.dart';
import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/ui/shared/avatar.dart';
import 'package:ct312h_project/ui/shared/full_image_viewer.dart';
import 'package:ct312h_project/utils/format.dart';
import 'package:ct312h_project/utils/generate.dart';
import 'package:ct312h_project/viewmodels/posts_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  String get baseUrl {
    String url = dotenv.env['POCKETBASE_URL'] ?? 'http://127.0.0.1:8090';
    if (url.endsWith('/')) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final postsManager = context.watch<PostsManager>();
    final isReposted = postsManager.hasUserReposted(widget.post.id);
    final isLiked = widget.post.isLiked ?? false;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
            const Spacer(),
            Text(
              Format.getTimeDifference(widget.post.created),
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(widget.post.content, style: textTheme.bodyLarge),
        if (widget.post.images != null && widget.post.images!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            child: _buildImageSlider(
              context,
              widget.post.images!,
              widget.post.id,
            ),
          ),
        const SizedBox(height: 4),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                context.read<PostsManager>().onLikePostPressed(widget.post.id);
              },
              style: TextButton.styleFrom(
                foregroundColor: isLiked
                    ? colorScheme.error
                    : colorScheme.onSurface,
              ),
              label: Text(
                Format.getCountNumber(widget.post.likes),
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
                  pathParameters: {'id': widget.post.id},
                  extra: {'focusComment': true},
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
              ),
              label: Text(
                Format.getCountNumber(widget.post.comments),
                style: textTheme.bodyMedium,
              ),
              icon: const Icon(Icons.mode_comment_outlined),
            ),
            const SizedBox(width: 4),
            TextButton.icon(
              onPressed: () {
                context.read<PostsManager>().onRepostPressed(widget.post.id);
              },
              style: TextButton.styleFrom(
                foregroundColor: isReposted
                    ? Colors.white
                    : colorScheme.onSurface,
              ),
              label: Text(
                Format.getCountNumber(widget.post.reposts),
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
                    child: Image.network(
                      '$baseUrl/api/files/posts/$postId/${images[index]}',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.withOpacity(0.1),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.withOpacity(0.1),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                    ),
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
