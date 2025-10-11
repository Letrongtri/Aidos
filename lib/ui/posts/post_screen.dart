import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key, required this.panelController});
  final PanelController panelController;

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String? _selectedTopic;

  final List<String> _topics = [
    'Công nghệ',
    'Du lịch',
    'Ẩm thực',
    'Thời trang',
    'Thể thao',
    'Giải trí',
  ];

  Future<void> _showTopicSelection(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Chọn một chủ đề',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const Divider(color: Colors.white54),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _topics.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _topics[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context, _topics[index]);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedTopic = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // ====== Thanh header ======
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    widget.panelController.close();
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  'New post',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Post',
                    style: TextStyle(
                      color: Color.fromARGB(255, 20, 132, 237),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, color: Colors.grey),

          // ====== Nội dung bài post ======
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  foregroundImage: AssetImage(
                    'assets/images/logo.png',
                  ), // đổi hình avatar ở đây
                  radius: 25,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // username > topic
                      Row(
                        children: [
                          const Text(
                            'leminhc',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          if (_selectedTopic != null) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: Colors.grey,
                            ),
                            Text(
                              _selectedTopic!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Nội dung bài viết
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: 'Start a post...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                      ),
                      const SizedBox(height: 15),

                      // Nút chọn chủ đề (chip)
                      ActionChip(
                        avatar: Icon(
                          _selectedTopic == null
                              ? Icons.add
                              : Icons.label_outline,
                          color: Colors.grey.shade700,
                          size: 18,
                        ),
                        label: Text(
                          _selectedTopic ?? 'Chọn chủ đề',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        backgroundColor: Colors.transparent,
                        onPressed: () {
                          _showTopicSelection(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
