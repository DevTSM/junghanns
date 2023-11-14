class OperationCustomerModel {
  DateTime date;
  DateTime entrega;
  String description;
  String type;
  double total;
  double priceU;
  int typeInt;
  int folio;
  int isProduct;
  int idDocument;
  int amount;
  int amountReturned;
  bool isReturned;
  OperationCustomerModel(
      {required this.date,
      required this.entrega,
      required this.description,
      required this.type,
      required this.total,
      required this.priceU,
      required this.typeInt,
      required this.folio,
      required this.isProduct,
      required this.idDocument,
      required this.amount,
      this.amountReturned=0,
      this.isReturned=false});
  factory OperationCustomerModel.fromState(){
    return OperationCustomerModel(
      date: DateTime.now(), 
      entrega: DateTime.now(), 
      description: "", 
      type: "", 
      total: 0,
      priceU: 0, 
      typeInt: 0, 
      folio: 0, 
      isProduct: 1, 
      idDocument: 0, 
      amount: 0
    );
  }
  factory OperationCustomerModel.fromServices(Map<String, dynamic> data) {
    return OperationCustomerModel(
        date: DateTime.parse(data["createdAt"] ?? DateTime.now().toString()),
        entrega:
            DateTime.parse(data["fecha_entrega"] ?? DateTime.now().toString()),
        description: data["desc"] ?? "",
        idDocument: data["id_documento"]??0,
        type: data["tipo"] ?? "PRÉSTAMO",
        total: double.parse((data["total"] ?? 0).toString()),
        priceU: double.parse((data["precio_unitario"] ?? 0).toString()),
        typeInt: getType(data["tipo"] ?? "PRÉSTAMO"),
        folio: int.parse((data["folio"] ?? 0).toString()),
        isProduct: int.parse((data["id_producto"] ?? 0).toString()),
        amount: int.parse((data["cantidad"] ?? 0).toString()));
  }
  factory OperationCustomerModel.fromDataBase(Map<String, dynamic> data) {
    return OperationCustomerModel(
      date: DateTime.parse(data["date"] ?? DateTime.now().toString()),
      entrega: DateTime.parse(data["fecha_entrega"] ?? DateTime.now().toString()),
      description: data["desc"] ?? "",
      idDocument: data["idDocumento"]??0,
      type: data["tipo"] ?? "PRÉSTAMO",
      total: double.parse((data["total"] ?? 0).toString()),
      priceU: double.parse((data["precio_unitario"] ?? 0).toString()),
      typeInt: getType(data["tipo"] ?? "PRÉSTAMO"),
      folio: int.parse((data["folio"] ?? 0).toString()),
      isProduct: int.parse((data["id_producto"] ?? 0).toString()),
      amount: int.parse((data["cantidad"] ?? 0).toString()),
      isReturned:true
    );   
  }
  Map<String,dynamic> get getMap=>{
    "createdAt":date.toString(),
    "fecha_entrega":date.toString(),
    "desc":description,
    "tipo":type,
    "total":total,
    "folio":folio,
    "id_documento":idDocument,
    "id_producto":isProduct,
    "cantidad":amount
  };
  set updateCount(int current)=>amount=current;
  set returnedAmount(int current)=> amountReturned = current;
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
