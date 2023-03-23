import 'dart:developer';

import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/folio.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/refill.dart';
import 'package:junghanns/models/stop.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBase {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    path = (await getExternalStorageDirectory())!.path;
    return openDatabase(
      join(path, 'junghanns.db'),
      onCreate: (database, version) async {
        //lista de clientes
        //autorizaciones en jsonEncode
        //payment en jsonEncode
        // 1= Especial 2=Ruta, 3=vuelta, 4=llama
        await database.execute(
          "CREATE TABLE customer(id INTEGER PRIMARY KEY AUTOINCREMENT, orden INTEGER , idCustomer INTEGER, idRoute INTEGER,type INTEGER, lat DOUBLE, lng DOUBLE, priceLiquid DOUBLE, byCollet DOUBLE, purse DOUBLE, name TEXT NOT NULL, address TEXT NOT NULL , nameRoute TEXT NOT NULL,typeVisit TEXT NOT NULL, category TEXT NOT NULL,days TEXT NOT NULL, img TEXT NOT NULL, observacion TEXT,auth TEXT,payment TEXT,color TEXT,config INTEGER,history TEXT)",
        );
        //lista de paradas en falso
        await database.execute(
          "CREATE TABLE stop(id INTEGER PRIMARY KEY AUTOINCREMENT, description TEXT NOT NULL, icon TEXT NOT NULL , color TEXT NOT NULL)",
        );
        //lista de recargas
        await database.execute(
          "CREATE TABLE refill(idProduct INTEGER PRIMARY KEY, description TEXT, price DOUBLE)",
        );
        //paradas en falso offLine
        await database.execute(
          "CREATE TABLE stopOff(idCustomer INTEGER ,idStop INTEGER, lat DOUBLE, lng DOUBLE, idOrigin INTEGER, type TEXT NOT NULL)",
        );
        //folio
        await database.execute(
          "CREATE TABLE folios(id INTEGER PRIMARY KEY AUTOINCREMENT,serie TEXT, numero INTEGER, tipo TEXT, status INTEGER)",
        );
        //
        //------------------------
        //ventas offLine
        //formas de pago y productos en jsonEncode
        await database.execute(
          "CREATE TABLE sale(id INTEGER PRIMARY KEY AUTOINCREMENT,idCustomer INTEGER ,idRoute INTEGER, lat DOUBLE, lng DOUBLE, saleItems TEXT, idAuth INTEGER,paymentMethod TEXT,idOrigin INTEGER,folio INTEGER,type TEXT,isUpdate INTEGER)",
        );
        //
      },
      version: 1,
    );
  }

  Future<int> insertUser(List<CustomerModel> users) async {
    int result = 0;
    final Database db = await initializeDB();
    for (var user in users) {
      result = await db.insert('customer', user.getMap());
    }
    return result;
  }

  Future<int> insertStop(List<StopModel> stops) async {
    int result = 0;
    final Database db = await initializeDB();
    for (var stop in stops) {
      result = await db.insert('stop', stop.getMap());
    }
    return result;
  }

  Future<int> insertRefill(List<RefillModel> refillList) async {
    int result = 0;
    final Database db = await initializeDB();
    for (var refill in refillList) {
      result = await db.insert('refill', refill.getMap());
      log(result.toString());
    }
    return result;
  }

  Future<int> insertFolios(List<FolioModel> foliosList) async {
    int result = 0;
    final Database db = await initializeDB();
    for (var folio in foliosList) {
      result = await db.insert('folios', folio.getMap());
    }
    return result;
  }

  Future<int> insertStopOff(Map<String, dynamic> stops) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.insert('stopOff', stops);
    return result;
  }

  Future<int> insertSale(Map<String, dynamic> sale) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.insert('sale', sale);
    log("se inserto la venta $result");
    return result;
  }

  deleteTable() async {
    final db = await initializeDB();
    db.delete('customer');
    db.delete('stop');
    db.delete('refill');
  }

  deleteSaleId(int id) async {
    final db = await initializeDB();
    await db.delete(
      'sale',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  deleteStopId(int id) async {
    final db = await initializeDB();
    await db.delete(
      'stopOff',
      where: "idCustomer = ?",
      whereArgs: [id],
    );
  }

  deleteStops() async {
    final db = await initializeDB();
    db.delete('stop');
  }

  deleteStopOff() async {
    final db = await initializeDB();
    db.delete('stopOff');
  }

  deleteSale() async {
    final db = await initializeDB();
    db.delete('sale');
  }

  deleteRefill() async {
    final db = await initializeDB();
    db.delete('refill');
  }

  addColumn() async {
    final db = await initializeDB();
    db.execute("ALTER TABLE customer ADD async INTEGER NOT NULL DEFAULT 1");
  }

  Future<List<CustomerModel>> retrieveUsers() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult =
        await db.query('customer', orderBy: "orden ASC");
    return queryResult.map((e) => CustomerModel.fromDataBase(e)).toList();
  }

  Future<List<CustomerModel>> retrieveUsersType(int type) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('customer',
        where: "type = ? ", whereArgs: [type], orderBy: "orden DESC");
    return queryResult.map((e) => CustomerModel.fromDataBase(e)).toList();
  }

  Future<List<Map<String, dynamic>>> retrieveUsersType2(int type) async {
    final Database db = await initializeDB();
    return await db.query('customer',
        where: "type = ? ", whereArgs: [type], orderBy: "orden DESC");
  }

  Future<List<StopModel>> retrieveStop() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('stop');
    return queryResult.map((e) => StopModel.fromDatabase(e)).toList();
  }

  Future<List<ProductModel>> retrieveRefill() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('refill');
    return queryResult.map((e) {
      return ProductModel.fromServiceRefillDatabase(e);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> retrieveStopOff() async {
    final Database db = await initializeDB();
    return await db.query('stopOff');
  }

  Future<List<Map<String, dynamic>>> retrieveSales() async {
    final Database db = await initializeDB();
    return await db.query('sale',where: "isUpdate = ?",whereArgs: [0]);
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
    var res = await db.query(
      'customer',
      where: "email = ?",
      whereArgs: [email],
    );
    return res.isNotEmpty ? CustomerModel.fromDataBase(res.first) : null;
  }

  Future<void> updateUser(CustomerModel customerCurrent) async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Update the given Dog.
    await db.update(
      'customer',
      customerCurrent.getMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [customerCurrent.id],
    );
  }

  Future<void> updateFolio(FolioModel folioCurrent) async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Update the given Dog.
    await db.update(
      'customer',
      folioCurrent.getMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [folioCurrent.id],
    );
  }

  Future<void> updateSale(int update, int id) async {
    // Get a reference to the database.
    final db = await initializeDB();
    // Update the given Dog.
    await db.update(
      'sale',
      {'isUpdate': 1},
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
    log("venta $id actualizada con $update");
  }
}
