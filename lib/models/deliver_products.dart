import 'package:junghanns/models/carboy.dart';
import 'package:junghanns/models/produc_receiption.dart';

class DeliverProductsModel {
  int idRoute;
  CarboyModel carboys;
  List<ProductReceiptionModel> others;
  List<ProductReceiptionModel> returns;

  DeliverProductsModel({
    required this.idRoute,
    required this.carboys,
    required this.others,
    required this.returns,
  });

  DeliverProductsModel copy() {
    return DeliverProductsModel(
      idRoute: this.idRoute,
      carboys: this.carboys.copy(),
      others: this.others,
      returns: this.returns,
    );
  }
  DeliverProductsModel copyOthers() {
    return DeliverProductsModel(
      idRoute: this.idRoute,
      carboys: this.carboys.copy(), // Copia de carboys
      others: this.others.map((e) => e.copy()).toList(), // Copia profunda de others
      returns: this.returns.map((e) => e.copy()).toList(), // Copia profunda de returns si es necesario
    );
  }

  factory DeliverProductsModel.empty(){
    return DeliverProductsModel(idRoute: 0, carboys: CarboyModel.empty(), others: [], returns: []);
  }

  factory DeliverProductsModel.fromJson(Map<String, dynamic> json) {
    return DeliverProductsModel(
      idRoute: int.tryParse(json["id_ruta"].toString()) ?? 0,
      carboys: CarboyModel.from(json['garrafones']),
      others: List<ProductReceiptionModel>.from(
        json['otros'].map((x) => ProductReceiptionModel.from(x)),
      ),
      returns: List<ProductReceiptionModel>.from(
        json['devoluciones'].map((x) => ProductReceiptionModel.from(x)),
      ),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id_ruta': idRoute,
      'garrafones': carboys,
      'otros': others.map((item) => item.toJsonOthers()).toList(),
      'devoluciones': returns.map((item) => item.toProductReturn()).toList(),
      // 'productos': products.toJson(),
    };
  }
  @override
  String toString() {
    return 'ValidationModel( id_ruta: $idRoute, garrafones:$carboys, otros: $others, devoluciones: $returns)';
  }
}
