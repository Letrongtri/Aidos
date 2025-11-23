import 'package:ct312h_project/utils/url.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.userId, this.size = 45});

  final String userId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: size / 2,

      backgroundColor: colorScheme.surfaceContainerHighest,
      backgroundImage: NetworkImage(
        "https://robohash.org/${Uri.encodeComponent(userId)}.png?set=set2&size=200x200",
      ),
    );
  }
}

class PostImage extends StatelessWidget {
  const PostImage({super.key, required this.postId, required this.image});

  final String postId;
  final String image;

  @override
  Widget build(BuildContext context) {
    final url = Url.getPostImageUrl(postId, image);
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.withOpacity(0.1),
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey.withOpacity(0.1),
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}
