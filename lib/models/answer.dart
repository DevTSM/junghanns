import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';
import 'package:junghanns/preferences/global_variables.dart';

class Answer {
  dynamic body;
  String message;
  bool error;
  Answer({required this.body, required this.message, required this.error});
  factory Answer.fromService(Response response, {String? message}) {
    try {
      if (response.statusCode < 400) {
        log("/Respuesta exitosa");
        if (response.statusCode == 204) {
          return Answer(
              body: {[]}, message: message ?? "Sin datos", error: true);
        } else {
          dynamic body = jsonDecode(response.body);
          return Answer(
              body: body,
              message: message ?? "Respuesta Exitosa",
              error: false);
        }
      } else {
        log("/Respuesta fallida");
        if (response.statusCode == 403 || response.statusCode == 401) {
          prefs.prefs!.clear();
        }
        dynamic body = jsonDecode(response.body);
        return Answer(
            body: body,
            message:
                body["message"] ?? "Código de error ${response.statusCode}",
            error: true);
      }
    } catch (e) {
      log("/Error en respuesta");
      return Answer(body: {"error": ""}, message: e.toString(), error: true);
    }
  }
}
