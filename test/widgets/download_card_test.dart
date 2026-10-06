import 'package:aniweb/data/models/download_item.dart';
import 'package:aniweb/features/downloads/presentation/downloads_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('downloads screen empty state', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DownloadsScreen()),
      ),
    );
    expect(find.text('Downloads'), findsOneWidget);
  });

  test('download item status names are stable', () {
    final item = DownloadItem(
      id: '1',
      title: 'Title',
      sourceUrl: 'https://example.com',
      filePath: '/tmp/a.mp4',
      status: DownloadStatus.downloading,
      createdAt: DateTime(2026),
    );
    expect(item.status.name, 'downloading');
  });
}
