class SaleModel {
  DateTime date;
  String type;
  String description;
  double amount;
  int count;
  SaleModel(
      {required this.date,
      required this.type,
      required this.description,
      required this.amount,
      required this.count});
  factory SaleModel.fromState() {
    return SaleModel(
        date: DateTime.now(), type: "", description: "", amount: 0.0, count: 0);
  }
  factory SaleModel.fromService(Map<String, dynamic> data) {
    return SaleModel(
        date: DateTime.parse(data["fecha"] ?? DateTime.now().toString()),
        type: data["tipo"] ?? "VENTA",
        description: data["descripcion"] ?? "",
        amount: double.parse((data["importe"] ?? "0").toString()),
        count: double.parse((data["cantidad"] ?? "0").toString()).ceil());
  }
  factory SaleModel.fromDataBase(Map<String, dynamic> data) {
    return SaleModel(
        date: DateTime.parse(data["fecha"] ?? DateTime.now().toString()),
        type: data["tipo"] ?? "VENTA",
        description: data["descripcion"] ?? "",
        amount: double.parse((data["importe"] ?? "0").toString()),
        count: double.parse((data["cantidad"] ?? "0").toString()).ceil());
  }
  Map<String,dynamic> get getMap=>{
    'fecha':date.toString(),
    'tipo':type,
    'descripcion':description,
    'importe':amount,
    'cantidad':count
  };
}

String checkDouble(String evalue) {
  switch (evalue[evalue.length - 2]) {
    case '.':
      return "\$ $evalue 0";
    default:
      return "\$ $evalue";
  }
}

/*List<String> checkDoubleRich(String evalue) {
  print(evalue);
  switch (evalue[evalue.length - 2]) {
    case '.':
      return [
        "\$ " + evalue.substring(0, evalue.indexOf('.')),
        evalue.substring(evalue.indexOf('.'), evalue.length) + "0"
      ];
    default:
      return [
        "\$ " + evalue.substring(0, evalue.indexOf('.')),
        evalue.substring(evalue.indexOf('.'), evalue.length)
      ];
  }
}*/
