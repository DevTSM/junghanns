//prefs
//import 'dart:ffi';

import 'package:junghanns/database/database.dart';
import 'package:junghanns/preferences/preferencias.dart';

PreferenciasUsuario prefs = PreferenciasUsuario();
DataBase handler = DataBase();
String ipProd = "https://qro.jusoftdelivery.com/v2/";
String ipCDMX="https://cdmx-norte.jusoftdelivery.com/";
String ipStage = "https://api-delivery-sandbox.junghanns.app/";
String ipStage2 = "https://api-delivery-sandbox.junghanns.app/v2/";
String ipPueSur = "https://pue-sur.jusoftdelivery.com/";
String ipPueOr="https://pue-ote.jusoftdelivery.com/";
String apiKeyStage = "76b2f0a4784e47d5d3ff89b1fd110984ea9f02bf";
String clientSecretStage = "baea25384fe9c8e5140aa49e72a6a841";
String messajeConnection="Error de comunicación con la Planta. La atención se completó correctamente de manera local. Por favor, sincronice.";
String nameDB="junny6.db";
String version = "23.1.15";
String validVersion = "9.04";
int timerDuration=28;

String urlBaseManuality = ipStage2;
//String urlBase = ipCDMX;
//String urlBase=prefs.urlBase;
String apiKey = apiKeyStage;
String clientSecret = clientSecretStage;
