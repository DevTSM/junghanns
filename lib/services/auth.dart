import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:junghanns/models/answer.dart';
import 'package:junghanns/preferences/global_variables.dart';

Future<Answer> getClientSecret(String user, String password) async {
  log("/AuthServices <getClientSecret>");
  try {
    var response = jsonDecode((await http.get(
      Uri.parse("$urlBase/token?q=secret&u=$user&p=$password"),
      headers: {
        "Content-Type": "aplication/json",
        "x-api-key": apiKey,
      },
    ))
        .body);
    if (response["client_secret"] != null) {
      log("/AuthServices <getClientSecret> Successfull ${response.toString()}");
      return Answer(body: response, message: "", error: false);
    } else {
      log("/AuthServices <getClientSecret> Fail ${response.toString()}");
      return Answer(body: response, message: response.toString(), error: true);
    }
  } catch (e) {
    log("/AuthServices <getClientSecret> Catch ${e.toString()}");
    return Answer(body: e, message: e.toString(), error: true);
  }
}

Future<Answer> getToken(String user) async {
  log("/AuthServices <getToken>");
  try {
    var response = jsonDecode((await http.get(
      Uri.parse("$urlBase/token?q=token&u=$user"),
      headers: {
        "Content-Type": "aplication/json",
        "x-api-key": apiKey,
        "client_secret": prefs.clientSecret,
      },
    ))
        .body);
    if (response["token"] != null) {
      log("/AuthServices <getToken> Successfull ${response.toString()}");
      return Answer(body: response, message: "", error: false);
    } else {
      log("/AuthServices <getToken> Fail ${response.toString()}");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/AuthServices <getToken> Catch ${e.toString()}");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}

Future<Answer> login(Map<String, dynamic> data) async {
  log("/AuthServices <login>");
  try {
    var response = jsonDecode((await http.post(Uri.parse("$urlBase/loginruta"),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
              "x-api-key": apiKey,
              "client_secret": prefs.clientSecret,
              "Authorization": "Bearer ${prefs.token}"
            },
            body: jsonEncode(data)))
        .body);
    if (response["id_usuario"] != null) {
      log("/AuthServices <login> Successfull ${response.toString()}");
      return Answer(body: response, message: "", error: false);
    } else {
      log("/AuthServices <login> Fail ${response.toString()}");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/AuthServices <login> Catch ${e.toString()}");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}

Future<Answer> getConfig(int id) async {
  log("/AuthServices <getConfig>");
  try {
    var response = jsonDecode((await http.get(
            Uri.parse("$urlBase/configruta?id_cliente=$id&q=distancia_km"),
            headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        }))
        .body);
    if (response != null) {
      log("/AuthServices <getConfig> Successfull $response");
      return Answer(body: response, message: "", error: false);
    } else {
      log("/AuthServices <getConfig> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          error: true);
    }
  } catch (e) {
    log("/AuthServices <getConfig> Catch ${e.toString()}");
    return Answer(
        body: e, message: "Algo salio mal, intentalo mas tarde.", error: true);
  }
}

Future<Answer> getFolio(String folio) async {
  log("/AuthServices <getFolio>");
  var response = await http
      .get(Uri.parse("$urlBase/validate?q=folio&num=$folio"), headers: {
    "Content-Type": "aplication/json",
    "x-api-key": apiKey,
    "client_secret": prefs.clientSecret,
    "Authorization": "Bearer ${prefs.token}",
  });
  log("${response.statusCode}");
  if (response.statusCode == 200) {
    log("/AuthServices <getFolio> Successfull, ${response.body}");
    return Answer(body: jsonDecode(response.body), message: "", error: false);
  } else {
    log("/AuthServices <getFolio> Fail, ${response.body}");
    return Answer(body: response, message: response.body, error: true);
  }
}
