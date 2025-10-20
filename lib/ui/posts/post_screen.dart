import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:ct312h_project/repository/user_repository.dart';
import 'package:ct312h_project/models/user.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key, required this.panelController});
  final PanelController panelController;

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
    // keep topic state in sync while typing
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
    // TODO: Add logic to send the post to the server (include topic if any)
    debugPrint('Post by ${user.username}: $content (${topic ?? "no topic"})');

    // Optional: clear inputs after posting
    // setState(() {
    //   _contentController.clear();
    //   _topicInputController.clear();
    //   _selectedTopic = null;
    // });
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
          return const Center(child: Text("User not found"));
        }

        final user = snapshot.data!;

        // If _selectedTopic was set externally, prefill controller
        if (_selectedTopic != null &&
            _topicInputController.text.trim() != _selectedTopic) {
          _topicInputController.text = _selectedTopic!;
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Header (Cancel | Title | Post)
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
              ),

              const Divider(thickness: 1, color: Colors.grey),

              // Body: avatar, username, topic input, content input
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
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
                          // Row: username + inline topic input (Threads-like)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Username
                              Text(
                                user.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Small chevron / visual separator (like Threads)
                              const Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: Colors.grey,
                              ),

                              const SizedBox(width: 4),

                              // Topic input area: flexible, no border, placeholder grey
                              Expanded(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 36,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
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
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Main post content input (multi-line)
                          TextFormField(
                            controller: _contentController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: 'Whats new',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                          ),

                          const SizedBox(height: 10),

                          // If a topic exists, show a subtle chip-like preview under the content
                          if (_selectedTopic != null &&
                              _selectedTopic!.isNotEmpty) ...[
                            Row(
                              children: [
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
                            const SizedBox(height: 8),
                          ],
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
