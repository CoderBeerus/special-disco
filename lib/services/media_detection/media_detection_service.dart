import 'package:aniweb/data/models/media_source.dart';

class MediaDetectionService {
  static const List<String> _extensions = ['.mp4', '.m3u8', '.mpd'];

  MediaSource? detect({
    required String resourceUrl,
    required String pageUrl,
    required String title,
    Map<String, String> headers = const {},
  }) {
    final lower = resourceUrl.toLowerCase();
    final matched = _extensions.where(lower.endsWith).toList();
    if (matched.isEmpty) return null;
    return MediaSource(
      url: resourceUrl,
      pageUrl: pageUrl,
      title: title,
      detectedAt: DateTime.now(),
      headers: headers,
      mediaType: _toType(matched.first),
    );
  }

  MediaType _toType(String ext) {
    switch (ext) {
      case '.mp4':
        return MediaType.mp4;
      case '.m3u8':
        return MediaType.hls;
      case '.mpd':
        return MediaType.dash;
      default:
        return MediaType.unknown;
    }
  }
}
