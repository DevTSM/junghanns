import 'dart:developer';

import 'package:junghanns/models/customer.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/services/customer.dart';

class Async {
  Future<bool>init() async {
   return  await handler.deleteTable().then((value){
      return getDataCustomerList("E", 1).then((value1) async {
          return getDataCustomerList("R", 2).then((value2){
          return getDataCustomerList("S", 3).then((value3){
            return getDataCustomerList("C", 4).then((value4){
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
