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
    // TODO: implement initState
    super.initState();
    searchController = SearchController();

    Future.microtask(() {
      final vm = context.read<SearchManager>();
      vm.init();
    });

    if (widget.keyword != null && widget.keyword!.isNotEmpty) {
      searchController.text = widget.keyword!;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    final newKeyword = widget.keyword;
    if (newKeyword != null &&
        newKeyword.isNotEmpty &&
        newKeyword != oldWidget.keyword) {
      searchController.text = newKeyword;
      context.read<SearchManager>().search(newKeyword);
    }
  }

  void _submitSearch(String query) {
    final vm = context.read<SearchManager>(); // Dùng context.read để lấy vm
    vm.search(query);
    searchController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchManager>();

    if (vm.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null) {
      return Center(child: Text('Error: ${vm.errorMessage}'));
    }

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

              SearchAnchor(
                searchController: searchController,

                builder: (context, controller) {
                  return Focus(
                    autofocus: true,
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.enter) {
                        _submitSearch(searchController.text);
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: SearchBar(
                      controller: controller,
                      hintText: 'Search',
                      onChanged: (_) {}, // TODO: xem lại
                      onSubmitted: (query) {
                        _submitSearch(query);
                      },
                      onTap: controller.openView,
                      textInputAction: TextInputAction.search,
                      trailing: [
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _submitSearch(searchController.text);
                          },
                        ),
                      ],
                    ),
                  );
                },

                suggestionsBuilder: (context, controller) {
                  final query = controller.text.toLowerCase();
                  final results = vm.topicSuggestions
                      .where((item) => item.name.toLowerCase().contains(query))
                      .toList();

                  return results.map((item) {
                    return ListTile(
                      trailing: Icon(Icons.trending_up),
                      title: Text(item.name),
                      onTap: () {
                        Future.microtask(() {
                          controller.closeView(item.name);
                        });
                        // WidgetsBinding.instance.addPostFrameCallback((_) {
                        //   controller.closeView(item.name);
                        // });
                      },
                    );
                  }).toList();
                },
              ),
              SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: vm.searchResults.length,
                  itemBuilder: (context, index) {
                    return SinglePostItem(post: vm.searchResults[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
