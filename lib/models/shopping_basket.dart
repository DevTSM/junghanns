import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/preferences/global_variables.dart';

class WayToPay {
  String type;
  double cost;

  WayToPay({required this.type, required this.cost});
}

class ProductB {
  int number;
  int idProduct;
  double unitPrice;

  ProductB(
      {required this.number, required this.idProduct, required this.unitPrice});
}

class BasketModel {
  int idCustomer;
  int idRoute;
  int idAuth;
  int idDataOrigin;
  int folio;
  double lat;
  double lng;
  double totalPrice;
  double addPrice;
  String typeOperation;
  List<ProductModel> sales;
  List<WayToPay> waysToPay;

  BasketModel(
      {required this.idCustomer,
      required this.idRoute,
      required this.lat,
      required this.lng,
      required this.sales,
      required this.idAuth,
      required this.waysToPay,
      required this.idDataOrigin,
      required this.folio,
      required this.typeOperation,
      required this.totalPrice,
      this.addPrice=0});

  factory BasketModel.fromState() {
    return BasketModel(
        idCustomer: -1,
        idRoute: -1,
        lat: 0.0,
        lng: 0.0,
        sales: [],
        idAuth: -1,
        waysToPay: [],
        idDataOrigin: -1,
        folio: -1,
        typeOperation: "V",
        totalPrice: 0);
  }
  factory BasketModel.fromInit(CustomerModel customerCurrent) {
    return BasketModel(
        idCustomer: customerCurrent.idClient,
        idRoute: prefs.idRouteD,
        lat: customerCurrent.lat,
        lng: customerCurrent.lng,
        sales: [],
        idAuth: -1,
        waysToPay: [],
        idDataOrigin: customerCurrent.id,
        folio: -1,
        typeOperation: "V",
        totalPrice: 0,
        addPrice: (customerCurrent.priceS * customerCurrent.numberS)
        );
  }
}
