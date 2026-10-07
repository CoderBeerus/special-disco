import 'package:aniweb/data/database/local_database.dart';
import 'package:aniweb/data/models/browser_history.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class HistoryRepository {
  HistoryRepository(this._database);
  final LocalDatabase _database;

  Future<void> addHistory(String url, String title, {String? favicon}) async {
    final db = await _database.database;
    final item = BrowserHistory(
      id: const Uuid().v4(),
      url: url,
      title: title,
      favicon: favicon,
      timestamp: DateTime.now(),
    );
    await db.insert(
      'browser_history',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BrowserHistory>> getAllHistory() async {
    final db = await _database.database;
    final results = await db.query('browser_history', orderBy: 'timestamp DESC');
    return results.map((e) => BrowserHistory.fromMap(e)).toList();
  }

  Future<void> deleteHistory(String id) async {
    final db = await _database.database;
    await db.delete('browser_history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearHistory() async {
    final db = await _database.database;
    await db.delete('browser_history');
  }

  Future<List<BrowserHistory>> searchHistory(String query) async {
    final db = await _database.database;
    final results = await db.query(
      'browser_history',
      where: 'title LIKE ? OR url LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'timestamp DESC',
    );
    return results.map((e) => BrowserHistory.fromMap(e)).toList();
  }
}
