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

  test('search by title, url, domain case-insensitive', () async {
    await repository.addHistory('https://dart.dev', 'Dart programming language');
    await repository.addHistory('https://flutter.dev', 'Flutter UI toolkit');

    // Title search
    final tSearch = await repository.searchHistory('PROGRAMMING');
    expect(tSearch.length, 1);
    expect(tSearch.first.title, 'Dart programming language');

    // URL/domain search
    final uSearch = await repository.searchHistory('Flutter.dev');
    expect(uSearch.length, 1);
    expect(uSearch.first.title, 'Flutter UI toolkit');

    // No result search
    final noSearch = await repository.searchHistory('nonexistent');
    expect(noSearch.isEmpty, true);

    // Empty search should return empty or all (handled by provider typically, but repo might return all depending on LIKE %%)
    final emptySearch = await repository.searchHistory('');
    expect(emptySearch.length, 2);
  });
}
