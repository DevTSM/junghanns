import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/models/answer.dart';
import 'package:http/http.dart' as http;
import 'package:junghanns/preferences/global_variables.dart';

Future<Answer> getListCustomer(int idR, DateTime date, String type) async {
  log("/CustomerServices <getListCustomer>");
  try {
    var response = await http.get(
        Uri.parse(
            "${prefs.urlBase}visita?idRuta=$idR&date=${(DateFormat('yyyyMMdd').format(date))}&tipo=$type"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        });
    return Answer.fromService(response,200);
  } catch (e) {
    log("/CustomerServices <getListCustomer> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}

Future<Answer> getDetailsCustomer(int id, String type) async {
  log("/CustomerServices <getDetailsCustomer>");
  try {
    var response = await http.get(
        Uri.parse("${prefs.urlBase}cliente?q=dashboard&tipo=$type&id=$id"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        });
    log("/CustomerServices <getDetailsCustomer>");
    return Answer.fromService(response,200);
  } catch (e) {
    log("/CustomerServices <getDetailsCustomer> Catch");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}

Future<Answer> getPhonesCustomer(int id) async {
  log("/CustomerServices <getPhonesCustomer>");
  try {
    var response = await http
        .get(Uri.parse("${prefs.urlBase}cliente?q=tel&id=$id"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    });
    log("/CustomerServices <getPhonesCustomer>");
    return Answer.fromService(response,200);
  } catch (e) {
    log("/CustomerServices <getPhonesCustomer> Catch");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}
Future<Answer> getCreditos(int id) async {
  log("/CustomerServices <getCreditos>");
  try {
    var response = await http
        .get(Uri.parse("${prefs.urlBase}credit?idCliente=$id"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    });
    return Answer.fromService(response,200);
  } catch (e) {
    log("/CustomerServices <getCreditos> Catch");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}

////////////////////
Future<Answer> getHistoryCustomer(int id) async {
  log("/CustomerServices <getHistoryCustomer>");
  try {
    var response = await http
        .get(Uri.parse("${prefs.urlBase}cliente?q=history&id=$id"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    });
    if (response.statusCode == 200) {
      log("/CustomerServices <getHistoryCustomer> Successfull ${jsonDecode(response.body)}");
      return Answer(
          body: jsonDecode(response.body),
          message: "",
          status: response.statusCode,
          error: false);
    } else {
      log("/CustomerServices <getHistoryCustomer> Fail");
      return Answer(
          body: response,
          message: "Algo salio mal con el historial, intentalo mas tarde.",
          status: response.statusCode,
          error: true);
    }
  } catch (e) {
    log("/CustomerServices <getHistoryCustomer> Catch");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}

Future<Answer> getMoneyCustomer(int id) async {
  log("/CustomerServices <getMoneyCustomer>");
  try {
    var response = await http
        .get(Uri.parse("${prefs.urlBase}cliente?q=money&id=$id"), headers: {
      "Content-Type": "aplication/json",
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    });
    if (response.statusCode == 200) {
      log("/CustomerServices <getMoneyCustomer> Successfull ${jsonDecode(response.body)}");
      return Answer(
          body: jsonDecode(response.body),
          message: "",
          status: response.statusCode,
          error: false);
    } else {
      log("/CustomerServices <getMoneyCustomer> Fail");
      return Answer(
          body: response,
          message: "No fue posible obtener el saldo, intentalo mas tarde.",
          status: response.statusCode,
          error: true);
    }
  } catch (e) {
    log("/CustomerServices <getMoneyCustomer> Catch");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}
