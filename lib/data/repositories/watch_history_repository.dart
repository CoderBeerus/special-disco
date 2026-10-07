import 'package:aniweb/data/database/local_database.dart';
import 'package:aniweb/data/models/watch_history.dart';
import 'package:uuid/uuid.dart';

class WatchHistoryRepository {
  WatchHistoryRepository(this._database);
  final LocalDatabase _database;

  Future<void> savePosition({
    required String title,
    required String url,
    required int positionMs,
    required int durationMs,
    String? thumbnail,
  }) async {
    final db = await _database.database;

    // Check if it exists
    final existing = await db.query('watch_history', where: 'url = ?', whereArgs: [url]);

    final isCompleted = positionMs >= durationMs * 0.95 && durationMs > 0;

    if (existing.isNotEmpty) {
      await db.update(
        'watch_history',
        {
          'position_ms': positionMs,
          'duration_ms': durationMs,
          'last_played': DateTime.now().toIso8601String(),
          'is_completed': isCompleted ? 1 : 0,
        },
        where: 'url = ?',
        whereArgs: [url],
      );
    } else {
      final item = WatchHistory(
        id: const Uuid().v4(),
        title: title,
        url: url,
        thumbnail: thumbnail,
        positionMs: positionMs,
        durationMs: durationMs,
        lastPlayed: DateTime.now(),
        isCompleted: isCompleted,
      );
      await db.insert('watch_history', item.toMap());
    }
  }

  Future<List<WatchHistory>> getContinueWatching() async {
    final db = await _database.database;
    final results = await db.query(
      'watch_history',
      where: 'is_completed = 0 AND position_ms > 0',
      orderBy: 'last_played DESC',
      limit: 10,
    );
    return results.map((e) => WatchHistory.fromMap(e)).toList();
  }

  Future<void> clearHistory() async {
    final db = await _database.database;
    await db.delete('watch_history');
  }

  Future<void> deleteHistory(String id) async {
    final db = await _database.database;
    await db.delete('watch_history', where: 'id = ?', whereArgs: [id]);
  }
}
