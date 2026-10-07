import 'package:aniweb/data/database/local_database.dart';
import 'package:aniweb/data/repositories/watch_history_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late LocalDatabase db;
  late WatchHistoryRepository watchRepo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = LocalDatabase.instanceForTest();
    watchRepo = WatchHistoryRepository(db);
    final database = await db.database;
    await database.delete('watch_history');
  });

  test('watch history records and persists', () async {
    await watchRepo.savePosition(
      title: 'Sample Video',
      url: 'https://example.com/video.mp4',
      positionMs: 1000,
      durationMs: 10000,
    );
    final all = await watchRepo.getContinueWatching();
    expect(all.length, 1);
    expect(all.first.title, 'Sample Video');
    expect(all.first.positionMs, 1000);
  });
}
