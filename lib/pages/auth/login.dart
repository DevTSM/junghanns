import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:junghanns/pages/home/home_principal.dart';
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
        body: SingleChildScrollView(
            child: Stack(
      children: [background(), menu(), textBottom()],
    )));
  }

  Widget background() {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Image.asset(
        "assets/images/junghannsWater.png",
        fit: BoxFit.cover,
      ),
    );
  }

  Widget menu() {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Column(
        children: [
          SizedBox(
            height: size.height * 0.15,
          ),
          logoJ(),
          SizedBox(
            height: size.height * 0.06,
          ),
          cardLogin(),
        ],
      ),
    );
  }

  Widget logoJ() {
    return Image.asset(
      "assets/images/junghannsLogo.png",
      width: size.width * 0.64,
    );
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
          textField(userC, "Usuario", "assets/icons/user.png"),
          textField(passC, "Contraseña", "assets/icons/password.png"),
          textOC(),
          buttonLog()
        ],
      ),
    );
  }

  Widget textField(
      TextEditingController controller, String hintText, String iconS) {
    return SizedBox(
        height: size.height * 0.06,
        child: TextFormField(
            controller: controller,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyles.blue18SemiBoldIt,
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
          color: ColorsJunghanns.greenJ,
          child: Text(
            "Iniciar sesión",
            style: TextStyles.white16SemiBoldIt,
          ),
        ),
        onTap: () {
          print("Inicar sesión");
          Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                  builder: (BuildContext context) => const HomePrincipal()));
        });
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
}
