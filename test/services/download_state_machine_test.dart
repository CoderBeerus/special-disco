import 'package:aniweb/data/models/download_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('download state transitions preserve metadata', () {
    final base = DownloadItem(
      id: 'id-1',
      title: 'video',
      sourceUrl: 'https://example.com/video.mp4',
      filePath: '/tmp/video.mp4',
      status: DownloadStatus.queued,
      createdAt: DateTime(2026),
    );

    final running = base.copyWith(status: DownloadStatus.downloading, progress: 0.5);
    final done = running.copyWith(status: DownloadStatus.completed, progress: 1);

    expect(done.status, DownloadStatus.completed);
    expect(done.progress, 1);
    expect(done.title, 'video');
  });
}
