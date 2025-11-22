import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String postId;

  const FullImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.postId,
  });

  @override
  State<FullImageViewer> createState() => _FullImageViewerState();
}

class _FullImageViewerState extends State<FullImageViewer> {
  late PageController _pageController;

  // Lấy baseUrl giống như các file khác
  String get baseUrl {
    String url = dotenv.env['POCKETBASE_URL'] ?? 'http://127.0.0.1:8090';
    if (url.endsWith('/')) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Nền đen
      // Nút đóng (X) và AppBar
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // Thư viện PhotoViewGallery để lướt và zoom
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          final imageUrl =
              '$baseUrl/api/files/posts/${widget.postId}/${widget.images[index]}';

          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrl),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(tag: widget.images[index]),
          );
        },
        itemCount: widget.images.length,
        loadingBuilder: (context, event) =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        pageController: _pageController,
      ),
    );
  }
}
