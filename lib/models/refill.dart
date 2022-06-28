class RefillModel{
  String name;
  String img;
  double price;
  int id;
  RefillModel({required this.name,required this.img,required this.price,required this.id});
  factory RefillModel.fromState(){
    return RefillModel(name: "", img: "assets/icons/refill1.png", price: 0, id: 0);
  }
  factory RefillModel.fromService(Map<String,dynamic> data){
    return RefillModel(name: data["descripcion"]??"", img: "assets/icons/refill1.png", price: double.parse(data["precio"]??"0"), id: data["isProductoServicio"]??0);
  }
}