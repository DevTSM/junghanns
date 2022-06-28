import 'package:junghanns/models/sale.dart';

class CustomerModel {
  bool invoice;
  int id;
  int idClient;
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
  List<SaleModel> history;
  CustomerModel(
      {
        required this.invoice,
      required this.id,
      required this.idClient,
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
      required this.observation,
      required this.history});
  factory CustomerModel.fromState() {
    return CustomerModel(
      invoice: true,
        id: 0,
        idClient: 0,
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
        observation: "",
        history: []);
  }
  factory CustomerModel.fromList(Map<String, dynamic> data, int idRoute) {
    return CustomerModel(
      invoice: false,
        id: data["id"],
        idClient: data["idCliente"],
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
        category: (data["categoria"]??"C")=="C"?"Cliente":"Empresa",
        days: "",
        observation: "",
        history: []);
  }
  factory CustomerModel.fromService(Map<String, dynamic> data,int id) {
    return CustomerModel(
      invoice: false,
      id:id,
        idClient: data["idCliente"]??0,
        idRoute: data["idRuta"]??0,
        lat: double.parse(data["latitud"]),
        lng: double.parse(data["longitud"]),
        priceLiquid: double.parse(data["precioLiquido"]??"0"),
        byCollect: double.parse((data["porCobrar"]??0).toString()),
        purse: double.parse((data["monedero"]??0).toString()),
        name: data["nombre"]??"",
        address: data["domicilio"]??"",
        nameRoute: data["ruta"]??"",
        typeVisit: data["tipoVisita"]??"",
        category: (data["categoria"]??"C")=="C"?"Cliente":"Empresa",
        days: data["diasVisita"]??"",
        observation: (data["observacion"]??"")==""?"Sin observaciones":data["observacion"]??"",
        history: data["historial"]!=null?List.from(data["historial"].map((e)=>SaleModel.fromService(e)).toList()):[]);
  }
}
