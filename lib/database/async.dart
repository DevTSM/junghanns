import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:junghanns/models/authorization.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/services/auth.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/services/store.dart';

class Async{
  List<CustomerModel> customerList=[];
getDataCustomerList(){
    customerList.clear();
    getListCustomer(prefs.idRouteD, DateTime.now(), "R").then((answer) async {
      if (!answer.error)  {
        for(var e in  answer.body){
          customerList.add(CustomerModel.fromList(e, prefs.idRouteD));
          List<AuthorizationModel>? authList=await getAuth(customerList.last);
          customerList.last.setAuth(authList??[]);
        }
      }
    });
  }
   Future<List<AuthorizationModel>?> getAuth(CustomerModel customerCurrent) async {
    List<AuthorizationModel> authList=[];
    try{
    await getAuthorization(customerCurrent.idClient, prefs.idRouteD)
        .then((answer) {
      if (!answer.error){
        for(var e in answer.body){
          authList.add(AuthorizationModel.fromService(e));
        }
      }
      return authList;
    });
    }catch(e){
      return authList;
    }
  }
}