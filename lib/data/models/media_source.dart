enum MediaType { mp4, hls, dash, unknown }

class MediaSource {
  const MediaSource({
    required this.url,
    required this.pageUrl,
    required this.title,
    required this.mediaType,
    required this.detectedAt,
    this.qualityLabel,
    this.duration,
    this.headers = const {},
    this.referer,
  });

  final String url;
  final String pageUrl;
  final String title;
  final MediaType mediaType;
  final DateTime detectedAt;
  final String? qualityLabel;
  final Duration? duration;
  final Map<String, String> headers;
  final String? referer;
}
