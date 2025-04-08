import 'package:junghanns/models/enum/message.dart';

class MessageChat{
  int id;
  String message;
  String emisor;
  DateTime date;
  EstatusMessage estatus;
  MessageChat(
    {
      required this.id,
      required this.message,
      required this.emisor,
      required this.date,
      required this.estatus
    }
  );
  factory MessageChat.fromState({String emisor = ''}){
    return MessageChat(
      id: 0, 
      message: "Hola", 
      emisor: emisor,
      date: DateTime.now(),
      estatus: EstatusMessage.enviado
    );
  }
  factory MessageChat.fromMessage({required String message}){
    return MessageChat(
      id: 0, 
      message: message,
      emisor: '', 
      date: DateTime.now(),
      estatus: EstatusMessage.enviado
    );
  }
  factory MessageChat.fromDB({required Map<String,dynamic> data}){
    return MessageChat(
      id: data['id'], 
      message: data['mensaje'],
      emisor: data['emisor'], 
      date: DateTime.parse(data['date']),
      estatus: status(data['estatus'])
    );
  }
  Map<String,dynamic> get map =>
  {
    'mensaje':message,
    'emisor':emisor,
    'date':date.toString(),
    'estatus': estatus.stringType
  };
}