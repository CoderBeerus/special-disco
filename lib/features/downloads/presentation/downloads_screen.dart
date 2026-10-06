import 'package:aniweb/core/extensions/duration_extensions.dart';
import 'package:aniweb/data/models/download_item.dart';
import 'package:aniweb/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: downloads.isEmpty
          ? const Center(child: Text('No downloads yet'))
          : ListView.builder(
              itemCount: downloads.length,
              itemBuilder: (context, index) => _DownloadCard(item: downloads[index]),
            ),
    );
  }
}

class _DownloadCard extends StatelessWidget {
  const _DownloadCard({required this.item});

  final DownloadItem item;

  @override
  Widget build(BuildContext context) {
    final pct = (item.progress * 100).toStringAsFixed(0);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: item.progress),
            const SizedBox(height: 8),
            Text('Status: ${item.status.name} • $pct%'),
            if (item.eta != null) Text('ETA: ${item.eta!.toPlayerLabel()}'),
          ],
        ),
      ),
    );
  }
}
