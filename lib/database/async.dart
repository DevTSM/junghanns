import 'dart:convert';
import 'dart:developer';

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
   await getAsyncData();
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
              prefs.isAsyncCurrent = false;
              provider.asyncProcess=false;
              return true;
            });
          });
        });
        });
      });
    });
  }
  Future <bool> getAsyncData() async {
    List<Map<String,dynamic>> salesPen= await handler.retrieveSales();
    List<Map<String,dynamic>> stopPen=await handler.retrieveStopOff();
    List<StopRuta> stopRuta=await handler.retrieveStopRuta();
    if(salesPen.isNotEmpty){
       provider.labelAsync = "Sincronizando ventas locales";
      for(var e in salesPen){
        await setSale(e);
        await handler.updateSale(1, e["id"]);
      }
    }
    if(stopPen.isNotEmpty){
       provider.labelAsync = "Sincronizando paradas en falso locales";
      for(var e in stopPen){
        await setStop(e);
        await handler.updateStopOff(1, e["id"]);
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
    return await getStockList(prefs.idRouteD).then((answer){
      if(answer.error){
        log("error ${answer.body}");
        return true;
      }else{
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
        log("error ${answer.body.toString()}");
        return true;
      } else {
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
                                    typeWayToPay: "C",
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
                                      typeWayToPay: "M",
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
    return await getStopsList().then((answer) {
      List<StopModel> stopList = [];
      if (!answer.error) {
        for (var item in answer.body) {
          stopList.add(StopModel.fromService(item));
        }
        handler.insertStop(stopList);
        return true;
      } else {
        return false;
      }
    });
  }

  Future<bool> getDataRefill() async {
    return await getRefillList(prefs.idRouteD).then((answer) {
      List<RefillModel> refillList = [];
      if (!answer.error) {
        for (var item in answer.body) {
          refillList.add(RefillModel.fromService(item));
        }
        handler.insertRefill(refillList);
        log("-----------------------${refillList.length.toString()}");
        return true;
      } else {
        return false;
      }
    });
  }
  
  Future<bool> getDataFolios() async {
    return await getFolios().then((answer) {
      List<FolioModel> folioList = [];
      if (!answer.error) {
        for (var item in answer.body) {
          if(item["folios"]!=null){
            if(item["folios"]["remision"]!=null){
              for(var item3 in item["folios"]["remision"]){
              folioList.add(FolioModel.fromService(item3,item["serie"]));
            }
            }
            if(item["folios"]["comodato"]!=null){
              for(var itemC in item["folios"]["comodato"]){
              folioList.add(FolioModel.fromService(itemC,item["serie"]));
            }
            }
            if(item["folios"]["comodato_inst"]!=null){
               for(var itemCI in item["folios"]["comodato_inst"]){
              folioList.add(FolioModel.fromService(itemCI,item["serie"]));
            }
            }
          }
        }
        handler.insertFolios(folioList);
        log("-----------------------${folioList.length.toString()}");
        return true;
      } else {
        return false;
      }
    });
  }

  Future<void> setDataSales() async {
    if (provider.connectionStatus != 4) {
      Connection connection = Connection();
      await connection.init();
      log("Verificando conexion Ventas ${connection.stableConnection}");
     // if (connection.stableConnection) {
      if(true){
        provider.asyncProcess = true;
        provider.labelAsync = "Sincronizando Ventas, no cierres la app.";
        List<Map<String, dynamic>> dataList = await handler.retrieveSales();
        provider.totalAsync = dataList.length;
        provider.currentAsync = 0;
        log("-------%%${dataList.length.toString()}");
        for (var e in dataList) {
          provider.currentAsync++;
          Map<String, dynamic> data = {
            "id_cliente": e["idCustomer"],
            "id_ruta": e["idRoute"],
            "latitud": e["lat"].toString(),
            "longitud": e["lng"].toString(),
            "venta": List.from(jsonDecode(e["saleItems"]).toList()),
            "id_autorizacion": e["idAuth"],
            "formas_de_pago":
                List.from(jsonDecode(e["paymentMethod"]).toList()),
            "id_data_origen": e["idOrigin"],
            "folio": e["folio"],
            "tipo_operacion": e["type"],
            "version": "1.1.4"
          };
          await postSale(data).then((answer) async {
            if (!answer.error) {
              log("venta asignada");
              await handler.updateSale(1,e["id"]);
            }
          });
        }
        prefs.dataSale = !(dataList.length == provider.currentAsync);
        provider.asyncProcess = false;
        log("Sincronizacion completa Ventas");
      }
    }
  }

  Future<void> setDataStop() async {
    if (provider.connectionStatus != 4) {
      Connection connection=Connection();
    await connection.init();
    log("latencia  ${connection.latency}");
    log("Verificando conexion Paradas${connection.stableConnection}");
//if(connection.stableConnection){
  if(true){
      provider.asyncProcess=true;
      provider.labelAsync="Sincronizando Ventas, no cierres la app.";
      List<Map<String, dynamic>> dataList =
          await handler.retrieveStopOff();
      provider.totalAsync=dataList.length;
      provider.currentAsync=0;
      log("-------%%${dataList.length.toString()}");
      for(var e in dataList){
        log("recorriendo el arreglo");
        provider.currentAsync++;
      Map<String,dynamic> data={
        "id_cliente": e["idCustomer"].toString(),
            "id_parada": e["idStop"],
            "lat": "${e["lat"]}",
            "lon": "${e["lng"]}",
            "id_data_origen": e["idOrigin"],
            "tipo": e["type"]
      };
      await postStop(data).then((answer) async {
            if (!answer.error){
              await handler.deleteStopId(data["id_cliente"]);
            }
          });
      
      }
      prefs.dataStop=!(dataList.length==provider.currentAsync);
      provider.asyncProcess=false;
      log("Sincronizacion completa Paradas");
    }
    }
  }
}
