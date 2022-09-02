class SaleCambaceoModel {
  int id;
  String description;

  SaleCambaceoModel({required this.id, required this.description});

  factory SaleCambaceoModel.fromState() {
    return SaleCambaceoModel(id: -1, description: "test");
  }

  factory SaleCambaceoModel.fromService(Map<String, dynamic> data) {
    return SaleCambaceoModel(
        id: int.parse((data["id"] ?? -1).toString()), description: data["descripcion"] ?? "No");
  }
}
