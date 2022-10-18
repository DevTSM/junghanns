import 'dart:developer';

import 'package:junghanns/models/authorization.dart';
import 'package:junghanns/models/config.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/method_payment.dart';
import 'package:junghanns/models/refill.dart';
import 'package:junghanns/models/stop.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/auth.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/services/store.dart';

class Async {
  ProviderJunghanns provider;
  Async({required this.provider});
  Future<bool> init() async {
    provider.labelAsync = "Sincronizando datos, no cierres la app.";
    prefs.isAsyncCurrent = true;
    return await handler.deleteTable().then((value) async {
      provider.labelAsync = "Limpiando base de datos";
      provider.labelAsync = "Sincronizando servicios especiales";
      return getDataCustomerList("E", 1).then((value1) async {
        provider.labelAsync = "Sincronizando ruta";
        return getDataCustomerList("R", 2).then((value2) {
          provider.labelAsync = "Sincronizando segunda vuelta";
          return getDataCustomerList("S", 3).then((value3) {
            provider.labelAsync = "Sincronizando clientes llama";
            return getDataCustomerList("C", 4).then((value4) {
              provider.labelAsync = "Sincronizando paradas";
              return getDataStops().then((value5) {
                provider.labelAsync = "Sincronizando recargas";
                return getDataRefill().then((value6) {
                  prefs.isAsyncCurrent = false;
                  return true;
                });
              });
            });
          });
        });
      });
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
                                  }
                                  list.add(item);
                                });
                              }
                            });
                          }
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
}
