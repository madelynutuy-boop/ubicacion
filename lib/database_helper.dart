
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

 
  DatabaseHelper._init();

 
  Future<Database> get database async {
    if (_database != null) return _database!;
    
   
    _database = await _initDB('basedatosgps.db');
    return _database!;
  }

    
 
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ubicaciones (
        ubicacion_id INTEGER PRIMARY KEY AUTOINCREMENT,
        longitud REAL NOT NULL,
        latitud REAL NOT NULL,
        fecha TEXT NOT NULL,
        hora TEXT NOT NULL
      )
    ''');
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

Future<int> insertarUbicacion(Map<String, dynamic> row) async {
  final db = await instance.database;
  return await db.insert('ubicaciones', row);
}


Future<List<Map<String, dynamic>>> obtenerUbicaciones() async {
  final db = await instance.database;
  
  return await db.query('ubicaciones', orderBy: 'ubicacion_id DESC');
}


  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
  }