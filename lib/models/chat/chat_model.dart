import 'dart:convert';
import 'message_model.dart';

class ChatModel {
  final String chatId;
  final int createdAt;
  final String status;
  final String statusText;
  final int lastMessage;
  final List<MessageModel> messages;

  ChatModel({
    required this.chatId,
    required this.createdAt,
    required this.status,
    required this.statusText,
    required this.lastMessage,
    required this.messages,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      chatId: json['id_chat'] ?? '',  // Si 'id_chat' es null, asignar una cadena vacía.
      createdAt: json['created'] ?? 0,  // Si 'created' es null, asignar 0.
      status: json['estatus'] ?? '',  // Si 'estatus' es null, asignar una cadena vacía.
      statusText: json['estatus_text'] ?? '',  // Si 'estatus_text' es null, asignar una cadena vacía.
      lastMessage: json['lastMessage'] ?? 0,  // Si 'lastMessage' es null, asignar 0.
      messages: (json['mensajes'] is List)
          ? (json['mensajes'] as List).map((e) => MessageModel.fromJson(e)).toList()
          : [], // Retorna una lista vacía si 'mensajes' no es una lista o es null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'createdAt': createdAt,
      'status': status,
      'statusText': statusText,
      'lastMessage': lastMessage,

    };
  }

  @override
  String toString() {
    return jsonEncode(toJson()); // Convierte el objeto a JSON en formato String
  }
}
