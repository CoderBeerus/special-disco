import 'package:aniweb/core/utils/url_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UrlValidator', () {
    test('accepts https/http', () {
      expect(UrlValidator.isAllowedWebUrl('https://example.com'), isTrue);
      expect(UrlValidator.isAllowedWebUrl('http://example.com'), isTrue);
    });

    test('rejects unsupported schemes', () {
      expect(UrlValidator.isAllowedWebUrl('file:///etc/passwd'), isFalse);
      expect(UrlValidator.isAllowedWebUrl('javascript:alert(1)'), isFalse);
    });
  });
}
