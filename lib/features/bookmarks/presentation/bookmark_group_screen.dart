import 'package:aniweb/data/models/page_bookmark.dart';
import 'package:aniweb/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BookmarkGroupScreen extends ConsumerWidget {
  const BookmarkGroupScreen({
    required this.groupId,
    required this.groupName,
    super.key,
  });

  final String groupId;
  final String groupName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksState = ref.watch(bookmarksForGroupProvider(groupId));

    return Scaffold(
      appBar: AppBar(title: Text(groupName)),
      body: bookmarksState.when(
        data: (bookmarks) {
          if (bookmarks.isEmpty) {
            return const Center(child: Text('No pages in this group'));
          }
          return ReorderableListView.builder(
            itemCount: bookmarks.length,
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) newIndex -= 1;
              final list = List<PageBookmark>.from(bookmarks);
              final item = list.removeAt(oldIndex);
              list.insert(newIndex, item);

              // Optimistic/Immediate update strategy would require a more complex provider for the list,
              // but for now we just call the repo and invalidate.
              final repo = ref.read(bookmarkRepositoryProvider);
              repo.reorderBookmarks(list.map((e) => e.id).toList()).then((_) {
                 ref.invalidate(bookmarksForGroupProvider(groupId));
              });
            },
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];
              return ListTile(
                key: ValueKey(bookmark.id),
                leading: const Icon(Icons.bookmark),
                title: Text(bookmark.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(bookmark.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                     final repo = ref.read(bookmarkRepositoryProvider);
                     repo.deleteBookmark(bookmark.id).then((_) {
                       ref.invalidate(bookmarksForGroupProvider(groupId));
                       ref.read(bookmarkGroupsProvider.notifier).refresh();
                     });
                  },
                ),
                onTap: () {
                  context.go('/browser?url=${Uri.encodeComponent(bookmark.url)}');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
