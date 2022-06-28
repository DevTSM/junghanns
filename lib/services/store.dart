 import 'dart:convert';
import 'dart:developer';

import 'package:junghanns/models/answer.dart';
import 'package:http/http.dart' as http;

import '../preferences/global_variables.dart';
 Future<Answer> getProductList()async {
  log("/StoreServices <getProductList>");
  try{
  var response= jsonDecode((await http.get(Uri.parse("$urlBase/index.php/almacenmovil?q=service&idRuta=21"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key":apiKey,
      "client_secret":clientSecret,
      "Authorization": "Bearer " + "caf048dc9e6560d05fe75f8d00ee4c48db607654",
    })).body);
    if(response!=null){
      log("/StoreServices <getProductList> Successfull");
      return Answer(body: response, message: "", error: false);
    }else{
      log("/StoreServices <getProductList> Fail");
      return Answer(body: response, message: "Algo salio mal, intentalo mas tarde.", error: true);
    }
  }catch(e){
    log("/StoreServices <getProductList> Catch ${e.toString()}");
      return Answer(body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}
Future<Answer> getRefillList()async {
  log("/StoreServices <getRefillList>");
  try{
  var response= jsonDecode((await http.get(Uri.parse("$urlBase/index.php/almacenmovil?q=recarga&idRuta=1"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key":apiKey,
      "client_secret":clientSecret,
      "Authorization": "Bearer " + "caf048dc9e6560d05fe75f8d00ee4c48db607654",
    })).body);
    if(response!=null){
      log("/StoreServices <getRefillList> Successfull ${response.toString()}");
      return Answer(body: response, message: "", error: false);
    }else{
      log("/StoreServices <getRefillList> Fail");
      return Answer(body: response, message: "Algo salio mal, intentalo mas tarde.", error: true);
    }
  }catch(e){
    log("/StoreServices <getRefillList> Catch ${e.toString()}");
      return Answer(body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}