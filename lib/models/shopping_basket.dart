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
  double lat;
  double lng;
  List<ProductB> sales;
  int idAuth;
  List<WayToPay> waysToPay;
  int idDataOrigin;
  int folio;
  String typeOperation;

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
      required this.typeOperation});

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
        typeOperation: "V");
  }
}
