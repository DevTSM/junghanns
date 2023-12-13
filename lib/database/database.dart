import 'dart:developer';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/folio.dart';
import 'package:junghanns/models/notification.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/refill.dart';
import 'package:junghanns/models/stop.dart';
import 'package:junghanns/models/stop_ruta.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DataBase {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    //path = (await getExternalStorageDirectory())!.path;
    return openDatabase(
      join(path, nameDB),
      onCreate: (database, version) async {
        //lista de clientes
        //autorizaciones en jsonEncode
        //payment en jsonEncode
        // 1= Ruta =>CRs
        // 2= Especiales =>ES 
        // 3=Segundas V => SV 
        // 4=clientes llama confirmados => LC
        // 5=Entregas =>ET
        // 6=clientes llama =>CL
        // 7=Atendidos
        // 8=Eliminados

        await database.execute(
          "CREATE TABLE customer(id INTEGER PRIMARY KEY, orden INTEGER , idCustomer INTEGER, idRoute INTEGER,type INTEGER, lat DOUBLE, lng DOUBLE, priceLiquid DOUBLE, byCollet DOUBLE, purse DOUBLE, name TEXT NOT NULL, address TEXT NOT NULL , nameRoute TEXT NOT NULL,typeVisit TEXT NOT NULL, category TEXT NOT NULL,days TEXT NOT NULL, img TEXT NOT NULL, observacion TEXT,auth TEXT,payment TEXT,color TEXT,config INTEGER,history TEXT,cargoAdicional TEXT,referenciaDomicilio TEXT,billing TEXT,creditos TEXT,isAuthPrice INTEGER,ventaPermitida INTEGER,horario1 TEXT,horario2 TEXT)",
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
          "CREATE TABLE stopOff(id INTEGER PRIMARY KEY AUTOINCREMENT,idCustomer INTEGER ,idStop INTEGER, lat DOUBLE, lng DOUBLE, idOrigin INTEGER, type TEXT NOT NULL,isUpdate INTEGER,fecha TEXT)",
        );
        //folio
        await database.execute(
          "CREATE TABLE folios(id INTEGER PRIMARY KEY AUTOINCREMENT,serie TEXT, numero INTEGER, tipo TEXT, status INTEGER)",
        );
        //notificaciones
        await database.execute(
          "CREATE TABLE notification(id INTEGER PRIMARY KEY AUTOINCREMENT,data TEXT ,date TEXT, name TEXT,description TEXT,status INTEGER)",
        );
        //paradas de ruta
        await database.execute(
          "CREATE TABLE stopRuta(id INTEGER PRIMARY KEY AUTOINCREMENT,status TEXT ,lat DOUBLE, lng DOUBLE,isUpdate INTEGER)",
        );
        //stock
        await database.execute(
          "CREATE TABLE product(id INTEGER PRIMARY KEY AUTOINCREMENT,idProductoServicio INTEGER, descripcion TEXT ,precio DOUBLE, stock DOUBLE,rank TEXT,url TEXT)",
        );
        //------------------------
        //ventas offLine
        //formas de pago y productos en jsonEncode
        await database.execute(
          "CREATE TABLE sale(id INTEGER PRIMARY KEY AUTOINCREMENT,idCustomer INTEGER ,idRoute INTEGER, lat DOUBLE, lng DOUBLE, saleItems TEXT, idAuth INTEGER,paymentMethod TEXT,idOrigin INTEGER,folio INTEGER,type TEXT,isUpdate INTEGER,fecha_entrega TEXT,id_marca_garrafon INTEGER,isError INTEGER,fecha_update TEXT,fecha TEXT)",
        );
        //devoluciones offline
        await database.execute(
          "CREATE TABLE devolucion(id INTEGER PRIMARY KEY AUTOINCREMENT,idDocumento INTEGER,cantidad INTEGER, lat DOUBLE, lng DOUBLE,isUpdate INTEGER,isError INTEGER,tipo TEXT,total DOUBLE,folio INTEGER,idCliente INTEGER,desc,date TEXT,precio_unitario DOUBLE)",
        );
        // Bitacora
        await database.execute(
          "CREATE TABLE bitacora(id INTEGER PRIMARY KEY AUTOINCREMENT,lat DOUBLE, lng DOUBLE,date TEXT,status TEXT,desc TEXT)",
        );
        // prefs
        await database.execute(
          "CREATE TABLE preferencias(id INTEGER PRIMARY KEY AUTOINCREMENT,url TEXT,clientSecret TEXT)",
        );
      },
      version: 1,
    );
  }
  Future<int> insertDevolucion(Map<String,dynamic> devolucion) async {
    final Database db = await initializeDB();
     return  await db.insert('devolucion', devolucion);

  }
  Future<int> insertStopRuta(StopRuta stop) async {
    final Database db = await initializeDB();
     return  await db.insert('stopRuta', stop.getMap);

  }
  Future<int> insertProduct(ProductModel product) async {
    final Database db = await initializeDB();
     return  await db.insert('product', product.getMapProduct);

  }
  Future<int> insertUser(List<CustomerModel> users) async {
    try{
    int result = 0;
    final Database db = await initializeDB();
    for (var user in users) {
      result = await db.insert('customer', user.getMap());
    }
    return result;
    }catch(e){
      log(e.toString());
      return 0;
    }
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
  Future<int> insertNotification(Map<String, dynamic> notification) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.insert('notification', notification);
    log("se inserto la notificacion $result");
    return result;
  }
  Future<int> insertBrand(Map<String, dynamic> brand) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.insert('sale', brand);
    log("se inserto la venta $result");
    return result;
  }
  Future<int> inserBitacora(Map<String, dynamic> item) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.insert('bitacora', item);
    log("se inserto  $result en la bitacora");
    return result;
  }
  Future<int> inserPrefs(Map<String, dynamic> item) async {
    int result = 0;
    try{
    final Database db = await initializeDB();
    result = await db.insert('preferencias', item);
    log("se inserto  $result en la prefs");
    print("se inserto  $result en la prefs");
    return result;
    }catch(e){
      log("Error inesperado: ${e.toString()}");
      return 0;
    }
  }
  deleteTable({bool isInit=true}) async {
    try{
    final db = await initializeDB();
    if(isInit){
      db.delete('sale');
      db.delete('stopRuta');
      db.delete('stopOff');
      db.delete('customer');
      db.delete('notification');
      db.delete('bitacora');
      db.delete('devolucion');
    }else{
      List<CustomerModel> dataAtendidos=await retrieveUsersType(7);
      db.delete('customer');
      insertUser(dataAtendidos);
    }
    db.delete('stop');
    db.delete('refill');
    db.delete('product');
    db.delete('folios');
    }catch(e){
      log(e.toString());
    }
  }
  deleteDevoluciones() async {
     final db = await initializeDB();
    db.delete('devolucion');
  }
  deleteBitacora() async {
     final db = await initializeDB();
    db.delete('bitacora');
  }
  deleteCustomers() async {
     final db = await initializeDB();
    db.delete('customer');
  }
  
  deleteFolios() async {
     final db = await initializeDB();
    db.delete('folios');
  }
  deleteStock() async {
    final db = await initializeDB();
    db.delete('product');
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
  deleteNotification() async {
    final db = await initializeDB();
    db.delete('notification');
  }
  deleteRefill() async {
    final db = await initializeDB();
    db.delete('refill');
  }
  addColumn() async {
    try{
    final db = await initializeDB();
    log("<=========== Agregando columnas =====>");
    await db.execute("ALTER TABLE stopOff ADD fecha TEXT");
    await db.execute("ALTER TABLE sale ADD fecha TEXT");
    await db.execute("ALTER TABLE sale ADD fecha_update TEXT");
    await db.execute("ALTER TABLE customer ADD billing TEXT");
    await db.execute("ALTER TABLE sale ADD isError INTEGER");
    await db.execute("ALTER TABLE sale ADD id_marca_garrafon INTEGER");
    await db.execute("ALTER TABLE sale ADD fecha_entrega TEXT");
    }catch(e){
      log("Error al agregar los campos a la base local: $e");
      Fluttertoast.showToast(
          msg: "Error al agregar los campos a la base local",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
    }
  }
  Future<bool> checkValidate()async{
    String path = await getDatabasesPath();
    bool isValid=await databaseExists("$path/$nameDB");
    log("IsValid: $isValid");
    return isValid;
  }
  Future<List<Map<String, dynamic>>> retrieveDevolucion() async {
    final Database db = await initializeDB();
    return await db.query('devolucion');
  }
  Future<List<Map<String, dynamic>>> retrieveDevolucionAsync() async {
    final Database db = await initializeDB();
    return await db.query('devolucion',where: "isUpdate = ? and isError=?",whereArgs: [0,0]);
  }
  Future<List<FolioModel>> retrieveFolios() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult =
        await db.query('folios');
    return queryResult.map((e) => FolioModel.fromDataBase(e)).toList();
  }
  Future<List<NotificationModel>> retrieveNotification() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult =
        await db.query('notification');
    return queryResult.map((e) => NotificationModel.fromDataBase(e)).toList();
  }
  Future<List<ProductModel>> retrieveProducts() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult =
        await db.query('product');
    return queryResult.map((e) => ProductModel.fromDatabase(e)).toList();
  }
  Future<List<CustomerModel>> retrieveUsers() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult =
        await db.query('customer');
    return queryResult.map((e) => CustomerModel.fromDataBase(e)).toList();
  }
  Future<List<CustomerModel>> retrieveUsersType(int type) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('customer',
        where: "type = ? ", whereArgs: [type], orderBy: "orden DESC");
    return queryResult.map((e) => CustomerModel.fromDataBase(e)).toList();
  }
  Future<List<Map<String, dynamic>>> retrieveUsersType2(int type1,int type2, int type3,int type4,int type5,int type6) async {
    final Database db = await initializeDB();
    return await db.query('customer',
        where: "type = ? or type = ? or type = ? or type = ? or type = ? or type = ?", whereArgs: [type1,type2,type3,type4,type5,type6], orderBy: "id ASC");
  }
  Future<List<StopRuta>> retrieveStopRuta() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('stopRuta',where: "isUpdate = ?",whereArgs: [0]);
    return queryResult.map((e) => StopRuta.fromDataBase(e)).toList();
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
  Future<List<Map<String, dynamic>>> retrieveStopOffUpdate() async {
    final Database db = await initializeDB();
    return await db.query('stopOff',where: "isUpdate = ?",whereArgs: [0]);
  }
  Future<List<Map<String, dynamic>>> retrieveSales() async {
    final Database db = await initializeDB();
    return await db.query('sale',where: "isUpdate = ?",whereArgs: [0]);
  }
  Future<List<Map<String, dynamic>>> retrieveSalesOff() async {
    final Database db = await initializeDB();
    return await db.query('sale');
  }
  Future<List<Map<String, dynamic>>> retrieveSalesAll() async {
    final Database db = await initializeDB();
    return await db.query('sale');
  }
  Future<List<Map<String, dynamic>>> retrieveBitacora() async {
    final Database db = await initializeDB();
    return await db.query('bitacora');
  }
  Future<List<Map<String, dynamic>>> retrievePrefs() async {
    try{
    final Database db = await initializeDB();
    return await db.query('preferencias');
    }catch(e){
      log("Error inesperado: ${e.toString()}");

      return [];
    }
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
  Future<void> updateDevolucion(Map<String,dynamic> devolucion) async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Update the given Dog.
    await db.update(
      'devolucion',
      devolucion,
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [devolucion["id"]],
    );
  }
  Future<void> updateFolio(FolioModel folioCurrent) async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Update the given Dog.
    await db.update(
      'folios',
      folioCurrent.getMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [folioCurrent.id],
    );
  }
  
  Future<void> updateNotification(NotificationModel notification) async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Update the given Dog.
    await db.update(
      'notification',
      notification.getMap,
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [notification.id],
    );
  }
  Future<void> updateSale(Map<String,dynamic>data, int id) async {
    // Get a reference to the database.
    final db = await initializeDB();
    // Update the given Dog.
    await db.update(
      'sale',
      data,
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
    log("venta $id actualizada con $data");
  }
  Future<void> deleteTemporalySale(int id) async {
    // Get a reference to the database.
    final db = await initializeDB();
    // Update the given Dog.
    await db.update(
      'sale',
      {'isError':-1},
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
    log("venta $id actualizada sub eliminada");
  }
  Future<void> updateStopOff(int update, int id) async {
    // Get a reference to the database.
    final db = await initializeDB();
    // Update the given Dog.
    await db.update(
      'stopOff',
      {'isUpdate': 1},
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
    log("venta $id actualizada con $update");
  }
  Future<void> updateProductStock(int update, int id) async {
    // Get a reference to the database.
    final db = await initializeDB();
    // Update the given Dog.
    await db.update(
      'product',
      {'stock': update},
      // Ensure that the Dog has a matching id.
      where: 'idProductoServicio = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
    log("Producto $id actualizada con $update");
  }
  Future<void> updateStopRuta(int update, int id) async {
    // Get a reference to the database.
    final db = await initializeDB();
    // Update the given Dog.
    await db.update(
      'stopRuta',
      {'isUpdate': 1},
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
    log("stopRuta $id actualizada con $update");
  }
}
