class SaleCambaceoModel {
  int id;
  String description;

  SaleCambaceoModel({required this.id, required this.description});

  factory SaleCambaceoModel.fromState() {
    return SaleCambaceoModel(id: -1, description: "test");
  }

  factory SaleCambaceoModel.fromService(Map<String, dynamic> data) {
    return SaleCambaceoModel(
        id: data["id"] ?? -1, description: data["descripcion"] ?? "No");
  }
}
