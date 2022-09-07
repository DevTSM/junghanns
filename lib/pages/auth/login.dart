import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/pages/home/home_principal.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/services/auth.dart';
import '../../components/loading.dart';
import '../../styles/color.dart';
import '../../styles/decoration.dart';
import '../../styles/text.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late Size size;
  late TextEditingController userC, passC;
  late bool isObscure = true;
  late bool isLoading = false;

  @override
  void initState() {
    super.initState();
    userC = TextEditingController();
    passC = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
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
      Visibility(visible: isLoading, child: const LoadingJunghanns())
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

  funLogin() async {
    //_onLoading();
    setState(() {
      isLoading = true;
    });
    if (userC.text.isNotEmpty && passC.text.isNotEmpty) {
      Map<String, dynamic> data = {
        "user": userC.text,
        "pass": passC.text,
      };
      await getClientSecret(userC.text, passC.text).then((answer) async {
        if (answer.error) {
          //Navigator.pop(context);
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
            msg: answer.message,
            timeInSecForIosWeb: 2,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            webShowClose: true,
          );
        } else {
          prefs.clientSecret = answer.body["client_secret"];
          await getToken(userC.text).then((answer1) async {
            if (answer1.error) {
              //Navigator.pop(context);
              setState(() {
                isLoading = false;
              });
              Fluttertoast.showToast(
                msg: answer.message,
                timeInSecForIosWeb: 2,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                webShowClose: true,
              );
            } else {
              prefs.token = answer1.body["token"];
              await login(data).then((answer2) {
                if (answer2.error) {
                  //Navigator.pop(context);
                  setState(() {
                    isLoading = false;
                  });
                  Fluttertoast.showToast(
                    msg: answer2.message,
                    timeInSecForIosWeb: 2,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    webShowClose: true,
                  );
                } else {
                  log(answer.body.toString());
                  prefs.isLogged = true;
                  //---------------------------------- Info DeliveryMan
                  prefs.idUserD = answer2.body["id_usuario"] ?? 0;
                  prefs.idProfileD =
                      int.parse((answer2.body["id_perfil"] ?? 0).toString());
                  prefs.nameUserD = answer2.body["nombre_usuario"] ?? "";
                  prefs.nameD = answer2.body["nombre"] ?? "";
                  prefs.idRouteD =
                      int.parse((answer2.body["id_ruta"] ?? 0).toString());
                  prefs.nameRouteD = answer2.body["nombre_ruta"] ?? "";
                  prefs.dayWorkD = answer2.body["dia_trabajo"] ?? "T";
                  prefs.dayWorkTextD =
                      answer2.body["dia_trabajo_texto"] ?? "TEST";
                  prefs.codeD = answer2.body["codigo_empresa"] ?? "";
                  log(prefs.nameD);
                  //-----------------------------------------
                  //Navigator.pop(context);
                  setState(() {
                    isLoading = false;
                  });
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                          builder: (BuildContext context) => HomePrincipal()));
                }
              });
            }
          });
        }
      });
    } else {
      //Navigator.pop(context);
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

  void _onLoading() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.8),
              borderRadius: const BorderRadius.all(Radius.circular(25)),
            ),
            height: MediaQuery.of(context).size.width * .30,
            width: MediaQuery.of(context).size.width * .30,
            child: const SpinKitDualRing(
              color: Colors.white70,
              lineWidth: 4,
            ),
          ),
        );
      },
    );
  }
}
