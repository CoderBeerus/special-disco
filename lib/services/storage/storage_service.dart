import 'dart:io';

import 'package:path_provider/path_provider.dart';

class StorageService {
  Future<Directory> appMediaDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final media = Directory('${dir.path}/media');
    if (!await media.exists()) {
      await media.create(recursive: true);
    }
    return media;
  }

  Future<int> computeDirectoryBytes(Directory directory) async {
    var size = 0;
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        size += await entity.length();
      }
    }
    return size;
  }
}
