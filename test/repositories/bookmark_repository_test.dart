import 'package:aniweb/data/database/local_database.dart';
import 'package:aniweb/data/repositories/bookmark_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LocalDatabase db;
  late BookmarkRepository repo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = LocalDatabase.instanceForTest();
    final database = await db.database;
    await database.delete('page_bookmarks');
    await database.delete('website_bookmark_groups');
    repo = BookmarkRepository(db);
  });

  test('auto create group and add bookmark', () async {
    final b1 = await repo.addBookmarkWithAutoGroup(
      title: 'Test Page',
      url: 'https://example.com/page',
      domain: 'example.com',
    );
    expect(b1.title, 'Test Page');
    expect(b1.domain, 'example.com');

    final groups = await repo.getAllGroups();
    expect(groups.length, 1);
    expect(groups.first.domain, 'example.com');
    expect(groups.first.bookmarkCount, 1);

    final bookmarks = await repo.getBookmarksForGroup(groups.first.id);
    expect(bookmarks.length, 1);
    expect(bookmarks.first.id, b1.id);
  });

  test('prevent duplicate bookmark', () async {
    await repo.addBookmarkWithAutoGroup(
      title: 'Page 1',
      url: 'https://example.com/page',
      domain: 'example.com',
    );

    expect(
      () => repo.addBookmarkWithAutoGroup(
        title: 'Page 2',
        url: 'https://example.com/page',
        domain: 'example.com',
      ),
      throwsException,
    );
  });

  test('cascade delete group', () async {
    await repo.addBookmarkWithAutoGroup(
      title: 'P1',
      url: 'https://a.com/1',
      domain: 'a.com',
    );
    final groups = await repo.getAllGroups();
    expect(groups.length, 1);

    await repo.deleteGroup(groups.first.id);

    final groupsAfter = await repo.getAllGroups();
    expect(groupsAfter.length, 0);

    final dbInstance = await db.database;
    final bookmarksAfter = await dbInstance.query('page_bookmarks');
    expect(bookmarksAfter.length, 0, reason: 'Bookmarks should be cascade deleted');
  });

  group('searchBookmarks', () {
    setUp(() async {
      final database = await db.database;
      await database.delete('page_bookmarks');
      await database.delete('website_bookmark_groups');

      await repo.addBookmarkWithAutoGroup(
        title: 'Flutter Dev',
        url: 'https://flutter.dev/docs',
        domain: 'flutter.dev',
      );
      final b2 = await repo.addBookmarkWithAutoGroup(
        title: 'Dart Dev',
        url: 'https://dart.dev',
        domain: 'dart.dev',
      );
      // Update b2 with custom title and notes
      final updatedB2 = b2.copyWith(customTitle: 'Dart Lang', notes: 'Important info here');
      await repo.updateBookmark(updatedB2);
    });

    test('match title', () async {
      final results = await repo.searchBookmarks('Flutter');
      expect(results.length, 1);
      expect(results.first.title, 'Flutter Dev');
    });

    test('match custom title', () async {
      final results = await repo.searchBookmarks('Lang');
      expect(results.length, 1);
      expect(results.first.customTitle, 'Dart Lang');
    });

    test('match url', () async {
      final results = await repo.searchBookmarks('flutter.dev/docs');
      expect(results.length, 1);
      expect(results.first.url, 'https://flutter.dev/docs');
    });

    test('match domain', () async {
      final results = await repo.searchBookmarks('dart.dev');
      expect(results.length, 1);
      expect(results.first.domain, 'dart.dev');
    });

    test('match notes', () async {
      final results = await repo.searchBookmarks('Important');
      expect(results.length, 1);
      expect(results.first.notes, 'Important info here');
    });

    test('case-insensitive search', () async {
      final results = await repo.searchBookmarks('fLuTtEr');
      expect(results.length, 1);
      expect(results.first.title, 'Flutter Dev');
    });

    test('no-result search or empty query', () async {
      final emptyResults = await repo.searchBookmarks('');
      expect(emptyResults.isEmpty, true);
      final noResults = await repo.searchBookmarks('nonexistent');
      expect(noResults.isEmpty, true);
    });
  });
}
