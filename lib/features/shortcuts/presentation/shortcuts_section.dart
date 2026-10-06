import 'package:aniweb/data/models/website_shortcut.dart';
import 'package:aniweb/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShortcutsSection extends ConsumerWidget {
  const ShortcutsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortcutsState = ref.watch(shortcutsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Website Shortcuts',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddDialog(context, ref),
              ),
            ],
          ),
        ),
        shortcutsState.when(
          data: (shortcuts) {
            if (shortcuts.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No shortcuts added yet.'),
              );
            }
            return SizedBox(
              height: 100,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: shortcuts.length,
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) newIndex -= 1;
                  final list = List<WebsiteShortcut>.from(shortcuts);
                  final item = list.removeAt(oldIndex);
                  list.insert(newIndex, item);
                  ref.read(shortcutsProvider.notifier).reorderShortcuts(list.map((e) => e.id).toList());
                },
                itemBuilder: (context, index) {
                  final shortcut = shortcuts[index];
                  return _ShortcutCard(
                    key: ValueKey(shortcut.id),
                    shortcut: shortcut,
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final urlController = TextEditingController(text: 'https://');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Shortcut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL'),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final url = urlController.text.trim();
              if (name.isNotEmpty && url.isNotEmpty) {
                ref.read(shortcutsProvider.notifier).addShortcut(name, url);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends ConsumerWidget {
  const _ShortcutCard({required super.key, required this.shortcut});

  final WebsiteShortcut shortcut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
           // Navigate to browser tab and load URL
           context.go('/browser?url=${Uri.encodeComponent(shortcut.url)}');
        },
        onLongPress: () => _showEditDialog(context, ref),
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.language, size: 32),
              const SizedBox(height: 8),
              Text(
                shortcut.name,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(text: shortcut.name);
    final urlController = TextEditingController(text: shortcut.url);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Shortcut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL'),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
               ref.read(shortcutsProvider.notifier).deleteShortcut(shortcut.id);
               Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final url = urlController.text.trim();
              if (name.isNotEmpty && url.isNotEmpty) {
                ref.read(shortcutsProvider.notifier).updateShortcut(
                  shortcut.copyWith(name: name, url: url),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
