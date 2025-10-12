import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:ct312h_project/repository/user_repository.dart';
import 'package:ct312h_project/repository/topic_repository.dart';
import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/models/topic.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key, required this.panelController});
  final PanelController panelController;

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String? _selectedTopic;
  final TextEditingController _contentController = TextEditingController();
  final UserRepository _userRepository = UserRepository();
  final TopicRepository _topicRepository = TopicRepository();

  Future<User?> _fetchCurrentUser() => _userRepository.fetchCurrentUser();
  Future<List<Topic>> _fetchTopics() => _topicRepository.fetchTopics();

  Future<void> _showTopicSelection(BuildContext context) async {
    final topics = await _fetchTopics();

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  return ListTile(
                    title: Text(
                      topic.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context, topic.name);
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
    return FutureBuilder<User?>(
      future: _fetchCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("Không tìm thấy user"));
        }

        final user = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // ===== Header =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => widget.panelController.close(),
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
                      onPressed: () {
                        debugPrint(
                          'Post by ${user.username}: ${_contentController.text} (${_selectedTopic ?? "no topic"})',
                        );
                      },
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

              // ===== Nội dung =====
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      foregroundImage: AssetImage(user.avatarUrl),
                      radius: 25,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // username + topic
                          Row(
                            children: [
                              Text(
                                user.username,
                                style: const TextStyle(
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

                          // Ô nhập bài viết
                          TextFormField(
                            controller: _contentController,
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
                          const SizedBox(height: 10),

                          // Nút chọn chủ đề
                          GestureDetector(
                            onTap: () => _showTopicSelection(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _selectedTopic == null
                                        ? Icons.add
                                        : Icons.label_outline,
                                    color: Colors.grey.shade700,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _selectedTopic ?? 'Add a topic',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
      },
    );
  }
}
