import 'package:aniweb/data/database/local_database.dart';
import 'package:aniweb/data/repositories/history_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late HistoryRepository repository;
  late LocalDatabase database;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = LocalDatabase.instanceForTest();
    final db = await database.database;
    await db.delete('browser_history');
    repository = HistoryRepository(database);
  });

  tearDownAll(() async {
    final db = await database.database;
    await db.close();
  });

  test('add, search, and delete history', () async {
    await repository.addHistory('https://example.com', 'Example Site');

    final all = await repository.getAllHistory();
    expect(all.length, greaterThanOrEqualTo(1));
    final item = all.firstWhere((e) => e.url == 'https://example.com');
    expect(item.title, 'Example Site');

    final search = await repository.searchHistory('Example');
    expect(search.isNotEmpty, true);
    expect(search.first.url, 'https://example.com');

    await repository.deleteHistory(item.id);
    final afterDelete = await repository.getAllHistory();
    expect(afterDelete.any((e) => e.url == 'https://example.com'), false);
  });

  test('clear all history', () async {
    await repository.addHistory('https://example1.com', 'Example 1');
    await repository.addHistory('https://example2.com', 'Example 2');

    await repository.clearHistory();

    final all = await repository.getAllHistory();
    expect(all.isEmpty, true);
  });
}
