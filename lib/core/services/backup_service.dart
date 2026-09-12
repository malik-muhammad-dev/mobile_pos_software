import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../db/app_database.dart';

class BackupRecord {
  final DateTime createdAt;
  final String filePath;
  final String type; // 'auto' | 'manual'
  final int sizeBytes;

  const BackupRecord({
    required this.createdAt,
    required this.filePath,
    required this.type,
    required this.sizeBytes,
  });

  factory BackupRecord.fromRow(Map<String, Object?> row) => BackupRecord(
        createdAt: DateTime.parse(row['created_at'] as String),
        filePath: row['file_path'] as String,
        type: row['type'] as String,
        sizeBytes: row['size_bytes'] as int,
      );
}

/// Local-only snapshots — no cloud, per the offline-only NFR. A snapshot is
/// just a timestamped copy of the on-disk .db file, logged so the Settings
/// screen can always show "last backup: X ago".
class BackupService {
  BackupService({Future<Database> Function()? databaseProvider})
      : _databaseProvider = databaseProvider ?? AppDatabase.getDatabase;

  final Future<Database> Function() _databaseProvider;

  Future<BackupRecord> runBackup({required bool manual}) async {
    final supportDir = await getApplicationSupportDirectory();
    final dbFile = File(join(supportDir.path, 'mobile_shop_pos.db'));
    final backupsDir = Directory(join(supportDir.path, 'backups'));
    if (!await backupsDir.exists()) await backupsDir.create(recursive: true);

    final now = DateTime.now();
    final fileName = 'backup_${now.toIso8601String().replaceAll(':', '-')}.db';
    final destPath = join(backupsDir.path, fileName);
    await dbFile.copy(destPath);
    final sizeBytes = await File(destPath).length();

    final db = await _databaseProvider();
    await db.insert('backups_log', {
      'created_at': now.toIso8601String(),
      'file_path': destPath,
      'type': manual ? 'manual' : 'auto',
      'size_bytes': sizeBytes,
    });

    return BackupRecord(
      createdAt: now,
      filePath: destPath,
      type: manual ? 'manual' : 'auto',
      sizeBytes: sizeBytes,
    );
  }

  Future<BackupRecord?> lastBackup() async {
    final db = await _databaseProvider();
    final rows = await db.query('backups_log', orderBy: 'created_at DESC', limit: 1);
    if (rows.isEmpty) return null;
    return BackupRecord.fromRow(rows.first);
  }
}