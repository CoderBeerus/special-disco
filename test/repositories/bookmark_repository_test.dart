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
}
