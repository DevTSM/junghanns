import 'dart:convert';
import 'dart:developer';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/models/answer.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/folio.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/refill.dart';
import 'package:junghanns/models/stop.dart';
import 'package:junghanns/models/stop_ruta.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/store.dart';

class Async {
  ProviderJunghanns provider;
  Async({required this.provider});

  Future<bool> init({bool isInit=true}) async {
    provider.asyncProcess=true;
    provider.labelAsync = "Sincronizando datos, no cierres la app.";
    prefs.isAsyncCurrent = true;
     provider.labelAsync = "Obteniendo datos guardados";
    provider.labelAsync = "Limpiando base de datos";
    return await handler.deleteTable(isInit: isInit).then((value) async {
      provider.labelAsync = "Sincronizando clientes";
      return getDataCustomers().then((value4) {
        provider.labelAsync = "Sincronizando stock";
      return getStock().then((value){
        provider.labelAsync = "Sincronizando paradas";
        return getDataStops().then((value5) {
          provider.labelAsync = "Sincronizando recargas";
          return getDataRefill().then((value6) {
            provider.labelAsync = "Sincronizando folios";
            return getDataFolios().then((value6) {
              provider.labelAsync = "Sincronizando QR";
              return getQR().then((value7){
                provider.labelAsync = "Sincronizando marcas de garrafón";
                return getDataBrand().then((value8){
                  prefs.isAsyncCurrent = false;
              provider.asyncProcess=false;
              return true;
                });
              });
            });
          });
        });
        });
      });
    });
  }
  
  Future<bool> initAsync() async {
    provider.asyncProcess=true;
    provider.labelAsync = "Sincronizando datos, no cierres la app.";
    prefs.isAsyncCurrent = true;
     provider.labelAsync = "Obteniendo datos guardados";
     return getAsyncData().then((value) async {
      provider.labelAsync = "Sincronizando clientes";
      return getDataCustomers().then((value4) {
        provider.labelAsync = "Sincronizando stock";
      return getStock().then((value){
        provider.labelAsync = "Sincronizando paradas";
        return getDataStops().then((value5) {
          provider.labelAsync = "Sincronizando recargas";
          return getDataRefill().then((value6) {
            provider.labelAsync = "Sincronizando folios";
            return getDataFolios().then((value6) {
              provider.labelAsync = "Sincronizando QR";
              return getQR().then((value7){
                provider.labelAsync = "Sincronizando marcas de garrafón";
                return getDataBrand().then((value8){
                  prefs.isAsyncCurrent = false;
              provider.asyncProcess=false;
              return true;
                });
                
              });
            });
          });
        });
        });
      });
  });
  }
  
  Future <bool> getAsyncData() async {
    List<Map<String,dynamic>> salesPen= await handler.retrieveSales();
    List<Map<String,dynamic>> stopPen=await handler.retrieveStopOffUpdate();
    List<StopRuta> stopRuta=await handler.retrieveStopRuta();
    if(salesPen.isNotEmpty){
      log("ventas pendientes ---------> ${salesPen.length}");
       provider.labelAsync = "Sincronizando ventas locales";
      for(var e in salesPen){
          Map<String, dynamic> data = {};
      data["id_local"]=e["id"];
      data["id_cliente"]= e["idCustomer"];
      data["id_ruta"]= e["idRoute"];
      data["latitud"]= e["lat"].toString();
      data["longitud"]= e["lng"].toString();
      data["venta"]= jsonDecode(e["saleItems"]);
      if(e["idAuth"]!=null){
      data["id_autorizacion"]= e["idAuth"];
      }
      data["formas_de_pago"]= jsonDecode(e["paymentMethod"]);
      data["id_data_origen"]= e["idOrigin"];
      if(e["folio"]!=null){
        data["folio"]= e["folio"];
      }
      
      data["tipo_operacion"]= e["type"];
      data["fecha_entrega"]=e["fecha_entrega"];
      if(e["id_marca_garrafon"]!=null){
      data["id_marca_garrafon"]=e["id_marca_garrafon"];
      }
        await postSale(data).then((value) async {
          if(!value.error){
            await handler.updateSale({'isUpdate': 1,
      'fecha_update':DateTime.now().toString()}, e["id"]);
       provider.isNeedAsync=false;
          }else{
            if(value.status!=1002){
               await handler.updateSale({'isUpdate': 1,
      'fecha_update':DateTime.now().toString(),
      'isError':1
      }, e["id"]);
            }
          }
        });
        
      }
    }
    if(stopPen.isNotEmpty){
       provider.labelAsync = "Sincronizando paradas en falso locales";
      for(var e in stopPen){
        Map<String, dynamic> data = {
          "id_local":e["id"],
            "id_cliente": e["idCustomer"],
            "id_parada": e["idStop"],
            "lat": e["lat"].toString(),
            "lon": e["lng"].toString(),
            "id_data_origen": e["idOrigin"],
            "tipo": e["type"]
          };
        await postStop(data).then((value) async {
          if(!value.error){
            await handler.updateStopOff(1, e["id"]);
          }
        });
        
      }
    }
    if(stopRuta.isNotEmpty){
       provider.labelAsync = "Sincronizando paradas de ruta";
      for(var e in stopRuta){
        await setInitRoute(e.lat,e.lng,status: e.status);
        await handler.updateStopRuta(1, e.id);
      }
    }
    return true;
  }
  

  Future <bool> getStock()async{
    return await getStockList(prefs.idRouteD).then((answer) async {
      if(answer.error){
        Fluttertoast.showToast(
              msg: answer.message,
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true);
        return true;
      }else{
        await handler.deleteStock();
        for (var item in answer.body) {
          handler.insertProduct(ProductModel.fromServiceProduct(item));
        }
        return true;
      }
    });
  }
  
  Future<bool> getDataCustomers() async {
    List<CustomerModel> list = [];
    provider.currentAsync = 1;
    provider.totalAsync = 2;
    return await getCustomers().then((answer) async {
      if (answer.error) {
        Fluttertoast.showToast(
              msg: answer.message,
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true);
        return false;
      } else {
        List<CustomerModel> dataAtendidos=await handler.retrieveUsersType(7);
        await handler.deleteCustomers();
        await handler.insertUser(dataAtendidos);
        for (var item in answer.body) {
          list.add(CustomerModel.fromPayload(item));
        }
        provider.currentAsync = 2;
        return await handler.insertUser(list).then((value) {
          return true;
        });
      }
    });
  }

  Future<bool> getDataStops() async {
    return await getStopsList().then((answer) async {
      List<StopModel> stopList = [];
      if (!answer.error) {
        await handler.deleteStops();
        for (var item in answer.body) {
          stopList.add(StopModel.fromService(item));
        }
        handler.insertStop(stopList);
        return true;
      } else {
        Fluttertoast.showToast(
              msg: answer.message,
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true);
        return false;
      }
    });
  }

  Future<bool> getDataRefill() async {
    return await getRefillList(prefs.idRouteD).then((answer) async {
      List<RefillModel> refillList = [];
      if (!answer.error) {
        await handler.deleteRefill();
        for (var item in answer.body) {
          refillList.add(RefillModel.fromService(item));
        }
        handler.insertRefill(refillList);
        return true;
      } else {
        Fluttertoast.showToast(
              msg: answer.message,
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true);
        return false;
      }
    });
  }
  
  Future<bool> getDataFolios() async {
    return await getFolios().then((answer) async {
      List<FolioModel> folioList = [];
      if (!answer.error) {
        await handler.deleteFolios();
        for (var item in answer.body) {
          if(item["folios"]!=null){
            if(item["folios"]["remision"]!=null){
              for(var item3 in item["folios"]["remision"]){
              folioList.add(FolioModel.fromService(item3,item["serie"],"remision"));
            }
            }
            if(item["folios"]["comodato"]!=null){
              for(var itemC in item["folios"]["comodato"]){
              folioList.add(FolioModel.fromService(itemC,item["serie"],"comodato"));
            }
            }
            if(item["folios"]["comodato_inst"]!=null){
               for(var itemCI in item["folios"]["comodato_inst"]){
              folioList.add(FolioModel.fromService(itemCI,item["serie"],"comodato_inst"));
            }
            }
            if(item["folios"]["prestamo"]!=null){
               for(var itemCI in item["folios"]["prestamo"]){
              folioList.add(FolioModel.fromService(itemCI,item["serie"],"prestamo"));
              
            }
            }
          }
        }
        handler.insertFolios(folioList);
        return true;
      } else {
        Fluttertoast.showToast(
              msg: answer.message,
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true);
        return false;
      }
    });
  }
  
  Future<bool> getDataBrand()async{
    return await getBrands().then((answer) async {
      if (!answer.error) {
        prefs.brands=jsonEncode(answer.body);
        return true;
      } else {
        Fluttertoast.showToast(
              msg: answer.message,
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true);
        return false;
      }
    });
  }
}
Future <bool> getQR()async{
    return await getDataQr().then((answer){
      if(answer.error){
        Fluttertoast.showToast(
              msg: answer.message,
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true);
        return true;
      }else{
        List<Map<String,dynamic>> data=[];
        answer.body.map((e)=>data.add({"name":e["nombre"],"url":e["url"]})).toList();
        prefs.qr=jsonEncode(data);
        return true;
      }
    });
  }
