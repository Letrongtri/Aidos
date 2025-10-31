import 'package:ct312h_project/ui/posts/single_post_item.dart';
import 'package:ct312h_project/viewmodels/search_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.keyword});
  final String? keyword;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchController searchController;

  @override
  void initState() {
    super.initState();
    searchController = SearchController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<SearchManager>();
      vm.fetchSuggestionTopics();
      vm.search('');
    });

    if (widget.keyword != null && widget.keyword!.isNotEmpty) {
      searchController.text = widget.keyword!;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newKeyword = widget.keyword;
    if (newKeyword != null &&
        newKeyword.isNotEmpty &&
        newKeyword != oldWidget.keyword) {
      searchController.text = newKeyword;
      if (mounted) {
        context.read<SearchManager>().search(newKeyword);
      }
    }
  }

  void _submitSearch(String query) {
    final vm = context.read<SearchManager>();
    vm.search(query);
    searchController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final searchManager = context.watch<SearchManager>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                'Search',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),

              _buildSearchBar(searchManager),

              SizedBox(height: 12),
              Expanded(
                child: searchManager.postCount == 0
                    ? Center(child: Text('Không tìm thấy bài viết'))
                    : ListView.builder(
                        itemCount: searchManager.postCount,
                        itemBuilder: (context, index) {
                          return SinglePostItem(
                            post: searchManager.posts[index],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SearchAnchor _buildSearchBar(SearchManager searchManager) {
    return SearchAnchor(
      searchController: searchController,

      builder: (context, controller) {
        return Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.enter) {
              controller.text = searchController.text;
              controller.closeView(searchController.text);
              _submitSearch(searchController.text);
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: SearchBar(
            controller: controller,
            hintText: 'Search',
            onSubmitted: (query) {
              controller.text = query;
              controller.closeView(query);
              _submitSearch(query);
            },
            onTap: controller.openView,
            textInputAction: TextInputAction.search,
            trailing: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  controller.text = searchController.text;
                  controller.closeView(searchController.text);
                  _submitSearch(searchController.text);
                },
              ),
            ],
          ),
        );
      },

      suggestionsBuilder: (context, controller) async {
        final query = controller.text.toLowerCase();
        final results = searchManager.topic
            .where((item) => item.name.toLowerCase().contains(query))
            .toList();

        return results.map((item) {
          return ListTile(
            trailing: Icon(Icons.trending_up),
            title: Text(item.name),
            onTap: () {
              Future.microtask(() {
                controller.text = item.name;
                controller.closeView(item.name);
                _submitSearch(item.name);
              });
            },
          );
        }).toList();
      },
    );
  }
}
