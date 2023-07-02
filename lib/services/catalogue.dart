import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:junghanns/models/answer.dart';
import 'package:junghanns/preferences/global_variables.dart';

Future<Answer> getSchedules() async {
  log("/StoreServices <getSchedules>");
  try {
    var body = await http.get(Uri.parse("${prefs.urlBase}horarioentrega"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    },).timeout(Duration(seconds: timerDuration));
    return Answer.fromService(body,200,message: "Error inesperado");
  } catch (e) {
    log("/StoreServices <getSchedules> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}