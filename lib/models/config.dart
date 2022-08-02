class ConfigModel {
  String parametro;
  String valor;
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
        valor: "99",
        unidad: "Mtrs",
        description: "Limite Registro Venta");
  }

  factory ConfigModel.fromService(Map<String, dynamic> data) {
    return ConfigModel(
        parametro: data["parametro"] ?? "",
        valor: data["valor"] ?? "99",
        unidad: data["unidad"] ?? "Mtrs",
        description: data["descripcion"] ?? "No");
  }
}