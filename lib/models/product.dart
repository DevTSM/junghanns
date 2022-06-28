class ProductModel{
  List<String> name;
  String img;
  double price;
  int id;
  ProductModel({required this.name,required this.img,required this.price,required this.id});
  factory ProductModel.fromState(){
    return ProductModel(name: ["Cerámica ","M12 Bco"], img: "assets/images/Ceramica.JPG", price: 0,id:0);
  }
}