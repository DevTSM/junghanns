class MethodPayment {
  String wayToPay;
  String typeWayToPay;
  String type;
  int idProductService;
  String description;
  int number;

  MethodPayment(
      {required this.wayToPay,
      required this.typeWayToPay,
      required this.type,
      required this.idProductService,
      required this.description,
      required this.number});

  factory MethodPayment.fromState() {
    return MethodPayment(
        wayToPay: "Contado",
        typeWayToPay: "E",
        type: "Atributo",
        idProductService: -1,
        description: "",
        number: -1);
  }
  factory MethodPayment.fromService(Map<String, dynamic> data) {
    return MethodPayment(
        wayToPay: data["formaPago"] ?? "",
        typeWayToPay: data["tipoFormaPago"],
        type: data["type"],
        idProductService: data["idProductoServicio"] ?? -1,
        description: data["descripcion"] ?? "",
        number: data["cantidad"] != null
            ? double.parse(data["cantidad"]).toInt()
            : -1);
  }
}
