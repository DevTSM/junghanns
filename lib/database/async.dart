import 'dart:convert';
import 'dart:developer';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/models/authorization.dart';
import 'package:junghanns/models/config.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/folio.dart';
import 'package:junghanns/models/method_payment.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/refill.dart';
import 'package:junghanns/models/sale.dart';
import 'package:junghanns/models/stop.dart';
import 'package:junghanns/models/stop_ruta.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/auth.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/util/connection.dart';

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
              return getQR().then((value7){
                provider.labelAsync = "Sincronizando QR";
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
              return getQR().then((value7){
                provider.labelAsync = "Sincronizando QR";
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
  }
  
  Future <bool> getAsyncData() async {
    List<Map<String,dynamic>> salesPen= await handler.retrieveSales();
    List<Map<String,dynamic>> stopPen=await handler.retrieveStopOffUpdate();
    List<StopRuta> stopRuta=await handler.retrieveStopRuta();
    if(salesPen.isNotEmpty){
      log("ventas pendientes ---------> ${salesPen.length}");
       provider.labelAsync = "Sincronizando ventas locales";
      for(var e in salesPen){
          Map<String, dynamic> data = {
      "id_cliente": e["idCustomer"],
      "id_ruta": e["idRoute"],
      "latitud": e["lat"].toString(),
      "longitud": e["lng"].toString(),
      "venta": jsonDecode(e["saleItems"]),
      "id_autorizacion": e["idAuth"],
      "formas_de_pago": jsonDecode(e["paymentMethod"]),
      "id_data_origen": e["idOrigin"],
      "folio": e["folio"],
      "tipo_operacion": e["type"],
      "fecha_entrega":e["fecha_entrega"],
      "id_marca_garrafon":e["id_marca_garrafon"]
    };
        await postSale(data).then((value) async {
          if(!value.error){
            await handler.updateSale(1, e["id"]);
          }
        });
        
      }
    }
    if(stopPen.isNotEmpty){
       provider.labelAsync = "Sincronizando paradas en falso locales";
      for(var e in stopPen){
        Map<String, dynamic> data = {
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

  Future<bool> getDataCustomerList(String type, int typeInt) async {
    List<CustomerModel> list = [];
    provider.currentAsync = 0;
    provider.totalAsync = 1;
    return await getListCustomer(prefs.idRouteD, DateTime.now(), type)
        .then((answer) async {
      if (prefs.token != "") {
        if (!answer.error) {
          provider.totalAsync = answer.body.length > 0 ? answer.body.length : 1;
          for (var e in answer.body) {
            provider.currentAsync++;
            CustomerModel item = CustomerModel.fromState();
            item = CustomerModel.fromList(e, prefs.idRouteD, typeInt);
            await getDetailsCustomer(item.id, type).then((answer) async {
              if (!answer.error) {
                item =
                    CustomerModel.fromService(answer.body, item.id, item.type);
                await getConfig(item.idClient).then((answer) async {
                  if (!answer.error) {
                    for (var e in answer.body) {
                      item.setConfig([
                        ConfigModel.fromDatabase(
                            int.parse((e["valor"] ?? 99).toString()))
                      ]);
                    }
                    await getMoneyCustomer(item.idClient).then((answer) async {
                      if (!answer.error) {
                        item.setMoney(double.parse(
                            (answer.body["saldo"] ?? 0).toString()));
                        List<AuthorizationModel> authList = [];
                        //TODO: para las autorizaciones debemos castear en el navigator cuando no hay conexion
                        await getAuthorization(item.idClient, prefs.idRouteD)
                            .then((answer) async {
                          if (!answer.error) {
                            log("Auth yes");
                            for (var e in answer.body) {
                              authList.add(AuthorizationModel.fromService(e));
                            }
                            if (authList.isNotEmpty) {
                              item.setAuth(authList);
                            }
                          }
                          await getPaymentMethods(item.idClient, prefs.idRouteD)
                              .then((answer) async {
                            if (!answer.error) {
                              List<MethodPayment> paymentsList = [];
                              if (item.auth.isNotEmpty &&
                                  item.auth.first.type == "C") {
                                paymentsList.add(MethodPayment(
                                    wayToPay: "Credito",
                                    type: "Atributo",
                                    idProductService: -1,
                                    description: "",
                                    number: -1));
                                item.setPayment(paymentsList);
                              } else {
                                for (var e in answer.body) {
                                  paymentsList
                                      .add(MethodPayment.fromService(e));
                                }
                                if (item.purse > 0) {
                                  paymentsList.add(MethodPayment(
                                      wayToPay: "Monedero",
                                      type: "Monedero",
                                      idProductService: -1,
                                      description: "",
                                      number: -1));
                                }
                                item.setPayment(paymentsList);
                              }
                              await getHistoryCustomer(item.idClient)
                                  .then((answer) {
                                if (!answer.error) {
                                  item.setHistory(answer.body);
                                  list.add(item);
                                  log("insertando sgregando a la lista de ${list.length}");
                                }
                              });
                            }
                          });
                        });
                      }
                    });
                  }
                });
              }
            });
          }
          return await handler.insertUser(list).then((value) {
            return true;
          });
        } else {
          log(answer.message);
          return false;
        }
      } else {
        //retornamos para cerrar la sesion
        return false;
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
      log(answer.body.toString());
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

}
