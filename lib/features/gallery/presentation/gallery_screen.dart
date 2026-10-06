import 'package:aniweb/data/models/download_item.dart';
import 'package:aniweb/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadsProvider);
    final completedDownloads = downloads.where((item) => item.status == DownloadStatus.completed).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: completedDownloads.isEmpty
          ? const Center(
              child: Text(
                'No media downloaded yet',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: completedDownloads.length,
              itemBuilder: (context, index) {
                final item = completedDownloads[index];
                return _GalleryItemCard(item: item);
              },
            ),
    );
  }
}

class _GalleryItemCard extends StatelessWidget {
  const _GalleryItemCard({required this.item});

  final DownloadItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/offline-player', extra: item.filePath);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.black12,
                child: const Icon(Icons.video_file, size: 48, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
