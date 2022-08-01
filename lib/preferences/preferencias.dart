import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario {
  static final PreferenciasUsuario _instancia =
      PreferenciasUsuario._internal();

  factory PreferenciasUsuario() {
    return _instancia;
  }

  PreferenciasUsuario._internal();

  SharedPreferences? prefs;
  

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
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
}
