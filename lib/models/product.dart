class ProductModel{
  List<String> name;
  String img;
  double price;
  int id;
  bool isSelect;
  ProductModel({required this.name,required this.img,required this.price,required this.id,required this.isSelect});
  factory ProductModel.fromState(){
    return ProductModel(name: ["Cerámica ","M12 Bco"], img: "assets/images/Ceramica.JPG", price: 10.1,id:0,isSelect: false);
  }
  setSelect(bool isSelect){
    this.isSelect=isSelect;
  }
}