import 'dart:typed_data';

import 'package:media_kit/media_kit.dart';

class ThumbnailService {
  Future<Uint8List?> thumbnailFromFile(String path) async {
    final player = Player();
    try {
      await player.open(Media(path), play: false);
      return await player.screenshot();
    } catch (_) {
      return null;
    } finally {
      await player.dispose();
    }
  }
}
