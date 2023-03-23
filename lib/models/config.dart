import 'dart:developer';

class ConfigModel {
  String parametro;
  int valor;
  String unidad;
  String description;

  ConfigModel(
      {required this.parametro,
      required this.valor,
      required this.unidad,
      required this.description});

  factory ConfigModel.fromState() {
    return ConfigModel(
        parametro: "",
        valor: 99,
        unidad: "Mtrs",
        description: "Limite Registro Venta");
  }

  factory ConfigModel.fromService(Map<String, dynamic> data) {
    return ConfigModel(
        parametro: data["parametro"] ?? "",
        valor: int.parse((data["valor"] ?? 99).toString()),
        unidad: data["unidad"] ?? "Mtrs",
        description: data["descripcion"] ?? "No");
  }
  factory ConfigModel.fromDatabase(int value) {
    return ConfigModel(
        parametro: "",
        valor: value,
        unidad: "Mtrs",
        description: "No");
  }
}
