import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:aniweb/core/utils/filename_sanitizer.dart';
import 'package:aniweb/data/models/download_item.dart';
import 'package:aniweb/data/repositories/download_repository.dart';
import 'package:path_provider/path_provider.dart';

class DownloadManagerService {
  DownloadManagerService(this._repository) {
    _subscription = FileDownloader().updates.listen(_onDownloadUpdate);
  }

  final DownloadRepository _repository;
  final _controller = StreamController<DownloadItem>.broadcast();
  late final StreamSubscription<TaskUpdate> _subscription;

  Stream<DownloadItem> get updates => _controller.stream;

  Future<void> enqueue({
    required String url,
    required String title,
  }) async {
    final downloads = await getApplicationDocumentsDirectory();
    final fileName = '${FilenameSanitizer.sanitize(title)}.mp4';
    final task = DownloadTask(
      taskId: DateTime.now().millisecondsSinceEpoch.toString(),
      url: url,
      filename: fileName,
      baseDirectory: BaseDirectory.applicationDocuments,
      directory: downloads.path,
      updates: Updates.statusAndProgress,
    );
    await FileDownloader().enqueue(task);
    final queued = DownloadItem(
      id: task.taskId,
      title: title,
      sourceUrl: url,
      filePath: '${downloads.path}/$fileName',
      status: DownloadStatus.queued,
      createdAt: DateTime.now(),
    );
    await _repository.upsert(queued);
    _controller.add(queued);
  }

  Future<List<DownloadItem>> getSavedDownloads() => _repository.all();

  Future<void> dispose() async {
    await _subscription.cancel();
    await _controller.close();
  }

  Future<void> _onDownloadUpdate(TaskUpdate update) async {
    if (update is TaskStatusUpdate) {
      final item = DownloadItem(
        id: update.task.taskId,
        title: update.task.filename,
        sourceUrl: update.task.url,
        filePath: await update.task.filePath(),
        status: _toStatus(update.status),
        createdAt: DateTime.now(),
      );
      await _repository.upsert(item);
      _controller.add(item);
    }
    if (update is TaskProgressUpdate) {
      final item = DownloadItem(
        id: update.task.taskId,
        title: update.task.filename,
        sourceUrl: update.task.url,
        filePath: await update.task.filePath(),
        status: DownloadStatus.downloading,
        progress: update.progress.clamp(0, 1),
        downloadedBytes: (update.expectedFileSize * update.progress).round(),
        totalBytes: update.expectedFileSize.toInt(),
        createdAt: DateTime.now(),
      );
      await _repository.upsert(item);
      _controller.add(item);
    }
  }

  DownloadStatus _toStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.enqueued:
        return DownloadStatus.queued;
      case TaskStatus.running:
        return DownloadStatus.downloading;
      case TaskStatus.paused:
        return DownloadStatus.paused;
      case TaskStatus.complete:
        return DownloadStatus.completed;
      case TaskStatus.failed:
        return DownloadStatus.failed;
      case TaskStatus.canceled:
        return DownloadStatus.cancelled;
      default:
        return DownloadStatus.failed;
    }
  }
}
