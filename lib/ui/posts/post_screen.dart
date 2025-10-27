import 'package:flutter/material.dart';
import 'package:ct312h_project/services/user_service.dart';
import 'package:ct312h_project/models/user.dart';
import 'package:go_router/go_router.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String? _selectedTopic;
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _topicInputController = TextEditingController();
  final UserRepository _userRepository = UserRepository();

  Future<User?> _fetchCurrentUser() => _userRepository.fetchCurrentUser();

  @override
  void initState() {
    super.initState();
    _topicInputController.addListener(() {
      final txt = _topicInputController.text.trim();
      if (txt.isEmpty && _selectedTopic != null) {
        setState(() => _selectedTopic = null);
      } else if (txt.isNotEmpty && _selectedTopic != txt) {
        setState(() => _selectedTopic = txt);
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _topicInputController.dispose();
    super.dispose();
  }

  void _onPost(User user) {
    final content = _contentController.text.trim();
    final topicText = _topicInputController.text.trim();
    final topic = topicText.isNotEmpty ? topicText : null;

    debugPrint('Post by ${user.username}: $content (${topic ?? "no topic"})');

    // Clear và quay về trang trước
    _contentController.clear();
    _topicInputController.clear();
    setState(() => _selectedTopic = null);

    // Có thể thêm snackbar thông báo
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post created successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<User?>(
          future: _fetchCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(child: Text("User not found"));
            }

            final user = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Header (Cancel | Title | Post)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => context.go('/home/feed'),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        'New post',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _onPost(user),
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

                  const Divider(thickness: 1, color: Colors.grey),

                  const SizedBox(height: 12),

                  // Body: avatar, username, topic input, content input
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      CircleAvatar(
                        foregroundImage: AssetImage(user.avatarUrl),
                        radius: 25,
                      ),
                      const SizedBox(width: 14),

                      // Main column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  user.username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),

                                // Topic input
                                Expanded(
                                  child: TextField(
                                    controller: _topicInputController,
                                    style: TextStyle(
                                      color:
                                          _topicInputController.text
                                              .trim()
                                              .isNotEmpty
                                          ? Colors.black87
                                          : Colors.grey.shade700,
                                      fontWeight:
                                          _topicInputController.text
                                              .trim()
                                              .isNotEmpty
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                      hintText: 'Enter a topic',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    textInputAction: TextInputAction.done,
                                    cursorColor: Colors.grey,
                                    onSubmitted: (_) =>
                                        FocusScope.of(context).unfocus(),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Main post content input
                            TextFormField(
                              controller: _contentController,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                hintText: 'What\'s new?',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                              ),
                              maxLines: null,
                              autofocus: true,
                            ),

                            const SizedBox(height: 10),

                            // Topic preview chip
                            if (_selectedTopic != null &&
                                _selectedTopic!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.label, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      _selectedTopic!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
