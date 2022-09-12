//prefs
//import 'dart:ffi';

import 'package:junghanns/database/database.dart';
import 'package:junghanns/preferences/preferencias.dart';

PreferenciasUsuario prefs = PreferenciasUsuario();
DataBase handler = DataBase();
String ipProd = "https://qro.jusoftdelivery.com";
String ipStage = "https://api-delivery-sandbox.junghanns.app";
String apiKeyStage = "76b2f0a4784e47d5d3ff89b1fd110984ea9f02bf";
String clientSecretStage = "baea25384fe9c8e5140aa49e72a6a841";
String version = "1.0.8";

//String urlBase = ipProd;
String urlBase = ipStage;
String apiKey = apiKeyStage;
String clientSecret = clientSecretStage;
