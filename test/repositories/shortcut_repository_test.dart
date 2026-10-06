import 'package:aniweb/data/database/local_database.dart';
import 'package:aniweb/data/repositories/shortcut_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LocalDatabase db;
  late ShortcutRepository repo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = LocalDatabase.instanceForTest();
    // In-memory db can't easily reset singleton without reflection,
    // but we can just clear the tables.
    final database = await db.database;
    await database.delete('website_shortcuts');
    repo = ShortcutRepository(db);
  });

  test('add, get, and update shortcut', () async {
    final s1 = await repo.addShortcut(name: 'Google', url: 'https://google.com');
    expect(s1.name, 'Google');
    expect(s1.url, 'https://google.com');

    final all = await repo.getAll();
    expect(all.length, 1);
    expect(all.first.id, s1.id);

    final updated = s1.copyWith(name: 'Google 2');
    await repo.updateShortcut(updated);

    final allUpdated = await repo.getAll();
    expect(allUpdated.first.name, 'Google 2');
  });

  test('delete shortcut', () async {
    final s1 = await repo.addShortcut(name: 'Google', url: 'https://google.com');
    await repo.deleteShortcut(s1.id);
    final all = await repo.getAll();
    expect(all, isEmpty);
  });

  test('reorder shortcuts', () async {
    final s1 = await repo.addShortcut(name: '1', url: 'http://1.com');
    final s2 = await repo.addShortcut(name: '2', url: 'http://2.com');
    final s3 = await repo.addShortcut(name: '3', url: 'http://3.com');

    // Reverse order
    await repo.reorderShortcuts([s3.id, s2.id, s1.id]);
    final all = await repo.getAll();
    expect(all[0].id, s3.id);
    expect(all[1].id, s2.id);
    expect(all[2].id, s1.id);
  });
}
