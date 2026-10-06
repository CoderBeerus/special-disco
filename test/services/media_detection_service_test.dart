import 'package:aniweb/data/models/media_source.dart';
import 'package:aniweb/services/media_detection/media_detection_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MediaDetectionService', () {
    final service = MediaDetectionService();

    test('detects mp4', () {
      final media = service.detect(
        resourceUrl: 'https://cdn.example.com/video.mp4',
        pageUrl: 'https://example.com/watch',
        title: 'Sample',
      );
      expect(media, isNotNull);
      expect(media!.mediaType, MediaType.mp4);
    });

    test('returns null for non-media url', () {
      final media = service.detect(
        resourceUrl: 'https://example.com/script.js',
        pageUrl: 'https://example.com',
        title: 'Sample',
      );
      expect(media, isNull);
    });
  });
}
