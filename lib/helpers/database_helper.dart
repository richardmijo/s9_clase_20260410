import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/carrera.dart';
import '../models/estudiante.dart';

class DatabaseHelper {
  // Patrón Singleton
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('universidad.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  // Habilitar el soporte de claves foráneas
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    // 1. Crear la tabla de Carreras
    await db.execute('''
      CREATE TABLE carreras (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

    // 2. Crear la tabla de Estudiantes
    await db.execute('''
      CREATE TABLE estudiantes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        email TEXT NOT NULL,
        carrera_id INTEGER NOT NULL,
        FOREIGN KEY (carrera_id) REFERENCES carreras (id) ON DELETE CASCADE
      )
    ''');
  }

  // ==========================================
  // OPERACIONES PARA CARRERAS
  // ==========================================

  Future<int> insertCarrera(Carrera carrera) async {
    final db = await instance.database;
    return await db.insert('carreras', carrera.toMap());
  }

  Future<List<Carrera>> getCarreras() async {
    final db = await instance.database;
    final result = await db.query('carreras');
    return result.map((json) => Carrera.fromMap(json)).toList();
  }

  // ==========================================
  // OPERACIONES PARA ESTUDIANTES
  // ==========================================

  Future<int> insertEstudiante(Estudiante estudiante) async {
    final db = await instance.database;
    return await db.insert('estudiantes', estudiante.toMap());
  }

  Future<List<Estudiante>> getEstudiantes() async {
    final db = await instance.database;
    // Realizamos INNER JOIN para traer el nombre de la carrera asociado
    final result = await db.rawQuery('''
      SELECT e.id, e.nombre, e.email, e.carrera_id, c.nombre as carrera_nombre
      FROM estudiantes e
      INNER JOIN carreras c ON e.carrera_id = c.id
    ''');
    return result.map((json) => Estudiante.fromMap(json)).toList();
  }

  Future<int> deleteEstudiante(int id) async {
    final db = await instance.database;
    return await db.delete('estudiantes', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
