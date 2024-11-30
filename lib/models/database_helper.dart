import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'recipe.dart';
import 'production.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'big_bolos.db');

    return await openDatabase(
      path,
      version:
          2, // Incrementando a versão do banco de dados para forçar a atualização
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recipes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            ingredients TEXT,
            units TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE productions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            ingredients TEXT,
            units TEXT,
            isFinished INTEGER,
            finishDate TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE productions ADD COLUMN isFinished INTEGER DEFAULT 0');
        }
      },
    );
  }

  Future<void> insertRecipe(Recipe recipe) async {
    final db = await database;
    await db.insert(
      'recipes',
      recipe.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Recipe>> getRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('recipes');

    return List.generate(maps.length, (i) {
      return Recipe(
        name: maps[i]['name'],
        ingredients:
            Map<String, double>.from(jsonDecode(maps[i]['ingredients'])),
        units: Map<String, String>.from(jsonDecode(maps[i]['units'])),
      );
    });
  }

  Future<void> insertProduction(Production production) async {
    final db = await database;
    await db.insert(
      'productions',
      {
        'name': production.name,
        'ingredients': jsonEncode(production.ingredients),
        'units': jsonEncode(production.units),
        'isFinished': 0,
        'finishDate': null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertFinishedProduction(FinishedProduction production) async {
    final db = await database;
    await db.update(
      'productions',
      {
        'isFinished': 1,
        'finishDate': production.finishDate.toIso8601String(),
      },
      where: 'name = ? AND isFinished = 0',
      whereArgs: [production.name],
    );
  }

  Future<void> deleteProduction(String name) async {
    final db = await database;
    await db.delete(
      'productions',
      where: 'name = ? AND isFinished = 0',
      whereArgs: [name],
    );
  }

  Future<List<Production>> getProductions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'productions',
      where: 'isFinished = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) {
      return Production(
        name: maps[i]['name'],
        ingredients:
            Map<String, double>.from(jsonDecode(maps[i]['ingredients'])),
        units: Map<String, String>.from(jsonDecode(maps[i]['units'])),
      );
    });
  }

  Future<List<FinishedProduction>> getFinishedProductions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'productions',
      where: 'isFinished = ?',
      whereArgs: [1],
    );

    return List.generate(maps.length, (i) {
      return FinishedProduction(
        name: maps[i]['name'],
        ingredients:
            Map<String, double>.from(jsonDecode(maps[i]['ingredients'])),
        units: Map<String, String>.from(jsonDecode(maps[i]['units'])),
        finishDate: DateTime.parse(maps[i]['finishDate']),
      );
    });
  }
}
