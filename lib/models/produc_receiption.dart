import 'package:junghanns/models/product.dart';

class ProductReceiptionModel {
  int id;
  String product;
  double count;
  int folio;
  String img;

  ProductReceiptionModel(
      {required this.id,
        required this.product,
        required this.count,
        required this.folio,
        required this.img,
       });

  factory ProductReceiptionModel.from(Map<String, dynamic> data) {
    return ProductReceiptionModel(
      id: int.parse((data["id"] ?? data["id_producto"] ?? data["id_devolucion"] ?? 0).toString()),
      /*id: int.parse((data["id"] ?? 0).toString()),*/
      product: data["producto"] ?? "",
      count: double.parse((data["cantidad"] ?? data["stock"] ?? "0").toString()),
      img: data["url"] ?? "",
      folio: int.parse((data["folio"] ?? 0).toString()),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto': product,
      'cantidad': count,
    };
  }
  Map<String, dynamic> toJsonOthers() {
    return {
      'id': id,
      'producto': product,
      'cantidad': count,
      'url': img,
    };
  }
  Map<String, dynamic> toProduct() {
    return {
      'id_producto': id,
      'cantidad': count,
    };
  }
  Map<String, dynamic> toProductReturn() {
    return {
      'id_devolucion': id,
      'cantidad': count,
      'folio': folio,
      'producto': product
    };
  }
  ProductReceiptionModel copy() {
    return ProductReceiptionModel(
      id: id,
      product: product,
      count: count,
      folio: folio,
      img: img,
    );
  }

  bool isEqualWithoutImage(ProductReceiptionModel other) {
    return this.id == other.id &&
        this.product == other.product &&
        this.count == other.count;
  }

  // Método para convertir ProductReceiptionModel a ProductModel
  ProductModel toProductModel() {
    return ProductModel(
      idProduct: id, // Asumimos que id se usa como idProduct
      description: product, // Asumiendo que 'product' es la descripción
      price: 0.0, // Establecer un valor por defecto
      stock: 0, // Establecer un valor por defecto
      stockLocal: 0, // Establecer un valor por defecto
      number: 0, // Establecer un valor por defecto
      img: img,
      type: 1, // Establecer un valor por defecto o cambiar según tu lógica
      count: count.toString(), // Convertir count a String
      isSelect: false, // Establecer un valor por defecto
      rank: '', // Establecer un valor por defecto
      label: '', // Establecer un valor por defecto
    );
  }

  @override
  String toString() {
    return 'ProductModell(id: $id, producto: $product, folio: $folio, cantidad: $count, img: $img)';
  }

  factory ProductReceiptionModel.empty(){
    return ProductReceiptionModel(id: 0, product: '', count: 1, img: '', folio: 0);
  }
}
