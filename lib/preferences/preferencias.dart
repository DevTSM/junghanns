import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario {
  static final PreferenciasUsuario _instancia = PreferenciasUsuario._internal();

  factory PreferenciasUsuario() {
    return _instancia;
  }

  PreferenciasUsuario._internal();

  SharedPreferences? prefs;

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }
  int get existStock {
    return prefs!.getInt("existStock") ?? 0;
  }
  set existStock(int existStock) {
    prefs!.setInt("existStock", existStock);
  }
  int get soldStock {
    return prefs!.getInt("soldStock") ?? 0;
  }
  set soldStock(int soldStock) {
    prefs!.setInt("soldStock", soldStock);
  }
  String get qr {
    return prefs!.getString("qr") ?? "";
  }
  set qr(String qr) {
    prefs!.setString("qr", qr);
  }
   String get lastBitacoraUpdate {
    return prefs!.getString("lastBitacoraUpdate") ?? "";
  }
  set lastBitacoraUpdate(String lastBitacoraUpdate) {
    prefs!.setString("lastBitacoraUpdate", lastBitacoraUpdate);
  }
   String get lastRouteUpdate {
    return prefs!.getString("lastRouteUpdate") ?? "";
  }
  set lastRouteUpdate(String lastRouteUpdate) {
    prefs!.setString("lastRouteUpdate", lastRouteUpdate);
  }
  String get statusRoute {
    return prefs!.getString("statusRoute") ?? "";
  }
  set statusRoute(String statusRoute) {
    prefs!.setString("statusRoute", statusRoute);
  }

  String get urlBase {
    return prefs!.getString("urlBase") ?? "";
  }

  set urlBase(String urlBase) {
    prefs!.setString("urlBase", urlBase);
  }
  String get labelCedis {
    return prefs!.getString("labelCedis") ?? "";
  }

  set labelCedis(String labelCedis) {
    prefs!.setString("labelCedis", labelCedis);
  }
  
  String get credentials {
    return prefs!.getString("credentials") ?? "";
  }

  set credentials(String credentials) {
    prefs!.setString("credentials", credentials);
  }
  String get brands {
    return prefs!.getString("brands") ?? "";
  }

  set brands(String brands) {
    prefs!.setString("brands", brands);
  }
  String get channelValidation {
    return prefs!.getString("channelValidation") ?? "";
  }

  set channelValidation(String channelValidation) {
    prefs!.setString("channelValidation", channelValidation);
  }
  String get dashboard {
    return prefs!.getString("dashboard") ?? "{}";
  }

  set dashboard(String dashboard) {
    prefs!.setString("dashboard", dashboard);
  }

  String get ipUrl {
    return prefs!.getString("ipUrl") ?? "";
  }

  set ipUrl(String ipUrl) {
    prefs!.setString("ipUrl", ipUrl);
  }

  String get version {
    return prefs!.getString("version") ?? "";
  }

  set version(String version) {
    prefs!.setString("version", version);
  }

  String get clientSecret {
    return prefs!.getString("clientSecret") ?? "";
  }

  set clientSecret(String clientSecret) {
    prefs!.setString("clientSecret", clientSecret);
  }

  String get token {
    return prefs!.getString("token") ?? "";
  }

  set token(String token) {
    prefs!.setString("token", token);
  }

  String get asyncLast {
    return prefs!.getString("asyncLast") ?? "";
  }

  set asyncLast(String asyncLast) {
    prefs!.setString("asyncLast", asyncLast);
  }
  bool get isAsyncCurrent {
    return prefs!.getBool("isAsyncCurrent") ?? true;
  }

  set isAsyncCurrent(bool isAsyncCurrent) {
    prefs!.setBool("isAsyncCurrent", isAsyncCurrent);
  }

  bool get isLogged {
    return prefs!.getBool("isLogged") ?? false;
  }

  set isLogged(bool isLogged) {
    prefs!.setBool("isLogged", isLogged);
  }
  bool get customerP {
    return prefs!.getBool("customerP") ?? false;
  }

  set customerP(bool customerP) {
    prefs!.setBool("customerP", customerP);
  }

  bool get dataStop {
    return prefs!.getBool("dataStop") ?? false;
  }

  set dataStop(bool dataStop) {
    prefs!.setBool("dataStop", dataStop);
  }
  String get branchOTP {
    return prefs!.getString("branchOTP") ?? "";
  }

  set branchOTP(String branchOTP) {
    prefs!.setString("branchOTP", branchOTP);
  }

  bool get dataSale {
    return prefs!.getBool("dataSale") ?? false;
  }

  set dataSale(bool dataSale) {
    prefs!.setBool("dataSale", dataSale);
  }

  bool get isUpdateDB {
    return prefs!.getBool("isUpdateDB") ?? false;
  }

  set isUpdateDB(bool isUpdateDB) {
    prefs!.setBool("isUpdateDB", isUpdateDB);
  }
  bool get isRequest {
    return prefs!.getBool("isRequest") ?? false;
  }

  set isRequest(bool isRequest) {
    prefs!.setBool("isRequest", isRequest);
  }

  bool get conectado {
    return prefs!.getBool("conectado") ?? false;
  }

  set conectado(bool conectado) {
    prefs!.setBool("conectado", conectado);
  }
  //Info DeliveryMan
  //---------------------------------------------------------

  int get idUserD {
    return prefs!.getInt("idUserD") ?? 0;
  }

  set idUserD(int idUserD) {
    prefs!.setInt("idUserD", idUserD);
  }

  int get idProfileD {
    return prefs!.getInt("idProfileD") ?? 0;
  }

  set idProfileD(int idProfileD) {
    prefs!.setInt("idProfileD", idProfileD);
  }

  String get nameUserD {
    return prefs!.getString("nameUserD") ?? "";
  }

  set nameUserD(String nameUserD) {
    prefs!.setString("nameUserD", nameUserD);
  }

  String get nameD {
    return prefs!.getString("nameD") ?? "";
  }

  set nameD(String nameD) {
    prefs!.setString("nameD", nameD);
  }

  int get idRouteD {
    return prefs!.getInt("idRouteD") ?? 0;
  }

  set idRouteD(int idRouteD) {
    prefs!.setInt("idRouteD", idRouteD);
  }
  int get lastIdRouteD {
    return prefs!.getInt("lastIdRouteD") ?? 0;
  }

  set lastIdRouteD(int lastIdRouteD) {
    prefs!.setInt("lastIdRouteD", lastIdRouteD);
  }

  String get nameRouteD {
    return prefs!.getString("nameRouteD") ?? "";
  }

  set nameRouteD(String nameRouteD) {
    prefs!.setString("nameRouteD", nameRouteD);
  }

  String get dayWorkD {
    return prefs!.getString("dayWorkD") ?? "";
  }

  set dayWorkD(String dayWorkD) {
    prefs!.setString("dayWorkD", dayWorkD);
  }

  String get dayWorkTextD {
    return prefs!.getString("dayWorkTextD") ?? "";
  }

  set dayWorkTextD(String dayWorkTextD) {
    prefs!.setString("dayWorkTextD", dayWorkTextD);
  }

  String get codeD {
    return prefs!.getString("codeD") ?? "";
  }

  set codeD(String codeD) {
    prefs!.setString("codeD", codeD);
  }
}
