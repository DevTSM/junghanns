import 'package:junghanns/models/product.dart';

class AuthorizationModel {
  int idAuth;
  int idProduct;
  String description;
  double price;
  int number;
  int idClient;
  int idCatAuth;
  String authText;
  String type;
  String observation;
  int idReasonAuth;
  String reason;
  String img;

  AuthorizationModel(
      {required this.idAuth,
      required this.idProduct,
      required this.description,
      required this.price,
      required this.number,
      required this.idClient,
      required this.idCatAuth,
      required this.authText,
      required this.type,
      required this.observation,
      required this.idReasonAuth,
      required this.reason,
      required this.img});

  factory AuthorizationModel.fromState() {
    return AuthorizationModel(
        idAuth: 0,
        idProduct: 0,
        description: "TEST",
        price: 0.0,
        number: 0,
        idClient: 0,
        idCatAuth: 0,
        authText: "TEST",
        type: "0",
        observation: "",
        idReasonAuth: 0,
        reason: "TEST",
        img: "https://jnsc.mx/img/garrafon.png");
  }

  factory AuthorizationModel.fromService(Map<String, dynamic> data) {
    return AuthorizationModel(
        idAuth: data["id"],
        idProduct: data["idProductoServicio"] ?? 0,
        description: data["descripcion"] ?? "",
        price: double.parse((data["precio"] ?? "0").toString()),
        number: data["cantidad"] ?? 0,
        idClient: data["idCliente"] ?? 0,
        idCatAuth: data["idCatAutorizacion"] ?? 0,
        authText: data["autorizacion"] ?? "",
        type: data["tipo"] ?? "",
        observation: data["observacion"] ?? "",
        idReasonAuth: data["idMotivoAutorizacion"] ?? 0,
        reason: data["Motivo"] ?? "",
        img: data["url"] ?? "");
  }

  ProductModel getProduct() {
    return ProductModel(
        idProduct: idProduct,
        description: description,
        price: price,
        stock: number,
        img: img,
        type: 1,
        isSelect: false);
  }
}
