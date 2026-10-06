enum DownloadStatus { queued, downloading, paused, completed, failed, cancelled }

class DownloadItem {
  const DownloadItem({
    required this.id,
    required this.title,
    required this.sourceUrl,
    required this.filePath,
    required this.status,
    required this.createdAt,
    this.progress = 0,
    this.totalBytes,
    this.downloadedBytes = 0,
    this.speedBytesPerSecond,
    this.eta,
    this.resolution,
    this.errorMessage,
  });

  final String id;
  final String title;
  final String sourceUrl;
  final String filePath;
  final DownloadStatus status;
  final DateTime createdAt;
  final double progress;
  final int? totalBytes;
  final int downloadedBytes;
  final int? speedBytesPerSecond;
  final Duration? eta;
  final String? resolution;
  final String? errorMessage;

  DownloadItem copyWith({
    DownloadStatus? status,
    double? progress,
    int? totalBytes,
    int? downloadedBytes,
    int? speedBytesPerSecond,
    Duration? eta,
    String? errorMessage,
  }) {
    return DownloadItem(
      id: id,
      title: title,
      sourceUrl: sourceUrl,
      filePath: filePath,
      status: status ?? this.status,
      createdAt: createdAt,
      progress: progress ?? this.progress,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      speedBytesPerSecond: speedBytesPerSecond ?? this.speedBytesPerSecond,
      eta: eta ?? this.eta,
      resolution: resolution,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
