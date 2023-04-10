import 'dart:developer';

class ProductModel {
  int idProduct;
  String description;
  double price;
  int stock;
  int number;
  String img;
  String count;
  int type; //1 product 2 refill
  bool isSelect;
  String rank;

  ProductModel(
      {required this.idProduct,
      required this.description,
      required this.price,
      required this.stock,
      required this.number,
      required this.img,
      required this.type,
      required this.count,
      required this.isSelect,
      required this.rank});

  factory ProductModel.fromState(int id) {
    return ProductModel(
        idProduct: id,
        description: "Liquido de recambio 20 LTS",
        price: 200.00,
        stock: 20,
        number: 0,
        img: "https://img77.uenicdn.com/image/upload/v1573695379/business/d3d540b1-1c2e-4895-90d6-eb749f17f808.jpg",
        type: 1,
        count: "20",
        isSelect: false,
        rank: id==0?"":"1");
  }
  factory ProductModel.fromProduct(ProductModel productCurrent) {
    return ProductModel(
        idProduct: productCurrent.idProduct,
        description: productCurrent.description,
        price: productCurrent.price,
        stock: productCurrent.stock,
        number: 0,
        img: productCurrent.img,
        count: productCurrent.count,
        type: productCurrent.type,
        isSelect: false,
        rank: productCurrent.rank);
  }
  factory ProductModel.fromServiceProduct(Map<String, dynamic> data) {
    return ProductModel(
        idProduct: int.parse((data["idProductoServicio"] ?? 0).toString()),
        description: data["descripcion"],
        price: double.parse((data["precio"] ?? "0").toString()),
        stock: int.parse((data["stock"]??(data["cantidad"] ?? 0)).toString()),
        number: 0,
        img: data["url"],
        type: 1,
        count: data["data"]??"",
        isSelect: false,
        rank: data["rank"] ?? "");
  }
  factory ProductModel.fromDatabase(Map<String, dynamic> data) {
    return ProductModel(
        idProduct: data["idProductoServicio"] ?? 0,
        description: data["descripcion"],
        price: data["precio"]??-1,
        stock: double.parse((data["stock"]??0).toString()).ceil(),
        number: 0,
        count: "",
        img: "assets/icons/refill1.png",
        type: 1,
        isSelect: false,
        rank: data["rank"]);
  }
  Map<String, dynamic> get getMapProduct=>{
    "idProductoServicio":idProduct,
      "descripcion":description,
      "precio":price,
      "stock":stock,
      "url":img,
      "rank":rank
  };
  setSelect(bool isSelect) {
    this.isSelect = isSelect;
  }
  getMap(){
    return {
      "idProductoServicio":idProduct,
      "descripcion":description,
      "precio":price,
      "stock":stock,
      "url":img,
      "rank":rank
    };
  }
  setCount(int number){
    this.number=number;
  }
  factory ProductModel.fromServiceRefill(Map<String, dynamic> data) {
    return ProductModel(
        idProduct: data["idProductoServicio"] ?? 0,
        description: data["descripcion"],
        price: double.parse((data["precio"] ?? "0").toString()),
        stock: 0,
        number: 0,
        img: "assets/icons/refill1.png",
        type: 2,
        count: "",
        isSelect: false,
        rank: "");
  }
  factory ProductModel.fromServiceRefillDatabase(Map<String, dynamic> data) {
    return ProductModel(
        idProduct: data["idProduct"] ?? 0,
        description: data["description"],
        price: data["price"]??-1,
        stock: 0,
        number: 0,
        count: "",
        img: "assets/icons/refill1.png",
        type: 2,
        isSelect: false,
        rank: "");
  }
}
