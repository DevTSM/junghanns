import 'dart:developer';

import 'package:junghanns/models/customer.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/customer.dart';

class Async {
  ProviderJunghanns provider;
  Async({required this.provider});
  Future<bool>init() async {
    provider.labelAsync="Sincronizando datos, no cierres la app.";
   return  await handler.deleteTable().then((value){
    provider.labelAsync="Limpiando base de datos";
      return getDataCustomerList("E", 1).then((value1) async {
        provider.labelAsync="Sincronizando servicios especiales";
          return getDataCustomerList("R", 2).then((value2){
            provider.labelAsync="Sincronizando ruta";
          return getDataCustomerList("S", 3).then((value3){
            provider.labelAsync="Sincronizando segunda vuelta";
            return getDataCustomerList("C", 4).then((value4){
              provider.labelAsync="Sincronizando clientes llama";
          return true;
              });
          });
        });
      });
    });
  }

  Future<bool> getDataCustomerList(String type, int typeInt) async {
    List<CustomerModel> list = [];
    return await getListCustomer(prefs.idRouteD, DateTime.now(), type)
        .then((answer) async {
      if (prefs.token != "") {
        if (!answer.error) {
          for (var e in answer.body) {
            CustomerModel item = CustomerModel.fromState();
            item = CustomerModel.fromList(e, prefs.idRouteD, typeInt);
            await getDetailsCustomer(item.id, type).then((answer) async {
              if (!answer.error) {
                item =
                    CustomerModel.fromService(answer.body, item.id, item.type);
                list.add(item);
              }
            });
          }
          return await handler.insertUser(list).then((value){return true;});

        }else{
          log(answer.message);
          return false;
        }
      } else {
        //retornamos para cerrar la sesion
        return false;
      }
    });
  }
}
