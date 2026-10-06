import 'package:sqflite/sqflite.dart';
import 'package:aniweb/data/database/local_database.dart';
import 'package:aniweb/data/models/download_item.dart';

class DownloadRepository {
  DownloadRepository(this._database);

  final LocalDatabase _database;

  Future<void> upsert(DownloadItem item) async {
    final db = await _database.database;
    await db.insert(
      'downloads',
      {
        'id': item.id,
        'title': item.title,
        'source_url': item.sourceUrl,
        'file_path': item.filePath,
        'status': item.status.name,
        'progress': item.progress,
        'downloaded_bytes': item.downloadedBytes,
        'total_bytes': item.totalBytes,
        'created_at': item.createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DownloadItem>> all() async {
    final db = await _database.database;
    final rows = await db.query('downloads', orderBy: 'created_at DESC');
    return rows
        .map(
          (row) => DownloadItem(
            id: row['id'] as String,
            title: row['title'] as String,
            sourceUrl: row['source_url'] as String,
            filePath: row['file_path'] as String,
            status: DownloadStatus.values.byName(row['status'] as String),
            progress: (row['progress'] as num).toDouble(),
            downloadedBytes: (row['downloaded_bytes'] as num).toInt(),
            totalBytes: (row['total_bytes'] as num?)?.toInt(),
            createdAt: DateTime.parse(row['created_at'] as String),
          ),
        )
        .toList(growable: false);
  }
}
