import 'package:aniweb/data/models/website_bookmark_group.dart';
import 'package:aniweb/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(bookmarkSearchQueryProvider);
    final isSearching = searchQuery.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              hintText: 'Search bookmarks...',
              leading: const Icon(Icons.search),
              trailing: [
                if (isSearching)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      ref.read(bookmarkSearchQueryProvider.notifier).state = '';
                    },
                  ),
              ],
              onChanged: (value) {
                ref.read(bookmarkSearchQueryProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: isSearching ? _buildSearchResults(ref) : _buildGroupList(ref),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(WidgetRef ref) {
    final searchState = ref.watch(bookmarkSearchProvider);

    return searchState.when(
      data: (bookmarks) {
        if (bookmarks.isEmpty) {
          return const Center(child: Text('No results found'));
        }
        return ListView.builder(
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = bookmarks[index];
            return ListTile(
              leading: const Icon(Icons.bookmark), // Or use favicon if available
              title: Text(bookmark.customTitle ?? bookmark.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(bookmark.url, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () {
                context.go('/browser?url=${Uri.encodeComponent(bookmark.url)}');
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildGroupList(WidgetRef ref) {
    final groupsState = ref.watch(bookmarkGroupsProvider);

    return groupsState.when(
      data: (groups) {
        if (groups.isEmpty) {
          return const Center(child: Text('No bookmarks yet'));
        }
        return ReorderableListView.builder(
          itemCount: groups.length,
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) newIndex -= 1;
            final list = List<WebsiteBookmarkGroup>.from(groups);
            final item = list.removeAt(oldIndex);
            list.insert(newIndex, item);
            ref.read(bookmarkGroupsProvider.notifier).reorderGroups(list.map((e) => e.id).toList());
          },
          itemBuilder: (context, index) {
            final group = groups[index];
            return ListTile(
              key: ValueKey(group.id),
              leading: const Icon(Icons.folder),
              title: Text(group.websiteName),
              subtitle: Text(group.domain),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${group.bookmarkCount} pages'),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, ref, group),
                  ),
                ],
              ),
              onTap: () {
                context.push('/bookmarks/group/${group.id}', extra: group.websiteName);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, WebsiteBookmarkGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bookmark Group?'),
        content: Text('Are you sure you want to delete "${group.websiteName}" and all its bookmarks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(bookmarkGroupsProvider.notifier).deleteGroup(group.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
