import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/components/textfield/text_field.text.dart';
import 'package:junghanns/components/without_internet.dart';
import 'package:junghanns/pages/auth/login.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/auth.dart';
import 'package:location/location.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:provider/provider.dart';

import '../../components/loading.dart';
import '../../styles/color.dart';
import '../../styles/decoration.dart';
import '../../styles/text.dart';

class GetBranch extends StatefulWidget {
  const GetBranch({Key? key}) : super(key: key);

  @override
  State<GetBranch> createState() => _GetBranchState();
}

class _GetBranchState extends State<GetBranch> {
  late Size size;
  late TextEditingController token,pinC;
  late bool isLoading,isValitedOtp;
  late LocationData currentLocation;
  //
  late ProviderJunghanns provider;

  @override
  void initState() {
    super.initState();
    pinC = TextEditingController();
    token = TextEditingController();
    currentLocation = LocationData.fromMap({});
    isLoading = false;
    isValitedOtp = false;
  }
  
  setCurrentLocation() async {
    try{
    Location locationInstance=Location();
    PermissionStatus permission = await locationInstance.hasPermission();
    if (permission == PermissionStatus.granted) {
      provider.permission = true;
      locationInstance.changeSettings(accuracy: LocationAccuracy.high);
      if(await locationInstance.serviceEnabled()){
        provider.permission = true;
      currentLocation = await locationInstance.getLocation().timeout(const Duration(seconds: 15));
      }else{
        provider.permission = false;
        Fluttertoast.showToast(
              msg: "Activa el servicio de Ubicacion e intentalo de nuevo.",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
              backgroundColor:ColorsJunghanns.red);
      }
    } else {
      provider.permission = false;
      await locationInstance.requestPermission().then((value) => setCurrentLocation());
      
    }
    } catch (e) {
          log("***ERROR -- $e");
          Fluttertoast.showToast(
              msg: "Tiempo de espera superado, vuelve a intentarlo",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
              backgroundColor:ColorsJunghanns.red);
          return false;
        }
  }
  
  fungetToken() async {
    setState(() {
      isLoading=true;
    });
        await setCurrentLocation().then((value) async {
          await tokenKernelActive(token.text, currentLocation.latitude!, currentLocation.longitude!).then((answer){
          setState(() {
            isLoading=false;
          });
          if(answer.error){
            Fluttertoast.showToast(
          msg: answer.message 
          == "No es posible realizar una activación fuera del CEDIS."
            ? "Solo se pueden realizar activaciones dentro del CEDIS" 
            : "Acceso denegado. El token ingresado es incorrecto.",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
          }else{
            setState(() {
              isValitedOtp = true;
            });
          }
        });
        });
        
  }

  funValidateOtp() async {
    setState(() {
      isLoading=true;
    });
    await validateOTP(token.text,pinC.text,currentLocation.latitude!, currentLocation.longitude!).then((answer){
      setState(() {
      isLoading=false;
    });
      if(answer.error){
        Fluttertoast.showToast(
          msg: "Acceso denegado. El token ingresado es incorrecto.",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      }else{
        prefs.urlBase=answer.body["endpoint"];
        prefs.labelCedis=answer.body["claveCedis"];
        Navigator.pushReplacement<void, void>(
                context,
                MaterialPageRoute<void>(
                    builder: (BuildContext context) => const Login()),
              );
      }
    });
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
              Visibility(
                  visible: provider.connectionStatus == 4,
                  child: const WithoutInternet()),
              Container(
                  margin: EdgeInsets.only(
                      top: size.height * .13, left: 30, right: 30),
                  child: Image.asset(
                    "assets/images/junghannsLogo.png",
                  )),
              const SizedBox(
                height: 25,
              ),
              isValitedOtp?otpField():cardLogin()
            ],
          ),
        ),
      ),
      textVersion(),
      Visibility(visible: isLoading, child: const LoadingJunghanns())
    ]));
  }

  Widget cardLogin() {
    return Container(
      width: size.width * 0.85,
      //height: size.width * 0.75,
      padding: EdgeInsets.all(size.height * 0.03),
      decoration: Decorations.whiteCard,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          textField(token, "Código", Image.asset(
                    "assets/icons/user.png"), false,max: 8),
                    const SizedBox(height: 15,),
          button(),
        ],
      ),
    );
  }

  Widget button() {
    return GestureDetector(
        child: Container(
          width: double.infinity,
          height: 40,
          alignment: Alignment.center,
          color: ColorsJunghanns.greenJ,
          child: Text(
            "Activar",
            style: TextStyles.white16SemiBoldIt,
          ),
        ),
        onTap: () => fungetToken());
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

  Widget otpField() {
    return Center(
            child: Container(
          padding: const EdgeInsets.all(12),
          width: size.width * .8,
          height: size.height * .36,
          decoration: Decorations.whiteS1Card,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child:IconButton(onPressed: ()=> setState((){ isValitedOtp=false;
                pinC.clear();}), icon: Icon(Icons.arrow_back_ios,color: ColorsJunghanns.green,))),
              //Info Phone
              Container(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        "Ingresa el código de verificación",
                        style: TextStyles.blueJ215R,
                        textAlign: TextAlign.center,
                      )),
              //OTP Field
              PinCodeTextField(
                maxLength: 6,
                pinBoxRadius: 10,
                controller: pinC,
                pinBoxBorderWidth: 3,
                pinBoxWidth: size.width * 0.1,
                pinBoxHeight: size.width * 0.1,
                defaultBorderColor: ColorsJunghanns.blueJ3,
                hasTextBorderColor: ColorsJunghanns.blueJ,
                onDone: (value) {
                  log("Fun OTP");
                  funValidateOtp();

                },
              ),
              //Buttons Resend and Cancel
              Container(
                        margin: const EdgeInsets.only(left: 15,right: 15),
                        width: size.width,
                        height: 45,
                        child: ButtonJunghanns(
                            fun: () {
                              log("RESEND CODE");
                              fungetToken();
                            },
                            decoration: Decorations.blueJ2Card,
                            style: TextStyles.white15R,
                            label: "Reenviar código"),
                      ),
            ],
          ),
        ));
  }
}
