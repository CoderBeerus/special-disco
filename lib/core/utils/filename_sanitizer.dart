class FilenameSanitizer {
  static final RegExp _illegalChars = RegExp(r'[\\/:*?"<>|]');
  static final RegExp _multiSpace = RegExp(r'\s+');

  static String sanitize(String input, {String fallback = 'media_file'}) {
    final cleaned = input
        .trim()
        .replaceAll(_illegalChars, '_')
        .replaceAll(_multiSpace, ' ')
        .replaceAll('..', '_')
        .replaceAll('/', '_');

    if (cleaned.isEmpty) return fallback;
    if (cleaned.length > 120) return cleaned.substring(0, 120);
    return cleaned;
  }
}
