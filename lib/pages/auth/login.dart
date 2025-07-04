import 'dart:convert';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:junghanns/components/without_internet.dart';
import 'package:junghanns/pages/opening.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/auth.dart';
import 'package:junghanns/util/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../components/loading.dart';
import '../../styles/color.dart';
import '../../styles/decoration.dart';
import '../../styles/text.dart';
import '../socket/socket_service.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late Position _currentLocation;
  late Size size;
  late TextEditingController userC, passC;
  late bool isObscure = true;
  late bool isLoading = false;
  //
  late ProviderJunghanns provider;

  @override
  void initState() {
    super.initState();
    _currentLocation = Position(
      altitudeAccuracy: 1,
      headingAccuracy: 1,
      altitude: 1,
      longitude: 0, 
      accuracy: 1, 
      heading: 1, 
      latitude: 0, 
      speed: 1, 
      speedAccuracy: 1, 
      timestamp: DateTime.now()
    );
    userC = TextEditingController();
    passC = TextEditingController();
    Provider.of<ProviderJunghanns>(context,listen:false).requestAllPermissions();
  }
  Future<Map<String,dynamic>?> getDataLogin() async {
    try{
      bool isPermission=await Permission.phone.isGranted;
      if(!isPermission){
      await Permission.phone.request();
      }
    _currentLocation=(await LocationJunny().getCurrentLocation())!;
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      // Intentamos usar androidInfo.serialNumber si está disponible
      String serial = androidInfo.id ?? "";

      if (serial.isEmpty || serial.length < 2) {
        // Usamos otro campo si es necesario
        serial = androidInfo.fingerprint ?? "";
      }

      // Obtenemos la versión del SO, modelo y marca
      String versionSo = androidInfo.version.release ?? "Desconocido";
      String modelo = androidInfo.model ?? "Desconocido";
      String marca = androidInfo.manufacturer ?? "Desconocido";

    if(_currentLocation.latitude!=0&&_currentLocation.longitude!=0){
      log('''esto enviamos 
          user ${userC.text},
          pass: ${passC.text},
          marca:${marca},
          modelo:${modelo},
          version_so:${versionSo},
          serial:${serial.replaceAll(":", "")},
          lat:${_currentLocation.latitude},
          lon:${_currentLocation.longitude}
        ''');
    return {
          "user": userC.text,
          "pass": passC.text,
          "marca":marca,
          "modelo":modelo,
          "version_so":versionSo,
          "serial":serial.replaceAll(":", ""),
          "lat":_currentLocation.latitude,
          "lon":_currentLocation.longitude
        };
    }else{
      Fluttertoast.showToast(
              msg: "Revisa los permisos de la app",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
            );
    }
    }catch(e){
      log("ERROR:::::: ${e.toString()}");
      Fluttertoast.showToast(
              msg: "Error inesperado: ${e.toString()}",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
            );
            return null;
    }
  }

  funLogin() async {
    if (provider.connectionStatus < 4) {
      setState(() {
        isLoading = true;
      });

      if (userC.text.isNotEmpty && passC.text.isNotEmpty) {
        try {
          final answer = await getClientSecret(userC.text, passC.text);

          if (answer.error || answer.body == null) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(
              msg: answer.message ?? "Error desconocido",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
            );
            return;
          }

          final clientSecret = answer.body["client_secret"];
          if (clientSecret == null) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(
              msg: "Credenciales inválidas",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
            );
            return;
          }

          prefs.clientSecret = clientSecret;

          final answer1 = await getToken(userC.text);
          if (answer1.error || answer1.body == null || answer1.body["token"] == null) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(
              msg: answer1.message ?? "Error al obtener token",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
            );
            return;
          }

          prefs.token = answer1.body["token"];
          Map<String, dynamic> data = (await getDataLogin()) ?? {};

          final answer2 = await login(data);
          if (answer2.error || answer2.body == null) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(
              msg: answer2.message ?? "Error al iniciar sesión",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
            );
            return;
          }

          // Guardado de preferencias
          prefs.isLogged = true;
          prefs.idUserD = answer2.body["id_usuario"] ?? 0;
          prefs.idProfileD = int.tryParse(answer2.body["id_perfil"].toString()) ?? 0;
          prefs.nameUserD = answer2.body["nombre_usuario"] ?? "";
          prefs.nameD = answer2.body["nombre"] ?? "";
          prefs.idRouteD = int.tryParse(answer2.body["id_ruta"].toString()) ?? 0;
          prefs.nameRouteD = answer2.body["nombre_ruta"] ?? "";
          prefs.dayWorkD = answer2.body["dia_trabajo"] ?? "T";
          prefs.dayWorkTextD = answer2.body["dia_trabajo_texto"] ?? "TEST";
          prefs.codeD = answer2.body["codigo_empresa"] ?? "";
          prefs.idChat = int.tryParse(answer2.body["id_chat"].toString()) ?? 0;

          prefs.credentials = jsonEncode({
            "user": userC.text,
            "pass": passC.text,
            "clientSecret": prefs.clientSecret,
            "token": prefs.token,
            "nameD": prefs.nameD,
            "idRouteD": prefs.idRouteD,
            "nameRouteD": prefs.nameRouteD,
          });

          if (prefs.lastIdRouteD != prefs.idRouteD) {
            prefs.asyncLast = "";
          }
          prefs.lastIdRouteD = prefs.idRouteD;

          setState(() {
            isLoading = false;
          });

          FirebaseMessaging.instance.getToken().then((value) async {
            if (value != null) {
              await updateToken(value).then((ans) {
                if (ans.error) {
                  Fluttertoast.showToast(
                    msg: "No fue posible actualizar el servicio de notificaciones",
                    timeInSecForIosWeb: 2,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    webShowClose: true,
                  );
                }
              });
            }
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Opening(isLogin: true)),
          );
          await SocketService().connectIfLoggedIn();
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
            msg: "Error inesperado: ${e.toString()}",
            timeInSecForIosWeb: 2,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            webShowClose: true,
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
          msg: "Campos vacíos",
          timeInSecForIosWeb: 4,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      }
    } else {
      Map<String, dynamic> data = jsonDecode(prefs.credentials);
      if ((data["user"] ?? "-1") == userC.text &&
          (data["pass"] ?? "-1") == passC.text) {
        prefs.clientSecret = data["clientSecret"] ?? "";
        prefs.token = data["token"] ?? "";
        prefs.nameD = data["nameD"] ?? "";
        prefs.idRouteD = data["idRouteD"] ?? "";
        prefs.nameRouteD = data["nameRouteD"] ?? "";
        prefs.isLogged = true;
        Fluttertoast.showToast(
          msg: "Sin conexión a internet",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
        Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
                builder: (BuildContext context) => Opening(
                      isLogin: true,
                    )));
      } else {
        Fluttertoast.showToast(
          msg: "Los datos no coinciden.",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    provider = Provider.of<ProviderJunghanns>(context);
    return Scaffold(
        body: Stack(children: [
      Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                "assets/images/junghannsWater.png",
              ),
              fit: BoxFit.cover),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.1,
              ),
              Visibility(
                  visible: provider.connectionStatus == 4,
                  child: const WithoutInternet()),
              Container(
                  margin: EdgeInsets.only(
                      top: size.height * .05, left: 30, right: 30),
                  child: Image.asset(
                    "assets/images/junghannsLogo.png",
                  )),
              const SizedBox(
                height: 10,
              ),
              cardLogin()
            ],
          ),
        ),
      ),
      textVersion(),
      Visibility(visible: isLoading, child: const LoadingJunghanns()),
      Visibility(
        visible: !provider.permission,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _notPermission(msj: provider.labelPermission)
        )
      ),
    ]));
  }

  Widget cardLogin() {
    return Container(
      width: size.width * 0.85,
      height: size.width * 0.75,
      padding: EdgeInsets.all(size.height * 0.03),
      decoration: Decorations.whiteCard,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          textField(userC, "Usuario", "assets/icons/user.png", false),
          textField(passC, "Contraseña", "assets/icons/password.png", true),
          buttonLog()
        ],
      ),
    );
  }

  Widget textField(TextEditingController controller, String hintText,
      String iconS, bool isPass) {
    return SizedBox(
        height: size.height * 0.06,
        child: TextFormField(
            controller: controller,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyles.blue18SemiBoldIt,
            obscureText: isPass ? isObscure : false,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyles.blue18SemiBoldIt,
              filled: true,
              fillColor: ColorsJunghanns.whiteJ,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              prefixIcon: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: Image.asset(
                    iconS,
                  )),
              suffixIcon: isPass
                  ? visibleIcon()
                  : const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10)),
            )));
  }

  Widget visibleIcon() {
    return GestureDetector(
      child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
          child: Icon(
            isObscure ? Icons.visibility_off : Icons.visibility,
            color: ColorsJunghanns.blueJ2,
          )),
      onTap: () {
        log("Cambiar");
        setState(() {
          isObscure = !isObscure;
        });
      },
    );
  }

  Widget buttonLog() {
    return GestureDetector(
        child: Container(
          width: double.infinity,
          height: 40,
          alignment: Alignment.center,
          color: ColorsJunghanns.greenJ,
          child: Text(
            "Iniciar sesión",
            style: TextStyles.white16SemiBoldIt,
          ),
        ),
        onTap: () => funLogin());
  }

  

  Widget textBottom() {
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [textAP(), textDR()],
      ),
    );
  }

  Widget textAP() {
    return GestureDetector(
        child: AutoSizeText(
          "Aviso de privacidad",
          maxLines: 1,
          style: TextStyles.blue17SemiBoldUnderline,
        ),
        onTap: () {});
  }

  Widget textDR() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 8),
      child: AutoSizeText(
        "Todos los derechos reservados 2022. MAFIN SA. de CV.",
        maxLines: 1,
        style: TextStyles.blue15SemiBold,
      ),
    );
  }

  Widget textVersion() {
    return Container(
      alignment: Alignment.topRight,
      margin: const EdgeInsets.only(top: 44, right: 12),
      child: Text(
        "${prefs.labelCedis} V$version",
        style: TextStyles.blue18SemiBoldIt,
      ),
    );
  }
  Widget _notPermission({required String msj}){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
      width: double.infinity,
      height: 120,
      alignment: Alignment.center,
      color: JunnyColor.red5c,
      child: AutoSizeText(
        msj,
        style: JunnyText.semiBoldBlueA1(18).copyWith(color: JunnyColor.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
