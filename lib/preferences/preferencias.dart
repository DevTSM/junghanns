import 'package:junghanns/models/delivery_man.dart';
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

  bool get isLogged {
    return prefs!.getBool("isLogged") ?? false;
  }

  set isLogged(bool isLogged) {
    prefs!.setBool("isLogged", isLogged);
  }

  bool get dataStop {
    return prefs!.getBool("dataStop") ?? false;
  }

  set dataStop(bool dataStop) {
    prefs!.setBool("dataStop", dataStop);
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
