import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:junghanns/styles/color_styles.dart';
import 'package:junghanns/styles/text_styles.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late double sw, sh;
  late TextEditingController userC, passC;

  @override
  void initState() {
    super.initState();
    userC = TextEditingController();
    passC = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    sw = MediaQuery.of(context).size.width;
    sh = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SingleChildScrollView(
            child: Stack(
      children: [fondo(), menu(), textB()],
    )));
  }

  Widget fondo() {
    return SizedBox(
      width: sw,
      height: sh,
      child: Image.asset(
        "assets/images/JUNGHANNS_WPA_V1_ele-01.png",
        fit: BoxFit.cover,
      ),
    );
  }

  Widget menu() {
    return SizedBox(
      width: sw,
      height: sh,
      child: Column(
        children: [
          SizedBox(
            height: sh * 0.15,
          ),
          logoJ(),
          SizedBox(
            height: sh * 0.06,
          ),
          cardLogin(),
        ],
      ),
    );
  }

  Widget textB() {
    return Container(
      width: sw,
      height: sh,
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [textAP(), textDR()],
      ),
    );
  }

  Widget logoJ() {
    return Image.asset(
      "assets/images/JUNGHANNS_WPA_V1_ele-03.png",
      width: sw * 0.64,
    );
  }

  Widget cardLogin() {
    return Container(
      width: sw * 0.85,
      height: sw * 0.75,
      padding: EdgeInsets.all(sh * 0.03),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 3.0,
            )
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          textField(
              userC, "Usuario", "assets/icons/JUNGHANNS_WPA_V1_ele-04.png"),
          textField(
              passC, "Contraseña", "assets/icons/JUNGHANNS_WPA_V1_ele-05.png"),
          textOC(),
          buttonLog()
        ],
      ),
    );
  }

  Widget textField(
      TextEditingController controller, String hintText, String iconS) {
    return SizedBox(
        height: sh * 0.06,
        child: TextFormField(
            controller: controller,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyles.blue18SemiBoldIt,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyles.blue18SemiBoldIt,
              filled: true,
              fillColor: ColorStyles.whiteJ,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              prefixIcon: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: Image.asset(
                    iconS,
                  )),
            )));
  }

  Widget textOC() {
    return Container(
      alignment: Alignment.centerRight,
      child: Text(
        "¿Olvidaste tu contraseña?",
        style: TextStyles.blue13It,
      ),
    );
  }

  Widget buttonLog() {
    return GestureDetector(
        child: Container(
          width: double.infinity,
          height: 40,
          alignment: Alignment.center,
          color: ColorStyles.greenJ,
          child: Text(
            "Iniciar sesión",
            style: TextStyles.white16SemiBoldIt,
          ),
        ),
        onTap: () {
          print("Inicar sesión");
        });
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
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: AutoSizeText(
        "Todos los derechos reservados 2022. MAFIN SA. de CV.",
        maxLines: 1,
        style: TextStyles.blue15SemiBold,
      ),
    );
  }
}
