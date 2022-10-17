import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:junghanns/models/answer.dart';
import 'package:junghanns/models/authorization.dart';
import 'package:junghanns/preferences/global_variables.dart';

Future<Answer> getTokenKernel(String user, String cedis) async {
  log("/AuthServices <getTokenKernel>");
  try {
    var responseAwait = await http.post (
      Uri.parse("https://junghannskernel.com/token"),
      headers: {
        "Content-Type": "aplication/json",
        "x-api-key": apiKey,
      },
      body: jsonEncode({
    "telefono": user,
    "cedis": cedis,
    "app": "APP JUNGHANNS DELIVERY"
})
    );
    log(responseAwait.body);
    var response=jsonDecode(responseAwait.body);
    if (response["code"] != null) {
      log("/AuthServices <getTokenKernel> Successfull ${response.toString()}");
      return Answer(body: response, message: "", error: false);
    } else {
      log("/AuthServices <getTokenKernel> Fail ${response.toString()}");
      return Answer(body: response, message: response.toString(), error: true);
    }
  } catch (e) {
    log("/AuthServices <getTokenKernel> Catch ${e.toString()}");
    return Answer(body: e, message: e.toString(), error: true);
  }
}

Future<Answer> tokenKernelActive(String token,double lat,double lng) async {
  log("/AuthServices <tokenKernelActive>");
  try {
    var responseAwait = await http.put(
      Uri.parse("https://junghannskernel.com/activacion"),
      headers: {
        HttpHeaders.contentTypeHeader:
                      'application/json; charset=UTF-8',
        "x-api-key": "4c190588c5f7dd27369308c1c1c4545924ddd02d",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
    "lat" : "19.30008262123766",
    "lon": "-99.11182636452587"
})
    );
    log("lat: $lat,lon: $lng,");
    log(responseAwait.body);
    var response=jsonDecode(responseAwait.body);
    if (responseAwait.statusCode==200) {
      log("/AuthServices <tokenKernelActive> Successfull");
      return Answer(body: response, message: "", error: false);
    } else {
      log("/AuthServices <tokenKernelActive> Fail ${response.toString()}");
      return Answer(body: response, message: response.toString(), error: true);
    }
  } catch (e) {
    log("/AuthServices <tokenKernelActive> Catch ${e.toString()}");
    return Answer(body: e, message: e.toString(), error: true);
  }
}

Future<Answer> validateOTP(String token,String code,double lat,double lng) async {
  log("/AuthServices <validateOTP>");
  try {
    var responseAwait = await http.put(
      Uri.parse("https://junghannskernel.com/otp"),
      headers: {
        "Content-Type": "aplication/json",
        "x-api-key": apiKey,
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "code":code,
    "lat": lat.toString(),
    "lon": lng.toString(),
})
    );
    log(responseAwait.body);
    var response=jsonDecode(responseAwait.body);
    if (responseAwait.statusCode==200) {
      log("/AuthServices <validateOTP> Successfull");
      return Answer(body: response, message: "", error: false);
    } else {
      log("/AuthServices <validateOTP> Fail ${response.toString()}");
      return Answer(body: response, message: response.toString(), error: true);
    }
  } catch (e) {
    log("/AuthServices <validateOTP> Catch ${e.toString()}");
    return Answer(body: e, message: e.toString(), error: true);
  }
}

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
