class TypeOfStreetModel {
  int id;
  String description;

  TypeOfStreetModel({required this.id, required this.description});

  factory TypeOfStreetModel.fromState() {
    return TypeOfStreetModel(id: -1, description: "test");
  }

  factory TypeOfStreetModel.fromService(Map<String, dynamic> data) {
    return TypeOfStreetModel(
        id: data["id"] ?? -1, description: data["descripcion"] ?? "No");
  }
}
