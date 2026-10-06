import 'package:aniweb/core/utils/filename_sanitizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FilenameSanitizer', () {
    test('strips illegal path characters', () {
      final out = FilenameSanitizer.sanitize('../te:st?.mp4');
      expect(out.contains('/'), isFalse);
      expect(out.contains('..'), isFalse);
      expect(out.contains(':'), isFalse);
    });

    test('returns fallback for blank value', () {
      expect(FilenameSanitizer.sanitize('   '), 'media_file');
    });
  });
}
