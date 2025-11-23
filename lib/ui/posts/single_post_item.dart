import 'package:ct312h_project/app/app_route.dart';
import 'package:ct312h_project/models/post.dart';
import 'package:ct312h_project/ui/posts/post_action.dart';
import 'package:ct312h_project/ui/posts/post_header.dart';
import 'package:ct312h_project/ui/shared/app_images.dart';
import 'package:ct312h_project/ui/shared/full_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

class SinglePostItem extends StatefulWidget {
  const SinglePostItem({
    super.key,
    required this.post,
    this.isFromSearch = false,
  });
  final Post post;
  final bool isFromSearch;

  @override
  State<SinglePostItem> createState() => _SinglePostItemState();
}

class _SinglePostItemState extends State<SinglePostItem> {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: () {
        context.pushNamed(
          AppRouteName.detailPost.name,
          pathParameters: {'id': widget.post.id},
        );
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Avatar(userId: widget.post.userId, size: 45),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostHeader(post: widget.post),
                      const SizedBox(height: 4),
                      Text(widget.post.content, style: textTheme.bodyLarge),
                      if (widget.post.images.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildImageSlider(context, widget.post.images),
                      ],
                      const SizedBox(height: 8),
                      PostAction(
                        post: widget.post,
                        isFromSearch: widget.isFromSearch,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: colorScheme.onSurface.withOpacity(0.12)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider(BuildContext context, List<String> images) {
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
                            postId: widget.post.id,
                          ),
                        ),
                      );
                    },
                    child: PostImage(
                      postId: widget.post.id,
                      image: images[index],
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
                width: 6.0,
                height: 6.0,
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
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

  // String _getImageUrl(String fileName) {
  //   return '$baseUrl/api/files/posts/${widget.post.id}/$fileName';
  // }
}
