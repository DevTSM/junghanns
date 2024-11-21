import 'package:junghanns/models/carboy.dart';
import 'package:junghanns/models/carboyEleven.dart';
import 'package:junghanns/models/demineralized.dart';
import 'package:junghanns/models/produc_receiption.dart';

class DeliverProductsModel {
  int idRoute;
  CarboyModel carboys;
  DemineralizedModel demineralizeds;
  CarboyElevenModel carboysEleven;
  List<ProductReceiptionModel> others;
  List<ProductReceiptionModel> returns;

  DeliverProductsModel({
    required this.idRoute,
    required this.carboys,
    required this.demineralizeds,
    required this.carboysEleven,
    required this.others,
    required this.returns,
  });

  DeliverProductsModel copy() {
    return DeliverProductsModel(
      idRoute: this.idRoute,
      carboys: this.carboys.copy(),
      demineralizeds: this.demineralizeds,
      carboysEleven: this.carboysEleven,
      others: this.others,
      returns: this.returns,
    );
  }
  DeliverProductsModel copyOthers() {
    return DeliverProductsModel(
      idRoute: this.idRoute,
      carboys: this.carboys.copy(),
      demineralizeds: this.demineralizeds.copy(),
      carboysEleven: this.carboysEleven.copy(),// Copia de carboys
      others: this.others.map((e) => e.copy()).toList(), // Copia profunda de others
      returns: this.returns.map((e) => e.copy()).toList(), // Copia profunda de returns si es necesario
    );
  }

  factory DeliverProductsModel.empty(){
    return DeliverProductsModel(idRoute: 0, carboys: CarboyModel.empty(), demineralizeds: DemineralizedModel.empty(), carboysEleven: CarboyElevenModel.empty(), others: [], returns: []);
  }

  factory DeliverProductsModel.fromJson(Map<String, dynamic> json) {
    return DeliverProductsModel(
      idRoute: int.tryParse(json["id_ruta"].toString()) ?? 0,
      carboys: CarboyModel.from(json['garrafones']),
      demineralizeds: DemineralizedModel.from(json['desmineralizados']),
      carboysEleven: CarboyElevenModel.from(json['garradon11l']),
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
      'desmineralizados': demineralizeds,
      'garradon11l': carboysEleven,
      'otros': others.map((item) => item.toJsonOthers()).toList(),
      'devoluciones': returns.map((item) => item.toProductReturn()).toList(),
      // 'productos': products.toJson(),
    };
  }
  @override
  String toString() {
    return 'ValidationModel( id_ruta: $idRoute, garrafones:$carboys, desmineralizados:$demineralizeds, garradon11l:$carboysEleven, otros: $others, devoluciones: $returns)';
  }
}
