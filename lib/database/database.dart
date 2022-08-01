import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/stop.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBase {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'junghanns.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE customer(id INTEGER PRIMARY KEY AUTOINCREMENT, idCustomer INTEGER, idRoute INTEGER, lat DOUBLE, lng DOUBLE, priceLiquid DOUBLE, byCollet DOUBLE, purse DOUBLE, name TEXT NOT NULL, address TEXT NOT NULL , nameRoute TEXT NOT NULL,typeVisit TEXT NOT NULL, category TEXT NOT NULL,days TEXT NOT NULL, img TEXT NOT NULL, observacion TEXT NOT NULL)",
        );
        await database.execute(
          "CREATE TABLE stop(id INTEGER PRIMARY KEY AUTOINCREMENT, description TEXT NOT NULL, icon TEXT NOT NULL , color TEXT NOT NULL)",
        );
        await database.execute(
          "CREATE TABLE stopOff(idCustomer INTEGER ,idStop INTEGER, lat DOUBLE, lng DOUBLE, idOrigin INTEGER, type TEXT NOT NULL)",
        );
      },
      version: 1,
    );
  }

  Future<int> insertUser(List<CustomerModel> users) async {
    int result = 0;
    final Database db = await initializeDB();
    for(var user in users){
      result = await db.insert('customer', user.getMap());
    }
    return result;
  }
  Future<int> insertStop(List<StopModel> stops) async {
    int result = 0;
    final Database db = await initializeDB();
    for(var stop in stops){
      result = await db.insert('stop', stop.getMap());
    }
    return result;
  }
  Future<int> insertStopOff(Map<String,dynamic> stops) async {
    int result = 0;
    final Database db = await initializeDB();
      result = await db.insert('stop', stops);
    return result;
  }
  deleteTable() async {
    final db = await initializeDB();
    db.delete('customer');
  }
  deleteStops() async {
    final db = await initializeDB();
    db.delete('stop');
  }
  deleteStopOff() async {
    final db = await initializeDB();
    db.delete('stopOff');
  }
  addColumn() async {
    final db = await initializeDB();
    db.execute("ALTER TABLE customer ADD img TEXT NOT NULL DEFAULT ''");
  }

  Future<List<CustomerModel>> retrieveUsers() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('customer');
    return queryResult.map((e) => CustomerModel.fromDataBase(e)).toList();
  }
  Future<List<StopModel>> retrieveStop() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('stop');
    return queryResult.map((e) => StopModel.fromDatabase(e)).toList();
  }
  Future<List<Map<String,dynamic>>> retrieveStopOff() async {
    final Database db = await initializeDB();
    return await  db.query('stopOff');
  }

  Future<void> deleteUser(int id) async {
    final db = await initializeDB();
    await db.delete(
      'customer',
      where: "id = ?",
      whereArgs: [id],
    );
  }
  Future<dynamic> searchUser(String email) async {
    final db = await initializeDB();
    var res= await db.query(
      'customer',
      where: "email = ?",
      whereArgs: [email],
    );
    return res.isNotEmpty ? CustomerModel.fromDataBase(res.first) : null;
  }
}