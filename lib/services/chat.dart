// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart'; // Asegúrate de importar 'path'

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:junghanns/models/answer.dart';

import '../preferences/global_variables.dart';

////////////////////////////////////////////
Future<Answer> sendMessageService({
   int? idRuta,
   String? fechaOperacion,
  required String mensaje,
}) async {
  log("/StoreServices <sendMessage>");
  Map<String, dynamic> body = {
    "id_ruta": idRuta,
    "fecha_envio": fechaOperacion,
    "mensaje": mensaje,
  };

  log("Request: $body");

  try {
    var response = await http.post(
      Uri.parse("${prefs.urlBase}chat"), // Asegúrate de que esta URL es la correcta
      headers: {
        "Content-Type": "application/json",
        "x-api-key": apiKey,
        "client_secret": prefs.clientSecret,
        "Authorization": "Bearer ${prefs.token}",
      },
      body: jsonEncode(body),
    ).timeout(Duration(seconds: timerDuration));

    if (response.statusCode == 201) {
      var decodedBody = jsonDecode(response.body);
      log("/StoreServices <sendMessage> Successfull");
      log("Response Body: $decodedBody");
      return Answer(body: decodedBody, message: "Mensaje enviado exitosamente", status: response.statusCode, error: false);
    } else {
      var decodedBody = jsonDecode(response.body);
      log("/StoreServices <sendMessage> Fail");
      log("Response Body: $decodedBody");
      return Answer(
        body: response,
        message: "No se pudo enviar el mensaje. Revisa tu conexión a internet.",
        status: response.statusCode,
        error: true,
      );
    }
  } catch (e) {
    log("/StoreServices <sendMessage> Catch ${e.toString()}");
    return Answer(
      body: e,
      message: "Conexión inestable con el back",
      status: 1002,
      error: true,
    );
  }
}

/*Future<Answer> sendMessageServiceFile({
  int? idRuta,
  String? fechaOperacion,
  required File archivo, // Aceptamos el archivo
}) async {
  log("/StoreServices <sendMessage>");

  // Verificar la ruta del archivo
  print('File path: ${archivo.path}');
  print('File exists: ${archivo.existsSync()}'); // Verifica si el archivo existe

  // Obtener solo el nombre del archivo (sin la ruta completa)
  String fileName = basename(archivo.path);
  print('File Name: $fileName');

  // Crear un MultipartRequest
  var uri = Uri.parse("${prefs.urlBase}chat");

  var request = http.MultipartRequest("POST", uri)
    ..headers.addAll({
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
      "Content-Type": "multipart/form-data", // Agregar tipo de contenido adecuado
    })
    ..fields["id_ruta"] = idRuta.toString()
    ..fields["fecha_envio"] = fechaOperacion ?? '';

  // Imprimir los campos de la solicitud
  print('Request Fields:');
  print('id_ruta: ${idRuta.toString()}');
  print('fecha_envio: ${fechaOperacion ?? 'No se proporcionó fecha'}');

  // Verificar si el archivo tiene una ruta no vacía antes de agregarlo
  if (archivo.existsSync() && archivo.path.isNotEmpty) {
    print("File to send: $fileName");

    // Verifica si el archivo realmente existe antes de enviarlo
    if (await archivo.exists()) {
      // Enviar el archivo usando MultipartFile.fromPath
      request.files.add(await http.MultipartFile.fromPath('archivo', archivo.path));
      print("Archivo añadido al request.");
    } else {
      print("El archivo no existe en la ruta proporcionada.");
    }
  } else {
    print("No file selected!");
  }

  // Verifica los archivos que se van a enviar
  print("Files in request:");
  request.files.forEach((file) {
    print("File: ${file.filename}, Size: ${file.length}");
  });

  // Verificar las cabeceras de la solicitud
  print("Request Headers:");
  request.headers.forEach((key, value) {
    print('$key: $value');
  });

  try {
    var response = await request.send().timeout(Duration(seconds: timerDuration));

    if (response.statusCode == 201) {
      var responseBody = await response.stream.bytesToString();
      var decodedBody = jsonDecode(responseBody);
      log("/StoreServices <sendMessage> Successfull");
      log("Response Body: $decodedBody");

      return Answer(
        body: decodedBody,
        message: "Mensaje con archivo enviado exitosamente",
        status: response.statusCode,
        error: false,
      );
    } else {
      var responseBody = await response.stream.bytesToString();
      var decodedBody = jsonDecode(responseBody);
      log("/StoreServices <sendMessage> Fail");
      log("Response Body: $decodedBody");

      return Answer(
        body: response,
        message: "No se pudo enviar el archivo. Revisa tu conexión a internet.",
        status: response.statusCode,
        error: true,
      );
    }
  } catch (e) {
    log("/StoreServices <sendMessage> Catch ${e.toString()}");
    return Answer(
      body: e,
      message: "Conexión inestable con el back",
      status: 1002,
      error: true,
    );
  }
}*/
Future<Answer> sendMessageServiceFile({
  int? idRuta,
  String? fechaOperacion,
  required List<File> archivos, // Aceptamos una lista de archivos
}) async {
  log("/StoreServices <sendMessage>");

  // Verificar si los archivos no están vacíos
  if (archivos.isEmpty) {
    print("No files selected!");
    return Answer(
      body: null,
      message: "No se seleccionaron archivos.",
      status: 1001,
      error: true,
    );
  }

  // Crear un MultipartRequest
  var uri = Uri.parse("${prefs.urlBase}chat");

  var request = http.MultipartRequest("POST", uri)
    ..headers.addAll({
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
      "Content-Type": "multipart/form-data", // Agregar tipo de contenido adecuado
    })
    ..fields["id_ruta"] = idRuta.toString()
    ..fields["fecha_envio"] = fechaOperacion ?? '';

  // Imprimir los campos de la solicitud
  print('Request Fields:');
  print('id_ruta: ${idRuta.toString()}');
  print('fecha_envio: ${fechaOperacion ?? 'No se proporcionó fecha'}');

  // Agregar archivos al request
  for (var archivo in archivos) {
    // Verificar si el archivo tiene una ruta válida antes de agregarlo
    if (archivo.existsSync() && archivo.path.isNotEmpty) {
      String fileName = basename(archivo.path);
      print("File to send: $fileName");

      // Enviar el archivo usando MultipartFile.fromPath
      if (await archivo.exists()) {
        request.files.add(await http.MultipartFile.fromPath('archivo[]', archivo.path));
        print("Archivo añadido al request.");
      } else {
        print("El archivo no existe en la ruta proporcionada: $fileName");
      }
    } else {
      print("Archivo vacío o no válido.");
    }
  }

  // Verifica los archivos que se van a enviar
  print("Files in request:");
  request.files.forEach((file) {
    print("File: ${file.filename}, Size: ${file.length}");
  });

  // Verificar las cabeceras de la solicitud
  print("Request Headers:");
  request.headers.forEach((key, value) {
    print('$key: $value');
  });

  try {
    var response = await request.send().timeout(Duration(seconds: timerDuration));

    if (response.statusCode == 201) {
      var responseBody = await response.stream.bytesToString();
      var decodedBody = jsonDecode(responseBody);
      log("/StoreServices <sendMessage> Successful");
      log("Response Body: $decodedBody");

      return Answer(
        body: decodedBody,
        message: "Mensaje con archivos enviados exitosamente",
        status: response.statusCode,
        error: false,
      );
    } else {
      var responseBody = await response.stream.bytesToString();
      var decodedBody = jsonDecode(responseBody);
      log("/StoreServices <sendMessage> Fail");
      log("Response Body: $decodedBody");

      return Answer(
        body: response,
        message: "No se pudo enviar los archivos. Revisa tu conexión a internet.",
        status: response.statusCode,
        error: true,
      );
    }
  } catch (e) {
    log("/StoreServices <sendMessage> Catch ${e.toString()}");
    return Answer(
      body: e,
      message: "Conexión inestable con el back",
      status: 1002,
      error: true,
    );
  }
}



/////////////////////
Future<Answer> getMessagesService({DateTime? date, int? idChat}) async {
  log("/StoreServices <getMessages>");
  Map<String, dynamic> params = {};

  // Si hay una fecha proporcionada
  if (date != null) {
    params["fecha"] = (date.millisecondsSinceEpoch ~/ 1000);
  } /*else {
    *//*DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
    params["fecha"] = (yesterday.millisecondsSinceEpoch ~/ 1000);*//*
    // Toma la fecha actual si no se proporciona ninguna
    params["fecha"] = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
  }*/

  // Imprimir la URL generada antes de realizar la solicitud
  String url = "${prefs.urlBase}chat?q=conversacion&id_chat=${idChat}&f_inicio=${params['fecha']}";


  log("URL generada: $url");

  try {
    var response = await http.get(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "x-api-key": apiKey,
        "client_secret": prefs.clientSecret,
        "Authorization": "Bearer ${prefs.token}",
      },
    ).timeout(Duration(seconds: timerDuration));

    log("${response.body} -----");
    return Answer.fromService(response, 200);
  } catch (e) {
    log("/CustomerServices <getMessages> Catch ${e.toString()}");
    return Answer(
        body: {"error": e.toString()},
        message: "Conexion inestable con el back",
        status: 1002,
        error: true);
  }
}
////////////////////////
Future<Answer> putStatus({required String action, required String idM}) async {
  log("/StoreServices <putStatus> ¡");
  try {
    Map<String, dynamic> body = {
      "action": action,
      "id_mensaje": idM,
    };

    // Si la acción es 'R' y el comentario no es nulo ni vacío, agregarlo al cuerpo
    // Imprimir el cuerpo antes de enviarlo
    log("Body enviado mensaje recivido: ${jsonEncode(body)}");

    var response = await http.put(Uri.parse("${prefs.urlBase}chat"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        },
        // Verificar lso datos
        body: jsonEncode(body) );
    log("/StoreServices <postValidated>");
    return Answer.fromService(response,201);
  } catch (e) {
    log("/StoreServices <putStatus> Catch");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexión a internet.",
        status: 1002,
        error: true);
  }
}
////////////

Future<Answer> getValidationList({
  required int idR,
  String? type,
}) async {
  log("/StoreServices <getValidationList>");

  // Construir la URL base
  String url = "${prefs.urlBase}almacenmovil?q=EstatusValidacion&id_ruta=$idR";

  // Si 'type' no es null, agregar el parámetro tipo_validacion
  if (type != null) {
    url += "&tipo_validacion=$type";
  }

  try {
    var response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        }).timeout(Duration(seconds: timerDuration));

    if (response.statusCode == 200) {
      var decodedBody = jsonDecode(response.body);
      log("/StoreServices <getValidationList> Successfull");
      log("Response Body: $decodedBody");
      return Answer(
          body: decodedBody,
          message: "",
          status: response.statusCode,
          error: false
      );
    } else {
      var decodedBody = jsonDecode(response.body);
      log("/StoreServices <getValidationList> Fail");
      log("Response Body: $decodedBody");
      return Answer(
          body: decodedBody,
          message: "Algo salió mal, intentalo más tarde.",
          status: response.statusCode,
          error: true
      );
    }
  } catch (e) {
    log("/StoreServices <getValidationList> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexión inestable con el back",
        status: 1002,
        error: true
    );
  }
}

Future<Answer> putValidated({required String action, required int idV, required double lat, required double lng, required String status, String ?comment}) async {
  log("/StoreServices <postValidated> ¡");
  try {
    Map<String, dynamic> body = {
      "action": action,
      "id_validacion": idV,
      "lat": lat.toString(),
      "lon": lng.toString(),
      "estatus": status,
    };

    // Si la acción es 'R' y el comentario no es nulo ni vacío, agregarlo al cuerpo
    if (status == 'R' && comment != null && comment.isNotEmpty) {
      body["comentario"] = comment;
    }
    // Imprimir el cuerpo antes de enviarlo
    log("Body enviado: ${jsonEncode(body)}");

    var response = await http.put(Uri.parse("${prefs.urlBase}almacenmovil"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        },
        // Verificar lso datos
        body: jsonEncode(body) );
    log("/StoreServices <postValidated>");
    return Answer.fromService(response,201);
  } catch (e) {
    log("/StoreServices <postValidated> Catch");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexión a internet.",
        status: 1002,
        error: true);
  }
}
Future<Answer> postDelivery({
  required int idR,
  required double lat,
  required double lon,
  required String equipo,
  required String marca,
  required String modelo,
  int ? idDestination,
  required Map<String, dynamic> entrega,
}) async {
  log("/StoreServices <postDelivery> ¡");

  try {
    // Construir el cuerpo de la petición
    Map<String, dynamic> body = {
      "id_ruta": idR,
      "lat": lat.toString(), // Convertir los doubles a String
      "lon": lon.toString(),
      "equipo": equipo,
      'marca': marca,
      'modelo': modelo,
      "entrega": entrega, // Pasar directamente el Map de la entrega
    };

    if (idDestination != null || idDestination != 0) {
      body["id_ruta_destino"] = idDestination;
    }

    // Imprimir el cuerpo antes de enviarlo
    log("Body enviado: ${jsonEncode(body)}");

    // Realizar la petición POST
    var response = await http.post(
      Uri.parse("${prefs.urlBase}almacenmovil"),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        "x-api-key": apiKey,
        "client_secret": prefs.clientSecret,
        "Authorization": "Bearer ${prefs.token}",
      },
      body: jsonEncode(body),
    );

    log("/StoreServices <postDelivery>");
    var dataOTP = jsonDecode(response.body);
    log("Estatus code ${response.statusCode} body ${response.body}");
    if (response.statusCode == 201) {
      log("/StoreServices <postDelivery> Successfull, ${response.body}");
      return Answer(body: jsonDecode(response.body), message: "",status: response.statusCode, error: false);
    } else {
      log("/StoreServices <postDelivery> Fail");
      return Answer(
        body: response.body,
        message: dataOTP['message'],
        status: response.statusCode,
        error: true,
      );
    }
  } catch (e) {
    log("/StoreServices <postDelivery> Catch");
    return Answer(
      body: e.toString(),
      message: "Algo salió mal, revisa tu conexión a internet.",
      status: 1002,
      error: true,
    );
  }
}
Future<Answer> deleteReceiption({required int idV, String? comment, required double lat, required double lng}) async {
  log("/StoreServices <deleteValidated> ¡");
  try {
    Map<String, dynamic> body = {
      "id_validacion": idV,
      "comentario": comment,
      "lat": lat.toString(),
      "lon": lng.toString(),
    };

    // Imprimir el cuerpo antes de enviarlo
    log("Body enviado: ${jsonEncode(body)}");

    var response = await http.delete(Uri.parse("${prefs.urlBase}almacenmovil"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        },
        // Verificar lso datos
        body: jsonEncode(body) );
    log("/StoreServices <deleteValidated>");
    return Answer.fromService(response,201);
  } catch (e) {
    log("/StoreServices <deleteValidated> Catch");
    return Answer(
        body: e,
        message: "Algo salio mal, revisa tu conexion a internet.",
        status: 1002,
        error: true);
  }
}

Future<Answer> postDirtyBroken({
  required String idRuta,
  required String idCliente,
  required String tipo,
  required String cantidad,
  required double lat,
  required double lon,
  required File archivo,
  required int idAutorization,
}) async {
  log("/StoreServices <postDirtyBroken> ¡");

  try {
    // Validación del tipo
    if (tipo != "S" && tipo != "R" && tipo != "MS") {
      throw Exception("Tipo inválido. Solo se acepta 'S' o 'R' o 'MS'.");
    }

    // Prepara la URI
    var uri = Uri.parse("${prefs.urlBase}mermaruta");

    // Crea la solicitud MultipartRequest
    var request = http.MultipartRequest("POST", uri);

    // Agrega los encabezados
    request.headers.addAll({
      "x-api-key": apiKey,
      "client_secret": prefs.clientSecret,
      "Authorization": "Bearer ${prefs.token}",
    });

    // Imprimir encabezados para depuración
    log("Headers: ${request.headers}");

    // Agrega los campos al body
    request.fields['id_ruta'] = idRuta;
    request.fields['id_cliente'] = idCliente;
    request.fields['tipo'] = tipo;
    request.fields['cantidad'] = cantidad;
    request.fields['lat'] = lat.toString();
    request.fields['lon'] = lon.toString();
    request.fields['id_autorizacion'] = idAutorization.toString();

    // Validar archivo antes de agregarlo
    if (!archivo.existsSync()) {
      throw Exception("El archivo no existe.");
    }

    // Archivo de imagen (usando el tipo MIME explícito)
    request.files.add(
      await http.MultipartFile.fromPath(
        'archivo', // Nombre del campo
        archivo.path,
        contentType: MediaType('archivo', 'jpg'), // MIME tipo explícito
      ),
    );

    // Imprimir detalles de los campos para depuración
    log("Request fields: ${request.fields}");
    log("Archivo a subir: ${archivo.path}");

    // Envía la solicitud
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    log("Response status: ${response.statusCode}");
    log("Response body: ${response.body}");

    // Verifica el estado de la respuesta
    if (response.statusCode == 201) {
      return Answer.fromService(response, 201);
    } else {
      return Answer(
          body: response.body,
          message: "Error en la solicitud.",
          status: response.statusCode,
          error: true);
    }
  } catch (e) {
    log("/StoreServices <postDirtyBroken> Catch - Error: $e");
    return Answer(
        body: e.toString(),
        message: "Algo salió mal, revisa tu conexión a internet.",
        status: 1002,
        error: true);
  }
}
Future<Answer> getDistance({required int idR}) async {
  log("/StoreServices <getDistance>");
  Map<String, dynamic> body = {
    "id_ruta": idR,
  };
  log("Request: $body");
  try {
    var response = await http.get(
      //Verificar la URL del stock
        Uri.parse("${prefs.urlBase}almacenmovil?q=distancia_ruta_almacen&id_ruta=$idR"),
        headers: {
          "Content-Type": "aplication/json",
          "x-api-key": apiKey,
          "client_secret": prefs.clientSecret,
          "Authorization": "Bearer ${prefs.token}",
        }).timeout(Duration(seconds: timerDuration));
    if (response.statusCode == 200) {
      var decodedBody = jsonDecode(response.body);
      log("/StoreServices <getDistance> Successfull");
      log("Response Body: $decodedBody");
      return Answer(body: jsonDecode(response.body), message: "",status:response.statusCode, error: false);
    } else {
      var decodedBody = jsonDecode(response.body);
      log("/StoreServices <getDistance> Fail");
      log("Response Body: $decodedBody");
      return Answer(
          body: response,
          message: "No se pudieron obtener los datos actualizados de la planta. Revisa tu conexión a internet.",
          status:response.statusCode,
          error: true);
    }
  } catch (e) {
    log("/StoreServices <getDistance> Catch ${e.toString()}");
    return Answer(
        body: e,
        message: "Conexión inestable con el back",
        status: 1002,
        error: true);
  }
}
