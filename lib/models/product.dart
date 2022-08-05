class ProductModel {
  int idProduct;
  String description;
  double price;
  int stock;
  String img;
  int type; //1 product 2 refill
  bool isSelect;

  ProductModel(
      {required this.idProduct,
      required this.description,
      required this.price,
      required this.stock,
      required this.img,
      required this.type,
      required this.isSelect});

  factory ProductModel.fromState(int id) {
    return ProductModel(
        idProduct: id,
        description: "Cerámica M12 Bco",
        price: 200.00,
        stock: 20,
        img: "assets/images/Ceramica.JPG",
        type: 1,
        isSelect: false);
  }

  factory ProductModel.fromServiceProduct(Map<String, dynamic> data) {
    return ProductModel(
        idProduct: data["idProductoServicio"] ?? 0,
        description: data["descripcion"],
        price: double.parse(data["precio"] ?? "100"),
        stock: data["stock"],
        img: data["url"],
        type: 1,
        isSelect: false);
  }

  setSelect(bool isSelect) {
    this.isSelect = isSelect;
  }

  factory ProductModel.fromServiceRefill(Map<String, dynamic> data) {
    return ProductModel(
        idProduct: data["idProductoServicio"] ?? 0,
        description: data["descripcion"],
        price: double.parse(data["precio"] ?? "0"),
        stock: 0,
        img: "assets/icons/refill1.png",
        type: 2,
        isSelect: false);
  }
}
