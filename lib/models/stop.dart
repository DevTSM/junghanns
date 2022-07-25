class StopModel {
  int id;
  String img;
  String name;
  bool isSelect;

  StopModel(
      {required this.name,
      required this.img,
      required this.id,
      required this.isSelect});

  factory StopModel.fromState() {
    return StopModel(
        name: "No estuvo",
        img: "assets/images/stop1.png",
        id: 0,
        isSelect: false);
  }
  /*factory StopModel.fromService(Map<String,dynamic> data){
    return StopModel(name: data["descripcion"]??"", img: "assets/images/stop1.png", id: data["id"]??0, isSelect: false);
  }*/

  setSelect(isSelect) {
    this.isSelect = isSelect;
  }
}
