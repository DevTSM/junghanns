/*
import 'info_model.dart';

class MessageModel {
  final String messageId;
  final int registeredAt;
  final String message;
  final String type;
  final String typeText;
  final String user;
  final String employee;
  final InfoModel info;

  MessageModel({
    required this.messageId,
    required this.registeredAt,
    required this.message,
    required this.type,
    required this.typeText,
    required this.user,
    required this.employee,
    required this.info,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['id_mensaje'],
      registeredAt: json['fecha_registro'],
      message: json['mensaje'],
      type: json['tipo'],
      typeText: json['tipo_text'],
      user: json['usuario'],
      employee: json['empleado'],
      // Handling the `info` field properly
      info: _parseInfo(json['info']),
    );
  }

  // A helper method to handle the info field
  static InfoModel _parseInfo(dynamic info) {
    if (info is Map<String, dynamic>) {
      // If info is a Map, parse it as an InfoModel
      return InfoModel.fromJson(info);
    } else {
      // If info is not a Map (like an empty list), return a default InfoModel
      return InfoModel(received: false, read: false);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mensaje': messageId,
      'fecha_registro': registeredAt,
      'mensaje': message,
      'tipo': type,
      'tipo_text': typeText,
      'usuario': user,
      'empleado': employee,
      'info': info.toJson(),
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
*/
import 'info_model.dart';

class MessageModel {
  final String messageId;
  final int registeredAt;
  final String message;
  final String type;
  final String typeText;
  final String user;
  final String employee;
  final InfoModel info;
  bool? isCheck; // Agregado el campo `check`

  MessageModel({
    required this.messageId,
    required this.registeredAt,
    required this.message,
    required this.type,
    required this.typeText,
    required this.user,
    required this.employee,
    required this.info,
    this.isCheck = false, // Valor predeterminado `true` para el campo `check`
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['id_mensaje'] ?? '',
      registeredAt: json['fecha_registro'] ?? 0,
      message: json['mensaje'] ?? '',
      type: json['tipo'] ?? '',
      typeText: json['tipo_text'] ?? '',
      user: json['usuario'] ?? '',
      employee: json['empleado'] ?? '',
      info: _parseInfo(json['info']),
      isCheck: json['isCheck']?? false, // Si 'check' no está en la respuesta, asigna `true`
    );
  }

  static InfoModel _parseInfo(dynamic info) {
    if (info is Map<String, dynamic>) {
      return InfoModel.fromJson(info);
    } else {
      return InfoModel(received: false, read: false);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mensaje': messageId,
      'fecha_registro': registeredAt,
      'mensaje': message,
      'tipo': type,
      'tipo_text': typeText,
      'usuario': user,
      'empleado': employee,
      'info': info.toJson(),
      'isCheck': isCheck, // Agregar el campo `check` al JSON
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
