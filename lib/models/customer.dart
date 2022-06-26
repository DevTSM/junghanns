class CustomerModel {
  int id;
  int idRoute;
  double lat;
  double lng;
  double priceLiquid;
  double byCollect;
  double purse;
  String name;
  String address;
  String nameRoute;
  String typeVisit;
  String category;
  String days;
  String observation;
  CustomerModel(
      {required this.id,
      required this.idRoute,
      required this.lat,
      required this.lng,
      required this.priceLiquid,
      required this.byCollect,
      required this.purse,
      required this.name,
      required this.address,
      required this.nameRoute,
      required this.typeVisit,
      required this.category,
      required this.days,
      required this.observation});
  factory CustomerModel.fromState() {
    return CustomerModel(
        id: 0,
        idRoute: 0,
        lat: 0,
        lng: 0,
        priceLiquid: 0.0,
        byCollect: 0.0,
        purse: 0.0,
        name: "",
        address: "",
        nameRoute: "",
        typeVisit: "",
        category: "",
        days: "",
        observation: "");
  }
  factory CustomerModel.fromList(Map<String, dynamic> data, int idRoute) {
    return CustomerModel(
        id: data["idCliente"],
        idRoute: idRoute,
        lat: 0,
        lng: 0,
        priceLiquid: 0,
        byCollect: 0,
        purse: 0,
        name: data["nombre"],
        address: data["direccion"],
        nameRoute: "",
        typeVisit: data["tipoVisita"],
        category: data["categoria"],
        days: "",
        observation: "");
  }
}
