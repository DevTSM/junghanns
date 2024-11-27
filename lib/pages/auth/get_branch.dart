import 'dart:async';
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

class _GetBranchState extends State<GetBranch>{
  late Size size;
  late TextEditingController token,pinC;
  late bool isLoading,isValitedOtp;
  late LocationData currentLocation;

  @override
  void initState() {
    super.initState();
    pinC = TextEditingController();
    token = TextEditingController(text: prefs.branchOTP);
    currentLocation = LocationData.fromMap({});
    isLoading = false;
    isValitedOtp = false;
    if(prefs.branchOTP != ""){
      setCurrentLocation();
    }
  }
  @override
  void dispose() {
    super.dispose();
  }
  setCurrentLocation() async {
    try{
    Location locationInstance = Location();
    PermissionStatus permission = await locationInstance.hasPermission();
    if (permission == PermissionStatus.granted) {
      locationInstance.changeSettings(accuracy: LocationAccuracy.high);
      if(await locationInstance.serviceEnabled()){
      currentLocation = await locationInstance.getLocation().timeout(const Duration(seconds: 15));
      }else{
        Fluttertoast.showToast(
              msg: "Activa el servicio de Ubicacion e intentalo de nuevo.",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
              backgroundColor:ColorsJunghanns.red);
      }
    } else {
      Timer(const Duration(seconds: 2), () async { 
        await Provider.of<ProviderJunghanns>(context,listen: false)
          .requestAllPermissions(); 
      });
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
              prefs.branchOTP = token.text;
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
        prefs.branchOTP = "";
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
    return Consumer<ProviderJunghanns>(
      builder: (BuildContext context, ProviderJunghanns controller,_){
        return _body(provider:controller);
      } 
    );
  }
  Widget _body({required ProviderJunghanns provider}){
    return Scaffold (
      body: Stack (
        children: [
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/junghannsWater.png",
                ),
                fit: BoxFit.cover
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: kBottomNavigationBarHeight + 50
              ),
              child: Column(
                children: [
                  Visibility(
                    visible: provider.connectionStatus == 4,
                    child: const WithoutInternet()
                  ),
                  Image.asset(
                    "assets/images/junghannsLogo.png",
                  ),
                  const SizedBox(height: 25),
                  isValitedOtp ? otpField() : cardLogin(provider: provider)
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
              child: _notPermission(msj:provider.labelPermission)
            )
          ),
        ]
      )
    );
  }

  Widget cardLogin({required ProviderJunghanns provider}) {
    return Container(
      width: size.width * 0.85,
      //height: size.width * 0.75,
      padding: EdgeInsets.all(size.height * 0.03),
      decoration: Decorations.whiteCard,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          textField(
            token, 
            "Código", 
            Image.asset("assets/icons/user.png"), 
            false,
            max: 8
          ),
          const SizedBox(height: 15),
          ButtonJunghanns(
            decoration: JunnyDecoration.orange255(8).copyWith(
              color: JunnyColor.green24
            ),
            fun: () async {fungetToken();},
            label: "Activar",
            style: TextStyles.white16SemiBoldIt,
            decorationInactive: JunnyDecoration.orange255(8).copyWith(
              color: ColorsJunghanns.lighGrey
            ),
            isActive: provider.permission && token.text.isNotEmpty,
          ),
          
        ],
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

  // Widget button() {
  //   return GestureDetector(
  //       child: Container(
  //         width: double.infinity,
  //         height: 40,
  //         alignment: Alignment.center,
  //         color: ColorsJunghanns.greenJ,
  //         child: Text(
  //           "Activar",
  //           style: TextStyles.white16SemiBoldIt,
  //         ),
  //       ),
  //       onTap: () => fungetToken());
  // }
  
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
                            fun: () async{
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
