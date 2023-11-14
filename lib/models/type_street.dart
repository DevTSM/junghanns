class TypeOfStreetModel {
  int id;
  String description;

  TypeOfStreetModel({required this.id, required this.description});

  factory TypeOfStreetModel.fromState() {
    return TypeOfStreetModel(id: -1, description: "Selecciona una opción");
  }

  factory TypeOfStreetModel.fromService(Map<String, dynamic> data) {
    return TypeOfStreetModel(
        id: int.parse((data["id"] ?? -1).toString()), description: data["descripcion"] ?? "No");
  }
}
