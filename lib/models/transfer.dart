class TransferModel {
  int id;
  int idRoute;
  int amount;
  int idProduct;
  String route;
  String type;
  String description;
  String status;
  String observation;
  DateTime create;
  DateTime update;
  TransferModel(
      {required this.id,
      required this.idRoute,
      required this.amount,
      required this.idProduct,
      required this.route,
      required this.type,
      required this.description,
      required this.status,
      required this.observation,
      required this.create,
      required this.update});
  factory TransferModel.fromService(Map<String, dynamic> data) {
    return TransferModel(
        id: data["id"] ?? 0,
        idRoute: data["id_ruta_entrega"] ?? (data["id_ruta_solicitud"]??0),
        amount: data["cantidad"] ?? 0,
        idProduct: data["id_producto"] ?? 0,
        route: data["ruta_entrega"] ?? (data["ruta_solicitud"]?? "Sin Ruta"),
        type: data["tipo"] ?? "ENVIADA",
        description: data["desc"] ?? "",
        status: data["estatus"] ?? "PENDIENTE",
        observation: data["observacion"] ?? "",
        create:
            DateTime.parse((data["fecha_alta"] ?? DateTime.now()).toString()),
        update: DateTime.parse(
            (data["fecha_modificacion"] ?? DateTime.now()).toString()));
  }
}
