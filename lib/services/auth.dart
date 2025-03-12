import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:junghanns/models/answer.dart';
import 'package:junghanns/preferences/global_variables.dart';

Future<Answer> getClientSecret(String user, String password) async {
  log("/AuthServices <getClientSecret>");

  final uri = Uri.parse("${prefs.urlBase}token?q=secret&u=$user&p=$password");
  log("Request URL: $uri");

  try {
    var response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": apiKey,
      },
    );

    log("Response Status: ${response.statusCode}");
    log("Response Body: ${response.body}");

    return Answer.fromService(response, response.statusCode);
  } catch (e) {
    log("/AuthServices <getClientSecret> Catch ${e.toString()}");
    return Answer(
      body: e.toString(),
      message: "Conexión inestable con el back jusoft",
      status: 1002,
      error: true,
    );
  }
}

/*Future<Answer> getClientSecret(String user, String password) async {
  log("/AuthServices <getClientSecret>");
  try {
    var body = await http.get(
      Uri.parse("${prefs.urlBase}token?q=secret&u=$user&p=$password"),
      headers: {
        "Content-Type": "aplication/json",
        "x-api-key": apiKey,
      },
    );
    return Answer.fromService(body,200);
  } catch (e) {
    log("/AuthServices <getClientSecret> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back jusoft",
        status: 1002,
        error: true);
  }
}*/

Future<Answer> login(Map<String, dynamic> data) async {
  log("/AuthServices <login>");
  try {
    var response = await http.post(Uri.parse("${prefs.urlBase}loginruta"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}"
        },
        body: jsonEncode(data));
    return Answer.fromService(response,200);
  } catch (e) {
    log("/AuthServices <login> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexion inestable con el back jusoft",
        status: 1002,
        error: true);
  }
}

//////////////
Future<Answer> getTokenKernel(String user, String cedis) async {
  log("/AuthServices <getTokenKernel>");
  try {
    var responseAwait = await http.post(
        Uri.parse("https://junghannskernel.com/token"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
        },
        body: jsonEncode({
          "telefono": user,
          "cedis": cedis,
          "app": "APP JUNGHANNS DELIVERY"
        }));
    var response = jsonDecode(responseAwait.body);
    if (response["code"] != null) {
      log("/AuthServices <getTokenKernel> Successfull");
      return Answer(
          body: response,
          message: "",
          status: responseAwait.statusCode,
          error: false);
    } else {
      log("/AuthServices <getTokenKernel> Fail ${response.toString()}");
      return Answer(
          body: response,
          message: response.toString(),
          status: responseAwait.statusCode,
          error: true);
    }
  } catch (e) {
    log("/AuthServices <getTokenKernel> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}

Future<Answer> tokenKernelActive(String token, double lat, double lng) async {
  log("/AuthServices <tokenKernelActive> ${{"lat": lat, "lon": lng}} Bearer $token");
  try {
    var responseAwait =
        await http.put(Uri.parse("https://junghannskernel.com/activacion"),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
              "x-api-key": "4c190588c5f7dd27369308c1c1c4545924ddd02d",
              "Authorization": "Bearer $token"
            },
            body: jsonEncode({"lat": lat, "lon": lng}));
    var response = jsonDecode(responseAwait.body);
    if (responseAwait.statusCode == 200) {
      log("/AuthServices <tokenKernelActive> Successfull");
      return Answer(
          body: response,
          message: "",
          status: responseAwait.statusCode,
          error: false);
    } else {
      log("/AuthServices <tokenKernelActive> Fail $response");
      return Answer(
          body: response,
          message: response["message"] ?? "",
          status: responseAwait.statusCode,
          error: true);
    }
  } catch (e) {
    log("/AuthServices <tokenKernelActive> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}



Future<Answer> getToken(String user) async {
  log("/AuthServices <getToken>");
  try {
    var responseAwait = await http.get(
      Uri.parse("${prefs.urlBase}token?q=token&u=$user"),
      headers: {
        "Content-Type": "aplication/json",
        "x-api-key": apiKey,
        "client_secret": prefs.clientSecret,
      },
    );
    var response = jsonDecode(responseAwait.body);
    if (response["token"] != null) {
      log("/AuthServices <getToken> Successfull");
      return Answer(
          body: response,
          message: "",
          status: responseAwait.statusCode,
          error: false);
    } else {
      log("/AuthServices <getToken> Fail ${response.toString()}");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          status: responseAwait.statusCode,
          error: true);
    }
  } catch (e) {
    log("/AuthServices <getToken> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}

Future<Answer> updateToken(String toke) async {
  log("/AuthServices <updateToken>");
  try {
    var response = await http.put(Uri.parse("${prefs.urlBase}notifymobile"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}"
        },
        body: jsonEncode({"token": toke}));
    if (response.statusCode == 200) {
      log("/AuthServices <updateToken> Successfull");
      return Answer(
          body: response,
          message: "",
          status: response.statusCode,
          error: false);
    } else {
      log("/AuthServices <updateToken> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          status: response.statusCode,
          error: true);
    }
  } catch (e) {
    log("/AuthServices <updateToken> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}

Future<Answer> getConfig(int id) async {
  log("/AuthServices <getConfig>");
  try {
    var response1 = await http.get(
        Uri.parse("${prefs.urlBase}configruta?id_cliente=$id&q=distancia_km"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        }).timeout(Duration(seconds: timerDuration));
    var response = jsonDecode(response1.body);
    if (response != null) {
      log("/AuthServices <getConfig> Successfull $response");
      return Answer(
          body: response,
          message: "",
          status: response1.statusCode,
          error: false);
    } else {
      log("/AuthServices <getConfig> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal, intentalo mas tarde.",
          status: response1.statusCode,
          error: true);
    }
  } catch (e) {
    log("/AuthServices <getConfig> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}

Future<Answer> getFolio(String folio, int idProduct, int idRoute) async {
  log("/AuthServices <getFolio>");
  try {
    var response = await http.get(
        Uri.parse(
            "${prefs.urlBase}validate?q=folio_ruta&num=$folio&id_ruta=$idRoute&id_ps=$idProduct"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        });
    if (response.statusCode == 200) {
      log("/AuthServices <getFolio> Successfull, ${response.body}");
      return Answer(
          body: jsonDecode(response.body),
          message: "",
          status: response.statusCode,
          error: false);
    } else {
      log("/AuthServices <getFolio> Fail, ${response.body}");
      return Answer(
          body: response,
          message: response.body,
          status: response.statusCode,
          error: true);
    }
  } catch (e) {
    return Answer(
        body: {"error": e},
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}
//////
Future<Answer> validateOTP(
    String token, String code, double lat, double lng) async {
  log("/AuthServices <validateOTP>");
  try {
    var responseAwait =
        await http.put(Uri.parse("https://junghannskernel.com/otp"),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
              "x-api-key": "4c190588c5f7dd27369308c1c1c4545924ddd02d",
              "Authorization": "Bearer $token"
            },
            body: jsonEncode({
              "code": code,
              "lat": lat.toString(),
              "lon": lng.toString(),
            }));
            return Answer.fromService(responseAwait, 200);
  } catch (e) {
    log("/AuthServices <validateOTP> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}