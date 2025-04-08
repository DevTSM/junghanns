import 'package:junghanns/models/produc_receiption.dart';

class ValidationProductModel {
  int idValidation;
  int idRoute;
  String status;
  String statusText;
  String rejection_comment;
  String valid;
  String typeValidation;
  String validationText;
  List<ProductReceiptionModel> products;
  // ProductModel products;


  ValidationProductModel({
    required this.idValidation,
    required this.idRoute,
    required this.status,
    required this.statusText,
    required this.rejection_comment,
    String? valid,
    required this.typeValidation,
    required this.validationText,
    required this.products,
  }): valid = valid ?? '';

  factory ValidationProductModel.fromJson(Map<String, dynamic> json) {
    return ValidationProductModel(
      idValidation: json["id_validacion"] ?? 0,
      idRoute: json["id_ruta"] ?? 0,
      status: json["estatus"] ?? '',
      statusText: json["estatus_text"] ?? '',
      rejection_comment: json["cometario_baja_rechazo"] ?? '',
      valid: json["valida"] ?? '',
      typeValidation: json["tipo_validacion"] ?? '',
      validationText: json["tipo_validacion_text"] ?? '',
      // products: ProductModel.fromProductInventary(json['productos'] ?? {}),
      /*products: List<ProductReceiptionModel>.from(
        json['productos'].map((x) => ProductReceiptionModel.from(x)),
      ),*/
      products: List<ProductReceiptionModel>.from(
        (json['productos'] as List<dynamic>).map(
              (product) => ProductReceiptionModel.from(product as Map<String, dynamic>),
        ),
      ),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id_validacion': idValidation,
      'id_ruta': idRoute,
      'estatus': status,
      'estatus_text': status,
      'cometario_baja_rechazo': rejection_comment,
      'valida': valid,
      'tipo_validacion': typeValidation,
      'tipo_validacion_text': validationText,
      // 'productos': products.toJson(),
    };
  }
  @override
  String toString() {
    return 'ValidationModel( id_validacion: $idValidation, id_ruta:$idRoute, estatus: $status, estatus_text: $statusText, cometario_baja_rechazo: $rejection_comment, valida: $valid, tipo_validacion: $typeValidation, tipo_validacion_text: $validationText, products: $products)';
  }
}
