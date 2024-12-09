import 'package:junghanns/models/carboy.dart';
import 'package:junghanns/models/produc_receiption.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/models/product_catalog.dart';

class DeliveryModel {
  CarboyModel carboys;
  List<ProductReceiptionModel> others;
  List<ProductModel> missings;
  List<ProductCatalogModel> additionals;

  DeliveryModel(
      {required this.carboys,
        required this.others,
        required this.missings,
        required this.additionals,
      });

  Map<String, dynamic> toJson() {
    return {
      'garrafon': carboys.toJson(),
      'faltantes': missings.map((e) => e.toProduct()).toList(),
      'otros': others.map((e) => e.toProduct()).toList(),
      'adicionales': additionals.map((e) => e.toProduct()).toList(),
    };
  }

  @override
  String toString() {
    return 'Delivery(garrafon: $carboys, faltantes: $missings, otros: $others, adicionales: $additionals,)';
  }
}
