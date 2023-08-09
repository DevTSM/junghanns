class OperationCustomerModel {
  DateTime date;
  DateTime entrega;
  String description;
  String type;
  double total;
  int typeInt;
  int folio;
  int isProduct;
  int amount;
  OperationCustomerModel(
      {required this.date,
      required this.entrega,
      required this.description,
      required this.type,
      required this.total,
      required this.typeInt,
      required this.folio,
      required this.isProduct,
      required this.amount});
  factory OperationCustomerModel.fromServices(Map<String, dynamic> data) {
    return OperationCustomerModel(
        date: DateTime.parse(data["createdAt"] ?? DateTime.now().toString()),
        entrega:
            DateTime.parse(data["fecha_entrega"] ?? DateTime.now().toString()),
        description: data["desc"] ?? "",
        type: data["tipo"] ?? "PRÉSTAMO",
        total: double.parse((data["total"] ?? 0).toString()),
        typeInt: getType(data["tipo"] ?? "PRÉSTAMO"),
        folio: int.parse((data["folio"] ?? 0).toString()),
        isProduct: int.parse((data["id_producto"] ?? 0).toString()),
        amount: int.parse((data["cantidad"] ?? 0).toString()));
  }
  Map<String,dynamic> get getMap=>{
    "createdAt":date.toString(),
    "fecha_entrega":date.toString(),
    "desc":description,
    "tipo":type,
    "total":total,
    "folio":folio,
    "id_producto":isProduct,
    "cantidad":amount
  };
}

int getType(String type) {
  switch (type) {
    case "PRÉSTAMO":
      return 2;
    case "CRÉDITO / REMISIÓN":
      return 3;
    default:
      return 1;
  }
}
