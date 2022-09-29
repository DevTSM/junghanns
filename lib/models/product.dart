class ProductModel {
  int idProduct;
  String description;
  double price;
  int stock;
  int number;
  String img;
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
      required this.isSelect,
      required this.rank});

  factory ProductModel.fromState(int id) {
    return ProductModel(
        idProduct: id,
        description: "Cerámica M12 Bco",
        price: 200.00,
        stock: 20,
        number: 0,
        img: "assets/images/Ceramica.JPG",
        type: 1,
        isSelect: false,
        rank: "");
  }
  factory ProductModel.fromProduct(ProductModel productCurrent) {
    return ProductModel(
        idProduct: productCurrent.idProduct,
        description: productCurrent.description,
        price: productCurrent.price,
        stock: productCurrent.stock,
        number: 0,
        img: productCurrent.img,
        type: productCurrent.type,
        isSelect: false,
        rank: productCurrent.rank);
  }
  factory ProductModel.fromServiceProduct(Map<String, dynamic> data) {
    return ProductModel(
        idProduct: data["idProductoServicio"] ?? 0,
        description: data["descripcion"],
        price: double.parse((data["precio"] ?? "0").toString()),
        stock: int.parse((data["stock"]??(data["cantidad"] ?? 0)).toString()),
        number: 0,
        img: data["url"],
        type: 1,
        isSelect: false,
        rank: data["rank"] ?? "");
  }

  setSelect(bool isSelect) {
    this.isSelect = isSelect;
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
        isSelect: false,
        rank: "");
  }
  factory ProductModel.fromServiceRefillDatabase(Map<String, dynamic> data) {
    return ProductModel(
        idProduct: data["idProduct"] ?? 0,
        description: data["description"],
        price: data["precio"],
        stock: 0,
        number: 0,
        img: "assets/icons/refill1.png",
        type: 2,
        isSelect: false,
        rank: "");
  }
}
