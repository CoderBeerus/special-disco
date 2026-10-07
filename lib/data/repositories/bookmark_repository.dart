import 'package:aniweb/data/database/local_database.dart';
import 'package:aniweb/data/models/website_bookmark_group.dart';
import 'package:aniweb/data/models/page_bookmark.dart';
import 'package:uuid/uuid.dart';

class BookmarkRepository {
  BookmarkRepository(this._database);

  final LocalDatabase _database;
  final _uuid = const Uuid();

  // --------------------------------------------------------------------------
  // GROUPS
  // --------------------------------------------------------------------------

  Future<List<WebsiteBookmarkGroup>> getAllGroups() async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT g.*, COUNT(b.id) as bookmarkCount
      FROM website_bookmark_groups g
      LEFT JOIN page_bookmarks b ON g.id = b.group_id
      GROUP BY g.id
      ORDER BY g.sort_order ASC, g.website_name ASC
    ''');

    return rows.map((row) {
      return WebsiteBookmarkGroup(
        id: row['id'] as String,
        websiteName: row['website_name'] as String,
        domain: row['domain'] as String,
        favicon: row['favicon'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String),
        sortOrder: row['sort_order'] as int,
        bookmarkCount: row['bookmarkCount'] as int,
      );
    }).toList();
  }

  Future<WebsiteBookmarkGroup> createGroup(String websiteName, String domain, {String? favicon}) async {
    final db = await _database.database;
    final id = _uuid.v4();
    final now = DateTime.now();

    final maxOrderRow = await db.rawQuery('SELECT MAX(sort_order) as max_order FROM website_bookmark_groups');
    final maxOrder = (maxOrderRow.first['max_order'] as int?) ?? -1;

    final group = WebsiteBookmarkGroup(
      id: id,
      websiteName: websiteName,
      domain: domain,
      favicon: favicon,
      createdAt: now,
      sortOrder: maxOrder + 1,
    );

    await db.insert('website_bookmark_groups', {
      'id': group.id,
      'website_name': group.websiteName,
      'domain': group.domain,
      'favicon': group.favicon,
      'created_at': group.createdAt.toIso8601String(),
      'sort_order': group.sortOrder,
    });

    return group;
  }

  Future<void> updateGroup(WebsiteBookmarkGroup group) async {
    final db = await _database.database;
    await db.update(
      'website_bookmark_groups',
      {
        'website_name': group.websiteName,
        'domain': group.domain,
        'favicon': group.favicon,
      },
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<void> deleteGroup(String id) async {
    final db = await _database.database;
    await db.execute('PRAGMA foreign_keys = ON'); // Ensure cascade delete works
    await db.delete(
      'website_bookmark_groups',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> reorderGroups(List<String> orderedIds) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      for (int i = 0; i < orderedIds.length; i++) {
        await txn.update(
          'website_bookmark_groups',
          {'sort_order': i},
          where: 'id = ?',
          whereArgs: [orderedIds[i]],
        );
      }
    });
  }

  // --------------------------------------------------------------------------
  // BOOKMARKS
  // --------------------------------------------------------------------------

  Future<List<PageBookmark>> getBookmarksForGroup(String groupId) async {
    final db = await _database.database;
    final rows = await db.query(
      'page_bookmarks',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'sort_order ASC, date_added DESC',
    );
    return rows.map((row) => _bookmarkFromMap(row)).toList();
  }

  /// Adds a bookmark, automatically creating a group if it doesn't exist based on the domain.
  Future<PageBookmark> addBookmarkWithAutoGroup({
    required String title,
    required String url,
    required String domain,
    String? favicon,
    String? thumbnail,
  }) async {
    final db = await _database.database;

    // Check if bookmark exists
    final existingBookmark = await db.query('page_bookmarks', where: 'url = ?', whereArgs: [url]);
    if (existingBookmark.isNotEmpty) {
      throw Exception('Bookmark for this URL already exists');
    }

    // Check if group exists for domain
    final existingGroups = await db.query('website_bookmark_groups', where: 'domain = ?', whereArgs: [domain]);
    String groupId;

    if (existingGroups.isNotEmpty) {
      groupId = existingGroups.first['id'] as String;
    } else {
      // Auto create group
      final group = await createGroup(domain, domain, favicon: favicon);
      groupId = group.id;
    }

    final id = _uuid.v4();
    final maxOrderRow = await db.rawQuery('SELECT MAX(sort_order) as max_order FROM page_bookmarks WHERE group_id = ?', [groupId]);
    final maxOrder = (maxOrderRow.first['max_order'] as int?) ?? -1;

    final bookmark = PageBookmark(
      id: id,
      groupId: groupId,
      title: title,
      url: url,
      domain: domain,
      favicon: favicon,
      thumbnail: thumbnail,
      dateAdded: DateTime.now(),
      sortOrder: maxOrder + 1,
    );

    await db.insert('page_bookmarks', _bookmarkToMap(bookmark));
    return bookmark;
  }

  Future<void> updateBookmark(PageBookmark bookmark) async {
    final db = await _database.database;
    await db.update(
      'page_bookmarks',
      _bookmarkToMap(bookmark),
      where: 'id = ?',
      whereArgs: [bookmark.id],
    );
  }

  Future<void> deleteBookmark(String id) async {
    final db = await _database.database;
    await db.delete(
      'page_bookmarks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> reorderBookmarks(List<String> orderedIds) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      for (int i = 0; i < orderedIds.length; i++) {
        await txn.update(
          'page_bookmarks',
          {'sort_order': i},
          where: 'id = ?',
          whereArgs: [orderedIds[i]],
        );
      }
    });
  }

  Future<void> moveBookmark(String bookmarkId, String newGroupId) async {
    final db = await _database.database;
    final maxOrderRow = await db.rawQuery('SELECT MAX(sort_order) as max_order FROM page_bookmarks WHERE group_id = ?', [newGroupId]);
    final maxOrder = (maxOrderRow.first['max_order'] as int?) ?? -1;

    await db.update(
      'page_bookmarks',
      {'group_id': newGroupId, 'sort_order': maxOrder + 1},
      where: 'id = ?',
      whereArgs: [bookmarkId],
    );
  }

  Future<PageBookmark?> getBookmarkByUrl(String url) async {
    final db = await _database.database;
    final rows = await db.query('page_bookmarks', where: 'url = ?', whereArgs: [url]);
    if (rows.isNotEmpty) {
      return _bookmarkFromMap(rows.first);
    }
    return null;
  }

  Future<List<PageBookmark>> searchBookmarks(String query) async {
    if (query.trim().isEmpty) return [];

    final db = await _database.database;
    final likeQuery = '%${query.trim()}%';
    final rows = await db.query(
      'page_bookmarks',
      where: 'title LIKE ? OR custom_title LIKE ? OR url LIKE ? OR domain LIKE ? OR notes LIKE ?',
      whereArgs: [likeQuery, likeQuery, likeQuery, likeQuery, likeQuery],
      orderBy: 'sort_order ASC, date_added DESC',
    );
    return rows.map((row) => _bookmarkFromMap(row)).toList();
  }

  PageBookmark _bookmarkFromMap(Map<String, Object?> map) {
    return PageBookmark(
      id: map['id'] as String,
      groupId: map['group_id'] as String,
      title: map['title'] as String,
      url: map['url'] as String,
      domain: map['domain'] as String,
      favicon: map['favicon'] as String?,
      thumbnail: map['thumbnail'] as String?,
      dateAdded: DateTime.parse(map['date_added'] as String),
      lastVisited: map['last_visited'] != null ? DateTime.parse(map['last_visited'] as String) : null,
      customTitle: map['custom_title'] as String?,
      notes: map['notes'] as String?,
      sortOrder: map['sort_order'] as int,
    );
  }

  Map<String, Object?> _bookmarkToMap(PageBookmark b) {
    return {
      'id': b.id,
      'group_id': b.groupId,
      'title': b.title,
      'url': b.url,
      'domain': b.domain,
      'favicon': b.favicon,
      'thumbnail': b.thumbnail,
      'date_added': b.dateAdded.toIso8601String(),
      'last_visited': b.lastVisited?.toIso8601String(),
      'custom_title': b.customTitle,
      'notes': b.notes,
      'sort_order': b.sortOrder,
    };
  }
}
