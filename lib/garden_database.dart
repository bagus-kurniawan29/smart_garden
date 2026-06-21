import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class CropCycle {
  const CropCycle({
    required this.id,
    required this.plantType,
    required this.startedAt,
  });

  final int id;
  final String plantType;
  final DateTime startedAt;

  int get currentDay {
    final day = DateTime.now().difference(startedAt).inDays + 1;
    return day < 1 ? 1 : day;
  }
}

class GardenDatabase {
  GardenDatabase._();

  static final GardenDatabase instance = GardenDatabase._();

  Database? _database;
  final Map<String, DateTime> _memoryFertilization = {};
  final Map<String, CropCycle> _memoryCycles = {};
  int _memoryCycleId = 0;

  Future<Database?> _openDatabase() async {
    if (kIsWeb) return null;
    if (_database != null) return _database;

    try {
      final databasePath = await getDatabasesPath();
      _database = await openDatabase(
        path.join(databasePath, 'smart_garden.db'),
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE fertilization_log (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              plant_type TEXT NOT NULL,
              fertilized_at TEXT NOT NULL
            )
          ''');
          await _createCropCycleTable(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _createCropCycleTable(db);
          }
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
    if (db == null) return _memoryFertilization[plantType];

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
    _memoryFertilization[plantType] = now;
    final db = await _openDatabase();

    if (db != null) {
      await db.insert('fertilization_log', {
        'plant_type': plantType,
        'fertilized_at': now.toIso8601String(),
      });
    }

    return now;
  }

  Future<CropCycle?> getActiveCropCycle(String plantType) async {
    final db = await _openDatabase();
    if (db == null) return _memoryCycles[plantType];

    final rows = await db.query(
      'crop_cycle',
      where: 'plant_type = ? AND completed_at IS NULL',
      whereArgs: [plantType],
      orderBy: 'started_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;

    return CropCycle(
      id: rows.first['id'] as int,
      plantType: rows.first['plant_type'] as String,
      startedAt: DateTime.parse(rows.first['started_at'] as String),
    );
  }

  Future<CropCycle> startCropCycle(String plantType) async {
    final existing = await getActiveCropCycle(plantType);
    if (existing != null) return existing;

    final startedAt = DateTime.now();
    final db = await _openDatabase();
    if (db == null) {
      final cycle = CropCycle(
        id: ++_memoryCycleId,
        plantType: plantType,
        startedAt: startedAt,
      );
      _memoryCycles[plantType] = cycle;
      return cycle;
    }

    final id = await db.insert('crop_cycle', {
      'plant_type': plantType,
      'started_at': startedAt.toIso8601String(),
      'completed_at': null,
    });
    return CropCycle(id: id, plantType: plantType, startedAt: startedAt);
  }

  Future<void> completeCropCycle(CropCycle cycle) async {
    _memoryCycles.remove(cycle.plantType);
    final db = await _openDatabase();
    if (db == null) return;

    await db.update(
      'crop_cycle',
      {'completed_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [cycle.id],
    );
  }

  static Future<void> _createCropCycleTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS crop_cycle (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plant_type TEXT NOT NULL,
        started_at TEXT NOT NULL,
        completed_at TEXT
      )
    ''');
  }
}
