class RefillModel{
  String name;
  String img;
  double price;
  int id;
  bool isSelect;
  RefillModel({required this.name,required this.img,required this.price,required this.id,required this.isSelect});
  factory RefillModel.fromState(){
    return RefillModel(name: "", img: "assets/icons/refill1.png", price: 0, id: 0,isSelect: false);
  }
  factory RefillModel.fromService(Map<String,dynamic> data){
    return RefillModel(name: data["descripcion"]??"", img: "assets/icons/refill1.png", price: double.parse((data["precio"]??"0").toString()), id: data["idProductoServicio"]??0,isSelect: false);
  }
  setSelect(isSelect){
    this.isSelect=isSelect;
  }
  getMap(){
    return {
      "idProduct":id,
      "description":name,
      "price":price
    };
  }
}