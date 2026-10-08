import 'package:aniweb/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BrowserHistoryScreen extends ConsumerStatefulWidget {
  const BrowserHistoryScreen({super.key});

  @override
  ConsumerState<BrowserHistoryScreen> createState() => _BrowserHistoryScreenState();
}

class _BrowserHistoryScreenState extends ConsumerState<BrowserHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Refresh history when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ref.read(historyProvider.notifier).refresh();
    } else {
      ref.read(historyProvider.notifier).searchHistory(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);
    final isSearching = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _confirmClearHistory(context, ref),
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search history...',
              leading: const Icon(Icons.search),
              trailing: [
                if (isSearching)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: historyState.when(
              data: (history) {
                if (history.isEmpty) {
                  return Center(
                    child: Text(isSearching ? 'No results found' : 'No history yet'),
                  );
                }
                return ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return ListTile(
                      leading: item.favicon != null
                          ? Image.network(
                              item.favicon!,
                              width: 24,
                              height: 24,
                              errorBuilder: (_, __, ___) => const Icon(Icons.history),
                            )
                          : const Icon(Icons.history),
                      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(item.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          ref.read(historyProvider.notifier).deleteHistory(item.id);
                        },
                      ),
                      onTap: () {
                        // Navigate back to browser and open the URL
                        context.pop();
                        // Assuming the browser is the active screen under history, pushing the url query parameter
                        // Because history is a sub-route of /browser, popping goes back, then we navigate again.
                        context.go('/browser?url=${Uri.encodeComponent(item.url)}');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Browsing History?'),
        content: const Text('Are you sure you want to delete all browsing history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(historyProvider.notifier).clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
