class StopModel {
  int id;
  String icon;
  String description;
  String color;
  bool isSelect;

  StopModel(
      {required this.id,
      required this.icon,
      required this.description,
      required this.color,
      required this.isSelect});

  factory StopModel.fromState() {
    return StopModel(
        id: 0,
        icon: "assets/images/stop1.png",
        description: "No estuvo",
        color: "bg-red2-light",
        isSelect: false);
  }
  factory StopModel.fromService(Map<String, dynamic> data) {
    return StopModel(
        id: int.parse((data["id"] ?? 0).toString()),
        description: data["descripcion"] ?? "",
        icon: data["icon"],
        color: data["color"],
        isSelect: false);
  }
  factory StopModel.fromDatabase(Map<String, dynamic> data) {
    return StopModel(
        id: data["id"] ?? 0,
        description: data["description"] ?? "",
        icon: data["icon"],
        color: data["color"],
        isSelect: false);
  }
  Map<String,dynamic> getMap(){
    return {
      "id":id,
      "description":description,
      "icon":icon,
      "color":color
    };
  }

  setSelect(isSelect) {
    this.isSelect = isSelect;
  }
}
