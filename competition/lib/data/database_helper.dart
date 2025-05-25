import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/team.dart';
import '../models/player.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sports_competition.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create teams table
    await db.execute('''
      CREATE TABLE favorite_teams (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        tla TEXT,
        crest TEXT,
        address TEXT,
        website TEXT,
        founded INTEGER,
        clubColors TEXT,
        venue TEXT,
        latitude REAL,
        longitude REAL
      )
    ''');

    // Create players table
    await db.execute('''
      CREATE TABLE favorite_players (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        position TEXT,
        dateOfBirth TEXT,
        nationality TEXT,
        shirtNumber INTEGER,
        teamId INTEGER NOT NULL,
        teamName TEXT
      )
    ''');
  }

  // Team operations
  Future<int> insertFavoriteTeam(Team team) async {
    final db = await database;
    return await db.insert(
      'favorite_teams',
      team.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Team>> getFavoriteTeams() async {
    final db = await database;
    final maps = await db.query('favorite_teams');
    return List.generate(maps.length, (i) => Team.fromMap(maps[i]));
  }

  Future<bool> isTeamFavorite(int teamId) async {
    final db = await database;
    final result = await db.query(
      'favorite_teams',
      where: 'id = ?',
      whereArgs: [teamId],
    );
    return result.isNotEmpty;
  }

  Future<int> deleteFavoriteTeam(int teamId) async {
    final db = await database;
    return await db.delete(
      'favorite_teams',
      where: 'id = ?',
      whereArgs: [teamId],
    );
  }

  // Player operations
  Future<int> insertFavoritePlayer(Player player) async {
    final db = await database;
    return await db.insert(
      'favorite_players',
      player.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Player>> getFavoritePlayers() async {
    final db = await database;
    final maps = await db.query('favorite_players');
    return List.generate(maps.length, (i) => Player.fromMap(maps[i]));
  }

  Future<bool> isPlayerFavorite(int playerId) async {
    final db = await database;
    final result = await db.query(
      'favorite_players',
      where: 'id = ?',
      whereArgs: [playerId],
    );
    return result.isNotEmpty;
  }

  Future<int> deleteFavoritePlayer(int playerId) async {
    final db = await database;
    return await db.delete(
      'favorite_players',
      where: 'id = ?',
      whereArgs: [playerId],
    );
  }

  // Close the database
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
