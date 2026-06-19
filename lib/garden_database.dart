import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class GardenDatabase {
  GardenDatabase._();

  static final GardenDatabase instance = GardenDatabase._();

  Database? _database;
  DateTime? _memoryLastFertilization;

  Future<Database?> _openDatabase() async {
    if (kIsWeb) return null;
    if (_database != null) return _database;

    try {
      final databasePath = await getDatabasesPath();
      _database = await openDatabase(
        path.join(databasePath, 'smart_garden.db'),
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE fertilization_log (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              plant_type TEXT NOT NULL,
              fertilized_at TEXT NOT NULL
            )
          ''');
        },
      );
      return _database;
    } catch (_) {
      // Widget test dan platform tanpa plugin SQLite memakai fallback memori.
      return null;
    }
  }

  Future<DateTime?> getLastFertilization(String plantType) async {
    final db = await _openDatabase();
    if (db == null) return _memoryLastFertilization;

    final rows = await db.query(
      'fertilization_log',
      columns: ['fertilized_at'],
      where: 'plant_type = ?',
      whereArgs: [plantType],
      orderBy: 'fertilized_at DESC',
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return DateTime.tryParse(rows.first['fertilized_at'] as String);
  }

  Future<DateTime> recordFertilization(String plantType) async {
    final now = DateTime.now();
    _memoryLastFertilization = now;
    final db = await _openDatabase();

    if (db != null) {
      await db.insert('fertilization_log', {
        'plant_type': plantType,
        'fertilized_at': now.toIso8601String(),
      });
    }

    return now;
  }
}
