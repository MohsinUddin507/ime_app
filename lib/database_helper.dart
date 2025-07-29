import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('attendance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Employees table
    await db.execute('''
      CREATE TABLE employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        employee_id TEXT UNIQUE NOT NULL,
        department TEXT,
        face_data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Attendance records table
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee_id TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,  // 'check_in' or 'check_out'
        timestamp TEXT NOT NULL,
        image_path TEXT,
        FOREIGN KEY (employee_id) REFERENCES employees (employee_id)
      )
    ''');
  }

  // Employee operations (renamed from createFace to insertEmployee)
  Future<int> insertEmployee({
    required String name,
    required String employeeId,
    required String faceData,
    String? department,
  }) async {
    final db = await instance.database;
    return await db.insert('employees', {
      'name': name,
      'employee_id': employeeId,
      'department': department,
      'face_data': faceData,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Alias for insertEmployee to maintain backward compatibility
  Future<int> createFace({
    required String name,
    required String employeeId,
    required String faceData,
    String? department,
  }) async {
    return insertEmployee(
      name: name,
      employeeId: employeeId,
      faceData: faceData,
      department: department,
    );
  }

  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    final db = await instance.database;
    return await db.query('employees');
  }

  Future<Map<String, dynamic>?> getEmployeeById(String employeeId) async {
    final db = await instance.database;
    final results = await db.query(
      'employees',
      where: 'employee_id = ?',
      whereArgs: [employeeId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Attendance operations
  Future<int> createAttendanceRecord({
    required String employeeId,
    required String name,
    required String type,
    String? imagePath,
  }) async {
    final db = await instance.database;
    return await db.insert('attendance', {
      'employee_id': employeeId,
      'name': name,
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
      'image_path': imagePath,
    });
  }

  // Alias for getAllAttendanceRecords
  Future<List<Map<String, dynamic>>> getAttendanceRecords() async {
    return getAllAttendanceRecords();
  }

  Future<List<Map<String, dynamic>>> getAllAttendanceRecords() async {
    final db = await instance.database;
    return await db.query('attendance', orderBy: 'timestamp DESC');
  }

  Future<List<Map<String, dynamic>>> getAttendanceByEmployee(String employeeId) async {
    final db = await instance.database;
    return await db.query(
      'attendance',
      where: 'employee_id = ?',
      whereArgs: [employeeId],
      orderBy: 'timestamp DESC',
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}