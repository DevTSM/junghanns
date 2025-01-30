import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junghanns/components/app_bar.dart';
import 'package:junghanns/components/bottom_bar.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/components/drawer/drawer.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/models/stop_ruta.dart';
import 'package:junghanns/pages/home/call.dart';
import 'package:junghanns/pages/home/home.dart';
import 'package:junghanns/pages/home/new_customer.dart';
import 'package:junghanns/pages/home/notifications.dart';
import 'package:junghanns/pages/home/routes.dart';
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

import '../../widgets/modal/receipt_modal.dart';
import '../../widgets/modal/transfers_modal.dart';
import '../../widgets/modal/validation_modal.dart';

const List<Widget> pages = [
  Home(),
  Specials(),
  Routes(),
  Notificactions(),
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
  late bool isloading,isFinRuta;
  List specialData = [];
  @override
  void initState() {
    super.initState();
    indexCurrent = widget.index;
    isFinRuta=false;
    currentLocation = LocationData.fromMap({});
    isloading=false;
    getFinRuta();
    _refreshTimer();
  }

  @override
  void dispose() {
    super.dispose();
  }
  Future<void> _refreshTimer() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);

    // Ahora fetchStockValidation devuelve un objeto ValidationModel
    await _refreshTransfers();
    await provider.fetchStockValidation();

    // Filtrar los datos según las condiciones especificadas
    final filteredData = provider.validationList.where((validation) {
      return validation.status == "P" && validation.valid == "Planta";
    }).toList();


    // Verificar si hay datos filtrados
    setState(() {
      if (filteredData.isNotEmpty) {
        specialData = filteredData;  // Asigna los datos filtrados a specialData
        // Imprimir el contenido de specialData para confirmarlo
        print('Contenido de specialData (filtrado): $specialData');
        print('Llama al modal');
        showValidationModal(context);
      } else {
        specialData = [];  // Si no hay datos que cumplan las condiciones, asignar un arreglo vacío
        print('No se encontraron datos que cumplan las condiciones----Home principal');
      }
    });

    if (provider.validationList.first.status =='P' && provider.validationList.first.valid == 'Ruta'){
      showReceiptModal(context);
    }
  }

  Future<void> _refreshTransfers() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);

    // Ahora fetchStockValidation devuelve un objeto ValidationModel
    await provider.fetchValidation();

    // Filtrar los datos según las condiciones especificadas
    final filteredDataTranfers = provider.validationList.where((validation) {
      return validation.status == "P" && validation.valid == "Ruta" && validation.typeValidation == 'T' && validation.idRoute != prefs.idRouteD;
    }).toList();

    // Verificar si hay datos filtrados
    setState(() {
      if (filteredDataTranfers.isNotEmpty) {
        specialData = filteredDataTranfers;  // Asigna los datos filtrados a specialData
        // Imprimir el contenido de specialData para confirmarlo
        print('Contenido de specialData (filtrado): $specialData');
        print('Llama al modal');
        showTransferModal(context);
      } else {
        specialData = [];  // Si no hay datos que cumplan las condiciones, asignar un arreglo vacío
      }
    });
  }

  void setIndexCurrent(int current) {
     Provider.of<ProviderJunghanns>(context,listen: false).getPendingNotification();
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

  getFinRuta() async {
  List<Map<String, dynamic>> dataList =
      await handler.retrieveUsersType2(1, 2, 3, 4, 5, 6);
      setState(() {
  if (dataList.isEmpty) {
    isFinRuta=true;
  } else {
    isFinRuta=false;
  }
  });
}
  @override
  Widget build(BuildContext context) {
    setState(() {
      size = MediaQuery.of(context).size;
      provider = Provider.of<ProviderJunghanns>(context);
    });
    return _body();
  }
  Widget _body(){
    return prefs.statusRoute == "INCM"
      ? comidaWidget()
      : Scaffold(
          //key: GlobalKey<ScaffoldState>(),
          appBar: appBarJunghanns(context, size, provider),
          drawer: drawer(provider, context,setIndexCurrent,/*isFinRuta*/true),//se comenta el valor de confirmacion de ruta debido a una adecuacion pendiente
          body: !provider.asyncProcess
            ? provider.isStatusloading
              ? const Center(child: LoadingJunghanns())
              : pages[indexCurrent]
            : asyncProcess(),
          bottomNavigationBar: bottomBar(setIndexCurrent, indexCurrent,context),
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
                StopRuta stop = StopRuta(
            id: 1,
            update: 0,
            lat: currentLocation.latitude!,
            lng: currentLocation.longitude!,
            status:"FNCM");
        int id = await handler.insertStopRuta(stop);
                  await setInitRoute(
                          currentLocation.latitude!, currentLocation.longitude!,
                          status: "fin_comida")
                      .then((answer) {
                        setState(() {
                          isloading=false;
                        });
                        if (!answer.error) {
            handler.updateStopRuta(1, id);
          }
                  });
                  setState(() {
                        prefs.statusRoute = "FNCM";
                      });
              },
              decoration: Decorations.greenBorder5,
              style: TextStyles.white17_6,
              label: "Continuar ruta")
        ]),
      ),
    ));
  }
}
