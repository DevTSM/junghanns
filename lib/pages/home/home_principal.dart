import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/components/app_bar.dart';
import 'package:junghanns/components/bottom_bar.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/components/drawer/drawer.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/pages/home/call.dart';
import 'package:junghanns/pages/home/home.dart';
import 'package:junghanns/pages/home/new_customer.dart';
import 'package:junghanns/pages/home/routes.dart';
import 'package:junghanns/pages/home/second.dart';
import 'package:junghanns/pages/home/specials.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

const List<Widget> pages = [
  Home(),
  Specials(),
  Routes(),
  Seconds(),
  
  NewCustomer(),
  Call(),
];

class HomePrincipal extends StatefulWidget {
  int index;
  HomePrincipal({Key? key, this.index = 0}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePrincipalState();
}

class _HomePrincipalState extends State<HomePrincipal> {
  late Size size;
  late ProviderJunghanns provider;
  late LocationData currentLocation;
  late int indexCurrent;
  late bool isloading;
  @override
  void initState() {
    super.initState();
    indexCurrent = widget.index;
    currentLocation = LocationData.fromMap({});
    isloading=false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setIndexCurrent(int current) {
    setState(() {
      indexCurrent = current;
    });
  }

  setCurrentLocation() async {
    try {
      Location locationInstance = Location();
      PermissionStatus permission = await locationInstance.hasPermission();
      if (permission == PermissionStatus.granted) {
        provider.permission = true;
        locationInstance.changeSettings(accuracy: LocationAccuracy.high);
        if (await locationInstance.serviceEnabled()) {
          provider.permission = true;
          currentLocation = await locationInstance
              .getLocation()
              .timeout(const Duration(seconds: 15));
        } else {
          provider.permission = false;
          Fluttertoast.showToast(
              msg: "Activa el servicio de Ubicacion e intentalo de nuevo.",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
              backgroundColor: ColorsJunghanns.red);
        }
      } else {
        print({"permission": permission.toString()});
        provider.permission = false;
      }
    } catch (e) {
      log("***ERROR -- $e");
      Fluttertoast.showToast(
          msg: "Tiempo de espera superado, vuelve a intentarlo",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
          backgroundColor: ColorsJunghanns.red);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      size = MediaQuery.of(context).size;
      provider = Provider.of<ProviderJunghanns>(context);
    });
    return prefs.statusRoute == "INCM"
        ? comidaWidget()
        : Scaffold(
            //key: GlobalKey<ScaffoldState>(),
            appBar: appBarJunghanns(context, size, provider),
            drawer: drawer(provider, context,setIndexCurrent),
            body: !provider.asyncProcess
                ? provider.isStatusloading
                    ? const Center(child: LoadingJunghanns())
                    : pages[indexCurrent]
                : asyncProcess(),
            bottomNavigationBar: bottomBar(setIndexCurrent, indexCurrent),
          );
  }

  Widget asyncProcess() {
    return Stack(
      children: [
        Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [
              Color.fromARGB(255, 244, 252, 253),
              Color.fromARGB(255, 206, 240, 255)
            ],
                    stops: [
              0.2,
              0.8
            ],
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter))),
        Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset("assets/images/junghannsLogo.png"),
            const SizedBox(
              height: 10,
            ),
            Text(provider.labelAsync),
            const SizedBox(
              height: 10,
            ),
            Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: LinearProgressBar(
                  minHeight: 7,
                  maxSteps: provider.totalAsync,
                  progressType: LinearProgressBar
                      .progressTypeLinear, // Use Linear progress
                  currentStep: provider.currentAsync,
                  progressColor: ColorsJunghanns.green,
                  backgroundColor: ColorsJunghanns.grey,
                ))
          ]),
        ),
      ],
    );
  }

  Widget comidaWidget() {
    return Scaffold(
        body: Container(
          padding: const EdgeInsets.only(left: 30,right: 30),
      decoration: const BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/images/junghannsWater.png"))),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset("assets/images/junghannsLogo.png"),
          const SizedBox(
            height: 40,
          ),
          isloading?const SpinKitCircle(
            color: ColorsJunghanns.blue,
          ): ButtonJunghanns(
              fun: () async {
                setState(() {
                          isloading=true;
                        });
                await setCurrentLocation();
                if (provider.connectionStatus < 4) {
                  await setInitRoute(
                          currentLocation.latitude!, currentLocation.longitude!,
                          status: "fin_comida")
                      .then((answer) {
                        setState(() {
                          isloading=false;
                        });
                    if (answer.error) {
                      Fluttertoast.showToast(
                        msg:
                            "No fue posible continuar la ruta, revisa tu conexion a internet",
                        timeInSecForIosWeb: 2,
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.TOP,
                        webShowClose: true,
                      );
                    } else {
                      setState(() {
                        prefs.statusRoute = "FNCM";
                      });
                    }
                  });
                } else {
                  setState(() {
                    prefs.statusRoute = "FNCM";
                  });
                }
              },
              decoration: Decorations.greenBorder5,
              style: TextStyles.white17_6,
              label: "Continuar ruta")
        ]),
      ),
    ));
  }
}
