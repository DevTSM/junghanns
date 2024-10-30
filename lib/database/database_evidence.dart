import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../models/evidence.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'evidences.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE evidences (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            idRuta TEXT,
            idCliente TEXT,
            tipo TEXT,
            cantidad TEXT,
            lat DOUBLE,
            lon DOUBLE,
            idAutorization INTEGER,
            archivo TEXT,
            isUploaded INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertEvidence(String idRuta, String idCliente, String tipo, String cantidad, double lat, double lon, int idAutorization, String archivo, int isUploaded) async {
    final db = await database;
    return await db.insert('evidences', {
      'idRuta': idRuta,
      'idCliente': idCliente,
      'tipo': tipo,
      'cantidad': cantidad,
      'lat': lat,
      'lon': lon,
      'idAutorization': idAutorization,
      'archivo': archivo,
      'isUploaded': isUploaded,
    });
  }

  Future<int> updateEvidence(int id, int isUploaded) async {
    final db = await database;
    return await db.update(
      'evidences',
      {'isUploaded': isUploaded},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Evidence>> getAllEvidences() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('evidences'); // Cambiado de 'evidencias' a 'evidences'

    return List.generate(maps.length, (i) {
      return Evidence(
        idRuta: maps[i]['idRuta'] ?? '',
        idCliente: maps[i]['idCliente'] ?? '',
        tipo: maps[i]['tipo'] ?? '',
        cantidad: maps[i]['cantidad'] ?? '',
        lat: maps[i]['lat'] ?? 0.0,
        lon: maps[i]['lon'] ?? 0.0,
        idAutorization: maps[i]['idAutorization'] ?? 0,
        filePath: maps[i]['archivo'] ?? '',
        isUploaded: (maps[i]['isUploaded'] ?? 0) == 1,
      );
    });
  }

  Future<List<Evidence>> getEvidences() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('evidences'); // Cambiado de 'evidencias' a 'evidences'

    return List.generate(maps.length, (i) {
      return Evidence(
        idRuta: maps[i]['idRuta'] ?? '',
        idCliente: maps[i]['idCliente'] ?? '',
        tipo: maps[i]['tipo'] ?? '',
        cantidad: maps[i]['cantidad'] ?? '',
        lat: maps[i]['lat'] ?? 0.0,
        lon: maps[i]['lon'] ?? 0.0,
        idAutorization: maps[i]['idAutorization'] ?? 0,
        filePath: maps[i]['archivo'] ?? '',
        isUploaded: (maps[i]['isUploaded'] ?? 0) == 0,
      );
    });
  }

}
