import 'package:junghanns/models/product.dart';

class AuthorizationModel {
  int idAuth;
  int idClient;
  int idCatAuth;
  String authText;
  String observation;
  String type;
  int idReasonAuth;
  String reason;
  ProductModel product;

  AuthorizationModel(
      {required this.idAuth,
      required this.idClient,
      required this.idCatAuth,
      required this.authText,
      required this.type,
      required this.observation,
      required this.idReasonAuth,
      required this.reason,
      required this.product});

  factory AuthorizationModel.fromState() {
    return AuthorizationModel(
        idAuth: 0,
        product: ProductModel.fromState(0),
        idClient: 0,
        idCatAuth: 0,
        authText: "TEST",
        type: "0",
        observation: "",
        idReasonAuth: 0,
        reason: "TEST");
  }

  factory AuthorizationModel.fromService(Map<String, dynamic> data) {
    return AuthorizationModel(
        idAuth: data["id"],
        product: ProductModel.fromServiceProduct(data),
        idClient: data["idCliente"] ?? 0,
        type: data["tipo"] ?? "",
        idCatAuth: data["idCatAutorizacion"] ?? 0,
        authText: data["autorizacion"] ?? "",
        observation: data["observacion"] ?? "",
        idReasonAuth: data["idMotivoAutorizacion"] ?? 0,
        reason: data["Motivo"] ?? "");
  }

  // ProductModel getProduct() {
  //   return ProductModel(
  //       idProduct: idProduct,
  //       description: description,
  //       price: price,
  //       stock: number,
  //       img: img,
  //       type: 1,
  //       number: 1,
  //       isSelect: false,
  //       rank: "");
  // }
}
