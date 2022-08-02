class ProductModel {
  List<String> name;
  String img;
  double price;
  int id;
  int type; //1 product 2 refill
  bool isSelect;
  ProductModel(
      {required this.name,
      required this.img,
      required this.price,
      required this.id,
      required this.type,
      required this.isSelect});
  factory ProductModel.fromState(int id) {
    return ProductModel(
        name: ["Cerámica ", "M12 Bco"],
        img: "assets/images/Ceramica.JPG",
        price: 45,
        id: id,
        type: 1,
        isSelect: false);
  }
  factory ProductModel.fromServiceRefill(Map<String, dynamic> data) {
    return ProductModel(
        name: [data["descripcion"] ?? "", ""],
        img: "assets/icons/refill1.png",
        price: double.parse(data["precio"] ?? "0"),
        id: data["idProductoServicio"] ?? 0,
        type: 2,
        isSelect: false);
  }
  setSelect(bool isSelect) {
    this.isSelect = isSelect;
  }
}
