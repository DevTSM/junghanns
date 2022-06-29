class MethodPayment {
  String wayToPay;
  String typeWayToPay;
  String type;
  MethodPayment(
      {required this.wayToPay, required this.typeWayToPay, required this.type});

  factory MethodPayment.fromState() {
    return MethodPayment(
        wayToPay: "Contado", typeWayToPay: "E", type: "Atributo");
  }
  factory MethodPayment.fromService(Map<String, dynamic> data) {
    return MethodPayment(
        wayToPay: data["formaPago"] ?? "",
        typeWayToPay: data["tipoFormaPago"],
        type: data["type"]);
  }
}
