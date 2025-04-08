import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:junghanns/models/chat/chat_model.dart';
import 'package:junghanns/models/chat/info_model.dart';
import 'package:junghanns/models/chat/message_model.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/services/chat.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../database/chat_database.dart';
import '../pages/socket/socket_service.dart';
import '../util/push_notifications_provider.dart';

class ChatProvider with ChangeNotifier {
  late IO.Socket socket;
  List<Map<String, dynamic>> messages = []; // Permite texto y archivos
  final String myUserId = prefs.nameUserD;
  List<ChatModel> _messagesChat = [];
  final ChatDatabaseHelper _chatDatabaseHelper = ChatDatabaseHelper();  // Instancia de la base de datos

  // Renombramos el getter para evitar conflictos con otros usos de 'messages'
  List<MessageModel> get chatMessages {
    return messagesChat.isEmpty ? [] : messagesChat[0].messages;
  }


  bool _hasNewMessage = false;
  bool get hasNewMessage => _hasNewMessage;
  List<ChatModel> get messagesChat => _messagesChat;

  set messagesChat(List<ChatModel> current){
    _messagesChat = current;
    notifyListeners();
  }


  ChatProvider() {
    socket = SocketService().getSocket();
    _setupListeners();
    sendPendingMessages();  // Llamamos a la función para enviar los mensajes pendientes
    printPendingMessages();
    //_setupConnectivityListener();  // Configurar el listener para la conectividad
  }

  void _setupListeners() {
    socket.on("receiveMessage", (data) {
      if (data is Map<String, dynamic>) {
        bool exists = messages.any((msg) =>
        msg["type"] == data["type"] &&
            msg["userId"] == data["user"] &&
            (msg["message"] == data["message"] || msg["fileName"] == data["fileName"]));

        if (!exists) {
          messages.add({
            "type": data["type"],
            "userId": data["user"] ?? "desconocido",
            "message": data["message"] ?? "",
            "fileName": data["fileName"],
            "fileType": data["fileType"],
            "fileUrl": data["fileUrl"],
          });

          _hasNewMessage = true;
          notifyListeners();

          if (data["user"] != myUserId) {
            NotificationService().showNotifications(
              "Nuevo mensaje de ${data["user"]}",
              data["message"] ?? "Nuevo mensaje recibido",
            );
          }
        }
      }
    });
  }

  /*sendMessage({
    int ? idRuta,
    String ? fechaOperacion,
    required String mensaje,
  }) async {
        // Obtener la fecha actual en formato UNIX
        int fechaOperacionUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        // Llamada al servicio de envío de mensaje con idRuta y fechaOperacion en formato UNIX
        await sendMessageService(
          idRuta: prefs.idRouteD,
          fechaOperacion: fechaOperacionUnix.toString(),  // Fecha en formato UNIX como String
          mensaje: mensaje,
        ).then((answer) async {
          // Verificamos si hubo un error al enviar el mensaje
          if (answer.error) {
            print("⚠️ Error al enviar mensaje: ${answer.message}");
          } else {
            int idChat = answer.body['id_chat'];
            // Si prefs.idChat está vacío o nulo, llenarlo con el idChat
            if (prefs.idChat == 0) {
              prefs.idChat = idChat;
              print("prefs.idChat ha sido llenado con idChat: ${prefs.idChat}");
            }else{
              print('Ya tine dato cargado');

            }
            // Si la respuesta es exitosa, agregamos el mensaje a la lista local
            final data = {
              "type": "text",
              "message": mensaje,
              "userId": myUserId,
            };

            socket.emit("sendMessage", data);  // Enviar mensaje al socket
            messages.add(data);  // Agregar el mensaje localmente
            notifyListeners();  // Notificar que se ha agregado un nuevo mensaje
          }
        });
  }*/
  sendMessage({
    int? idRuta,
    String? fechaOperacion,
    required String mensaje,
    String? type
  }) async {
    await _chatDatabaseHelper.checkAndClearChatDatabase();
    // Verificamos la conexión a internet
    ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

    // Obtener la fecha actual en formato UNIX
    int fechaOperacionUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (connectivityResult == ConnectivityResult.none) {
      // Si no hay conexión a internet, guardamos el mensaje con isSent = 0
      print("Sin conexión a internet. Guardando mensaje localmente...");
      final message = MessageModel(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),  // O usar un ID único
        registeredAt: fechaOperacionUnix,
        message: mensaje,
        type: type!,
        typeText: "",  // Ajusta según el tipo del mensaje
        user: "Tú",
        employee: "",
        info: InfoModel(received: false, read: false),
      );

      // Llamamos a insertMessage con isSent = 0
      await _chatDatabaseHelper.insertMessage(message, prefs.idChat.toString(), isSent: false);
      notifyListeners();  // Notificamos que se ha guardado el mensaje
    } else {
      // Si hay conexión, procedemos a enviar el mensaje
      await sendMessageService(
        idRuta: prefs.idRouteD,
        fechaOperacion: fechaOperacionUnix.toString(),
        mensaje: mensaje,
      ).then((answer) async {
        if (answer.error) {
          print("⚠️ Error al enviar mensaje: ${answer.message}");
        } else {
          int idChat = answer.body['id_chat'];

          if (prefs.idChat == 0) {
            prefs.idChat = idChat;
            print("prefs.idChat ha sido llenado con idChat: ${prefs.idChat}");
          } else {
            print('Ya tiene dato cargado');
          }

          // Si la respuesta es exitosa, agregamos el mensaje a la lista local
          final data = {
            "type": "text",
            "message": mensaje,
            "userId": myUserId,
            "isSent": 1,  // Indicamos que el mensaje fue enviado
          };

          socket.emit("sendMessage", data);
          messages.add(data);
          notifyListeners();
        }
      });
    }
  }
  void _setupConnectivityListener() {
    print("Entra a la conectividad");
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      print("Conectividad cambió: $result"); // Agrega este print para verificar
      if (result != ConnectivityResult.none) {
        // Se detectó conexión a Internet
        sendPendingMessages();  // Llamamos a la función para enviar los mensajes pendientes
        printPendingMessages();
      }
      //printPendingMessages();
    });
  }
  // Obtener los mensajes no enviados
  Future<void> printPendingMessages() async {
    print("NEntra a printMessages");
    try {
      // Agregar un print para verificar antes de hacer la llamada
      print("Llamando a getPendingMessages...");
      final pendingMessages = await _chatDatabaseHelper.getPendingMessages();

      // Verificar si los mensajes están vacíos o no
      print("Mensajes obtenidos: $pendingMessages");

      // Imprimir directamente los mensajes sin validación
      if (pendingMessages.isEmpty) {
        print("No se encontraron mensajes.");
      } else {
        for (var message in pendingMessages) {
          print("Message ID: ${message.messageId}");
          print("User: ${message.user}");
          print("Employee: ${message.employee}");
          print("Message: ${message.message}");
          print("Received: ${message.info.received ? 'Yes' : 'No'}");
          print("Read: ${message.info.read ? 'Yes' : 'No'}");
          print("Registered at: ${DateTime.fromMillisecondsSinceEpoch(message.registeredAt)}");
          print("-----");
        }
      }
    } catch (e) {
      print("Error-------: $e");
    }
  }



  Future<void> sendPendingMessages() async {
    printPendingMessages();
    // Verificar la conexión a internet
    ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      // Obtener los mensajes pendientes (isSent == 0)
      List<MessageModel> pendingMessages = await _chatDatabaseHelper.getPendingMessages();

      for (var message in pendingMessages) {
        try {
          // Enviar mensaje
          await sendMessageService(
            idRuta: prefs.idRouteD,
            fechaOperacion: message.registeredAt.toString(),
            mensaje: message.message,
          ).then((answer) async {
            if (answer.error) {
              print("⚠️ Error al enviar mensaje: ${answer.message}");
            } else {
              // Actualizar el mensaje como enviado
              await _chatDatabaseHelper.updateMessageStatus(message.messageId, isSent: true);
              // Eliminar el mensaje localmente después de marcarlo como enviado
              await _chatDatabaseHelper.deleteMessage(message.messageId); // Borrar mensaje localmente


              // Enviar al socket
              final data = {
                "type": "text",
                "message": message.message,
                "userId": myUserId,
                "isSent": 1,  // Indicamos que el mensaje fue enviado
              };
              socket.emit("sendMessage", data);
              print("Mensaje enviado con éxito con mensajes locales: ${message.message}");
              notifyListeners();
            }
          });
        } catch (e) {
          print("Error al enviar el mensaje pendiente: $e");
        }
      }
    } else {
      print("No hay conexión a internet, no se pueden enviar mensajes pendientes.");
    }
  }



  // 📂 Enviar archivo (solo pasa la URL al chat utilizando `sendMessageService`)
  /*Future<void> sendFile(*//*File fileUrl*//* List<File> fileUrl) async {
    print("⚠️ envia archivo");

    // Verificamos la conexión a internet
    ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

    // Obtener la fecha actual en formato UNIX
      int fechaOperacionUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Usar el servicio de `sendMessageService` para enviar la URL del archivo como mensaje
      await sendMessageServiceFile(
        idRuta: prefs.idRouteD,  // Usar idRuta como en sendMessage
        fechaOperacion: fechaOperacionUnix.toString(),  // Fecha en formato UNIX
        archivos: fileUrl,  // Usamos la URL del archivo como mensaje
      ).then((answer) {
        // Verificamos si hubo un error al enviar el mensaje
        if (answer.error) {
          print("⚠️ Error al enviar mensaje: ${answer.message}");
          getMessages();
        } else {
          // Si la respuesta es exitosa, agregamos el mensaje con la URL del archivo a la lista local
          // Obtener el `id_chat` de la respuesta
          int idChat = answer.body['id_chat'];
// Si prefs.idChat está vacío o nulo, llenarlo con el idChat
          if (prefs.idChat == 0) {
            prefs.idChat = idChat;
            print("prefs.idChat ha sido llenado con idChat: ${prefs.idChat}");
          } else{
            print('Ya tine dato cargado');
          }
          final data = {
            "type": "file",
            "message": fileUrl,
            "userId": myUserId,
            "fileUrl": fileUrl,
          };

          socket.emit("sendMessage", data);  // Enviar mensaje al socket
          messages.add(data);  // Agregar el mensaje localmente
          _hasNewMessage = true;  // Indicamos que hay un nuevo mensaje
          notifyListeners();  // Notificar que se ha agregado un nuevo mensaje
        }
      });

  }*/
  Future<void> sendFile(List<File> fileUrl, {String? type}) async {
    print("⚠️ Enviando archivo");
    await _chatDatabaseHelper.checkAndClearChatDatabase();

    // Verificamos la conexión a internet
    ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

    // Obtener la fecha actual en formato UNIX
    int fechaOperacionUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
// Convertir los archivos a una lista de rutas o nombres de archivo
    List<String> fileNames = fileUrl.map((file) => file.path).toList();

    if (connectivityResult == ConnectivityResult.none) {
      // Si no hay conexión a internet, guardamos el archivo localmente con isSent = 0
      print("Sin conexión a internet. Guardando archivo localmente...");

      final fileMessage = MessageModel(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),  // O usar un ID único
        registeredAt: fechaOperacionUnix,
        message: fileNames.join(','),
        type: type!,  // Tipo de archivo
        typeText: '',
        user: "Tú",
        employee: "",
        info: InfoModel(received: false, read: false),
      );

      // Llamamos a insertFileMessage con isSent = 0
      await _chatDatabaseHelper.insertMessage(fileMessage, prefs.idChat.toString(), isSent: false);
      notifyListeners();  // Notificamos que se ha guardado el archivo localmente
    } else {
      // Si hay conexión, procedemos a enviar el archivo
      await sendMessageServiceFile(
        idRuta: prefs.idRouteD,
        fechaOperacion: fechaOperacionUnix.toString(),
        archivos: fileUrl,
      ).then((answer) {
        // Verificamos si hubo un error al enviar el archivo
        if (answer.error) {
          print("⚠️ Error al enviar archivo: ${answer.message}");
          getMessages();
        } else {
          // Si la respuesta es exitosa, agregamos el mensaje con la URL del archivo a la lista local
          int idChat = answer.body['id_chat'];

          // Si prefs.idChat está vacío o nulo, llenarlo con el idChat
          if (prefs.idChat == 0) {
            prefs.idChat = idChat;
            print("prefs.idChat ha sido llenado con idChat: ${prefs.idChat}");
          } else {
            print('Ya tiene dato cargado');
          }

          final data = {
            "type": "file",
            "message": fileUrl,
            "userId": myUserId,
            "fileUrl": fileUrl,
          };

          socket.emit("sendMessage", data);  // Enviar mensaje al socket
          messages.add(data);  // Agregar el mensaje localmente
          _hasNewMessage = true;  // Indicamos que hay un nuevo mensaje
          notifyListeners();  // Notificar que se ha agregado un nuevo mensaje
        }
      });
    }
  }


  getMessages({DateTime? date}) async {
    try {
      // Verifica la conexión a Internet
      ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        // Si no hay conexión, cargar mensajes locales
        print("Sin conexión a internet. Cargando mensajes locales...");
        var localMessages = await _chatDatabaseHelper.getLocalMessages();
        messagesChat = localMessages;
        print("Mensajes locales cargados: $messagesChat");
      } else {
        // Si hay conexión, obtener mensajes desde el servidor
        print("Conexión a internet. Cargando mensajes desde el servidor...");
        var answer = await getMessagesService(idChat: prefs.idChat, date: date);
        print('Imprimiendo el chat${prefs.idChat}');

        if (answer.error) {
          print('Error al obtener los mensajes: ${answer.message}');
        } else {
          // Verifica si la respuesta es una lista o un solo objeto
          if (answer.body is List) {
            messagesChat = (answer.body as List).map((item) => ChatModel.fromJson(item)).toList();
            print('Mensajes del chat: $messagesChat');
          } else {
            messagesChat = [ChatModel.fromJson(answer.body)];
            print('Mensaje único del chat: $messagesChat');
          }
          sendPendingMessages();
// Marcar todos los mensajes como "old = true"
          for (var chat in messagesChat) {
            for (var message in chat.messages) {
              message.isCheck = true;
            }
          }

          print('Mensajes del chat (marcados como antiguos): $messagesChat');
          // Verificar si los mensajesChat no están vacíos
          if (messagesChat.isEmpty) {
            print('No se encontraron mensajes para el día ${date?.toString()}');
          } else {
            // Insertar los chats y los mensajes en la base de datos local
            for (var chat in messagesChat) {
              print('Insertando chat con ID: ${chat.chatId}');
              await _chatDatabaseHelper.checkAndClearChatDatabase();
              await _insertChatAndMessages(chat);


              // Marcar los mensajes que no son tuyos como recibidos
              if (chat.messages.isNotEmpty && chat.messages.first.user != "Tú") {
                print('ENTRAR A MARCAR COMO RECIBIDO: ${chat.messages.first.messageId}');
                putReceived(idM: chat.messages.first.messageId, action: 'leer');
                putReceived(idM: chat.messages.first.messageId, action: 'recibido');
              } else {
                print('Este mensaje es tuyo, no se marca como recibido.');
              }
            }
          }
        }
      }

      // Notificar que los datos han sido actualizados
      notifyListeners();

    } catch (e) {
      print('Error al obtener mensajes: $e');
    }
  }


// Función para insertar los chats y mensajes en la base de datos local
  Future<void> _insertChatAndMessages(ChatModel chat) async {
    try {
      print('Insertando chat con ID: ${chat.chatId}');
      // Insertar el chat
      await _chatDatabaseHelper.insertChat(chat);

      // Insertar los mensajes asociados al chat
      for (var message in chat.messages) {
        print('Insertando mensaje con ID: ${message.messageId}');
        //bool valorCheck =  message.isCheck;
        //print('cambiamos valor${valorCheck}');
        final messages = MessageModel(
          messageId: message.messageId,  // O usar un ID único
          registeredAt: message.registeredAt,
          message: message.message,
          type: message.type,
          typeText: message.typeText,  // Ajusta según el tipo del mensaje
          user: message.user,
          employee: message.employee,
          info: InfoModel(received: false, read: false),
          isCheck: true,
        );
        print('Mensajes insertados-----${messages}');
        await _chatDatabaseHelper.insertMessage(messages, chat.chatId, isSent: true);
        //await _chatDatabaseHelper.getLocalMessages();
        print('Mensaje insertado: ${message.messageId}');
      }
    } catch (e) {
      print('Error al insertar chat o mensajes: $e');
    }
  }

// Funcionalidad de la recepción
  putReceived({required String action ,required String idM}) async {
    notifyListeners();
    // Llamada al servicio postValidated
    await putStatus(
      action: action,
      idM: idM,
    ).then((answer) {
      /*loading = false;*/
      if (answer.error) {
        // Redirigir a la vista de Home
        print('Error al obtener los mensajes: ${answer.message}');
      } else {
        print('Mensajes recibidos o leídos');
        getMessages();
        notifyListeners();
      }
    });
  }

  void resetNewMessageFlag() {
    _hasNewMessage = false;
    notifyListeners();
  }
}
