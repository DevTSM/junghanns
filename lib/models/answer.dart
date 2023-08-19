import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';
import 'package:junghanns/preferences/global_variables.dart';
class Answer {
  dynamic body;
  String message;
  int status;
  bool error;
  Answer(
      {required this.body,
      required this.message,
      required this.status,
      required this.error});
  ///TODO: agregar estatus de post y create
  ///201 respuesta exitosa
  ///get
  ///200
  factory Answer.fromService(Response response, int statusOk,{String? message}) {
    try{
    log("Status => ${response.statusCode} ${response.body.toString()}");

    if(response.statusCode==statusOk){
      log("/Respuesta exitosa");
      dynamic body = jsonDecode(response.body);
      return Answer(
                body: body,
                message: "Respuesta Exitosa",
                status: response.statusCode,
                error: false);
    }else{
      if(response.statusCode>=100&&response.statusCode<=199){
        log("/Respuesta informativa");
        return Answer(
                body: response.body,
                message: "Respuesta informativa",
                status: response.statusCode,
                error: true);
      }
      if(response.statusCode>=200&&response.statusCode<=299){
        log("/Respuesta satisfactoria");
        if (response.statusCode == 203) {
          log("/Respuesta Non-Authoritative Information");
          String urlBaseSafe = prefs.urlBase;
          String nameCEDIS = prefs.labelCedis;
          prefs.prefs!.clear();
          prefs.version = version;
          prefs.urlBase = urlBaseSafe;
          prefs.labelCedis = nameCEDIS;
          return Answer(
              body: {},
              message: "Código de error ${response.statusCode}",
              status: response.statusCode,
              error: true);
        }
        if (response.statusCode == 204) {
            return Answer(
                body: {[]},
                message: "Sin datos",
                status: response.statusCode,
                error: true);
          }
        dynamic body = jsonDecode(response.body);
        return Answer(
                body: response.body,
                message: body["message"] ?? "La solicitud se proceso correctamente, pero jusoft la rechazo o cancelo la operación",
                status: response.statusCode,
                error: true);
      }
      if(response.statusCode>=400&&response.statusCode<=499){
        log("/Respuesta fallida");
        if (response.statusCode == 403 || response.statusCode == 401) {
          String urlBaseSafe = prefs.urlBase;
          String nameCEDIS = prefs.labelCedis;
          prefs.prefs!.clear();
          prefs.version = version;
          prefs.urlBase = urlBaseSafe;
          prefs.labelCedis = nameCEDIS;
        }
        dynamic body = jsonDecode(response.body);
        return Answer(
                body: response.body,
                message: response.statusCode==422?(body.map((e)=>e["message"]).toString()).toString():body["message"] ?? "Código de error ${response.statusCode}",
                status: response.statusCode,
                error: true);
      }
      dynamic body = jsonDecode(response.body);
        return Answer(
                body: response.body,
                message: response.statusCode==422?(body.map((e)=>e["message"]).toString()).toString():body["message"] ?? "Código de error ${response.statusCode}",
                status: response.statusCode,
                error: true);
    }
    }catch(e){
      log("/Error en respuesta");
      return Answer(
          body: {"error": ""},
          message: "Error inesperado: $e",
          status: 1001,
          error: true);
    }
  }

  //////Recobery
  ///factory Answer.fromService(Response response, int statusOk,{String? message}) {
  //   log("Status => ${response.statusCode}");
  //   try {
  //     if (response.statusCode < 400) {
  //       if (response.statusCode == 203) {
  //         log("/Respuesta fallida");
  //         String urlBaseSafe = prefs.urlBase;
  //         String nameCEDIS = prefs.labelCedis;
  //         prefs.prefs!.clear();
  //         prefs.version = version;
  //         prefs.urlBase = urlBaseSafe;
  //         prefs.labelCedis = nameCEDIS;
  //         return Answer(
  //             body: {},
  //             message: "Código de error ${response.statusCode}",
  //             status: response.statusCode,
  //             error: true);
  //       } else {
  //         log("/Respuesta exitosa");
  //         if (response.statusCode == 204) {
  //           return Answer(
  //               body: {[]},
  //               message: "Sin datos",
  //               status: response.statusCode,
  //               error: true);
  //         } else {
  //           dynamic body = jsonDecode(response.body);
  //           return Answer(
  //               body: body,
  //               message: "Respuesta Exitosa",
  //               status: response.statusCode,
  //               error: false);
  //         }
  //       }
  //     } else {
  //       log("/Respuesta fallida");
  //       if (response.statusCode == 403 || response.statusCode == 401) {
  //         String urlBaseSafe = prefs.urlBase;
  //         String nameCEDIS = prefs.labelCedis;
  //         prefs.prefs!.clear();
  //         prefs.version = version;
  //         prefs.urlBase = urlBaseSafe;
  //         prefs.labelCedis = nameCEDIS;
  //       }
  //       dynamic body = jsonDecode(response.body);
  //       log(response.statusCode.toString());
  //       log(body.toString());
  //       return Answer(
  //           body: body,
  //           message:
  //               response.statusCode==422?(body.map((e)=>e["message"]).toString()).toString():body["message"] ?? "Código de error ${response.statusCode}",
  //           status: response.statusCode,
  //           error: true);
  //     }
  //   } catch (e) {
  //     //Para catch el status es 1001 y catch en request es 1002
  //     log("/Error en respuesta");
  //     return Answer(
  //         body: {"error": ""},
  //         message: "Error inesperado: $e",
  //         status: 1001,
  //         error: true);
  //   }
  // }
}
