import 'package:aniweb/data/database/local_database.dart';
import 'package:aniweb/data/models/website_shortcut.dart';
import 'package:uuid/uuid.dart';

class ShortcutRepository {
  ShortcutRepository(this._database);

  final LocalDatabase _database;
  final _uuid = const Uuid();

  Future<List<WebsiteShortcut>> getAll() async {
    final db = await _database.database;
    final rows = await db.query(
      'website_shortcuts',
      orderBy: 'sort_order ASC, created_at DESC',
    );
    return rows.map((row) => _fromMap(row)).toList();
  }

  Future<WebsiteShortcut> addShortcut({
    required String name,
    required String url,
    String? faviconUrl,
    String? category,
    bool isPinned = false,
  }) async {
    final db = await _database.database;
    final id = _uuid.v4();
    final now = DateTime.now();

    // Get max sort_order
    final maxOrderRow = await db.rawQuery('SELECT MAX(sort_order) as max_order FROM website_shortcuts');
    final maxOrder = (maxOrderRow.first['max_order'] as int?) ?? -1;

    final shortcut = WebsiteShortcut(
      id: id,
      name: name,
      url: url,
      faviconUrl: faviconUrl,
      category: category,
      isPinned: isPinned,
      sortOrder: maxOrder + 1,
      createdAt: now,
    );

    await db.insert('website_shortcuts', _toMap(shortcut));
    return shortcut;
  }

  Future<void> updateShortcut(WebsiteShortcut shortcut) async {
    final db = await _database.database;
    final updated = shortcut.copyWith(updatedAt: DateTime.now());
    await db.update(
      'website_shortcuts',
      _toMap(updated),
      where: 'id = ?',
      whereArgs: [shortcut.id],
    );
  }

  Future<void> deleteShortcut(String id) async {
    final db = await _database.database;
    await db.delete(
      'website_shortcuts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> reorderShortcuts(List<String> orderedIds) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      for (int i = 0; i < orderedIds.length; i++) {
        await txn.update(
          'website_shortcuts',
          {'sort_order': i},
          where: 'id = ?',
          whereArgs: [orderedIds[i]],
        );
      }
    });
  }

  WebsiteShortcut _fromMap(Map<String, Object?> map) {
    return WebsiteShortcut(
      id: map['id'] as String,
      name: map['name'] as String,
      url: map['url'] as String,
      faviconUrl: map['favicon_url'] as String?,
      category: map['category'] as String?,
      isPinned: (map['is_pinned'] as int) == 1,
      sortOrder: map['sort_order'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }

  Map<String, Object?> _toMap(WebsiteShortcut s) {
    return {
      'id': s.id,
      'name': s.name,
      'url': s.url,
      'favicon_url': s.faviconUrl,
      'category': s.category,
      'is_pinned': s.isPinned ? 1 : 0,
      'sort_order': s.sortOrder,
      'created_at': s.createdAt.toIso8601String(),
      'updated_at': s.updatedAt?.toIso8601String(),
    };
  }
}
