

enum EstatusMessage{
  pendiente,
  enviado,
  fallido,
}
extension EstatusMessageExt on EstatusMessage {
  String get stringType {
    switch(this){
      case EstatusMessage.pendiente:
        return 'PENDIENTE';
      case EstatusMessage.fallido:
        return 'FALLIDO';
      case EstatusMessage.enviado:
        return 'ENVIADO';
      default :
        return 'PENDIENTE';
    }
  }
}
EstatusMessage status(String current) {
    switch(current){
      case 'PENDIENTE':
        return EstatusMessage.pendiente;
      case 'FALLIDO':
        return EstatusMessage.fallido;
      case 'ENVIADO':
        return EstatusMessage.enviado;
      default :
        return EstatusMessage.pendiente;
    }
  }