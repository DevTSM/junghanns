import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:junghanns/components/empty/empty.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/database/async.dart';
import 'package:junghanns/models/authorization.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/util/location.dart';
import 'package:junghanns/widgets/card/autorizacion.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:provider/provider.dart';

class Autorizaciones extends StatefulWidget {
  const Autorizaciones({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AutorizacionesState();
}

class _AutorizacionesState extends State<Autorizaciones> {
  late List<AuthorizationModel> authList;
  late TextEditingController searchTo;
  late ProviderJunghanns provider;
  late String valueSearch;
  late Size size;
  late bool isLoading;
  late bool isLoadingOne;

  @override
  void initState() {
    super.initState();
    authList = [];
    searchTo = TextEditingController();
    valueSearch = "";
    isLoading = false;
    isLoadingOne = false;
    getAuth();
  }

  getAuth() async {
    authList.clear();
    await handler.retrieveUsers().then((value) {
      value.map((e) {
        e.auth.map((e1) => e1.setClient = e).toList();
        setState(() {
          List<AuthorizationModel> temporally=[];
          e.auth.map((element){
            var exits = authList.where((element1) =>element.idAuth==element1.idAuth);
            if(exits.isEmpty){
              temporally.add(element);
            }
          }).toList();
          authList.addAll(temporally);
        });
      }).toList();
    });
  }

  getValidation(AuthorizationModel current, String code) async {
    Navigator.pop(context);
    setState(() {
      isLoadingOne = true;
    });
    await getCancelAuth({
      "id_auth": current.idAuth,
      "code": code,
      "id_ruta": prefs.idRouteD
    }).then((answer) async {
      setState(() {
        isLoadingOne = false;
      });
      if (answer.error) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: answer.message,
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: true,
          btnOkText: "Aceptar",
          btnOkOnPress: () => setState(() => isLoadingOne = false),
        ).show();
      } else {
        setState(() {
          isLoadingOne = true;
        });
        current.client.delete(current.idAuth);
        await handler.updateUser(current.client).then((value) {
          setState(() {
            isLoadingOne = false;
          });
          authList = [];
          getAuth();
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.rightSlide,
            title: 'Operacion exitosa',
            dismissOnTouchOutside: false,
            btnOkText: "Aceptar",
            btnOkOnPress: () => setState(() => isLoadingOne = false),
          ).show();
        });
      }
    });
  }

  getFilter(AuthorizationModel current) {
    if (current.authText.toLowerCase().contains(valueSearch)) {
      return true;
    }
    if (current.authText.toLowerCase().contains(valueSearch)) {
      return true;
    }
    if (current.product.description.toLowerCase().contains(valueSearch)) {
      return true;
    }
    if (current.client.address.toLowerCase().contains(valueSearch)) {
      return true;
    }
    if (current.client.idClient
        .toString()
        .toLowerCase()
        .contains(valueSearch)) {
      return true;
    }
    if (current.client.name.toLowerCase().contains(valueSearch)) {
      return true;
    }
    if (valueSearch == "") {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    provider = Provider.of<ProviderJunghanns>(context);
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
            backgroundColor: ColorsJunghanns.whiteJ,
            systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: ColorsJunghanns.whiteJ,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.dark),
            elevation: 0,
            leading: isLoading
                ? null
                : IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: ColorsJunghanns.blue,
                    ))),
        body: RefreshIndicator(
            onRefresh: () async {
              Position? currentLocation =
                  await LocationJunny().getCurrentLocation();
              setState(() {
                isLoading = true;
              });
              provider.asyncProcess = true;
              provider.isNeedAsync = false;
              prefs.lastBitacoraUpdate = DateTime.now().toString();
              Async async = Async(provider: provider);
              await async.initAsync().then((value) async {
                await handler.inserBitacora({
                  "lat":
                      (currentLocation != null ? currentLocation.latitude : 0),
                  "lng":
                      currentLocation != null ? currentLocation.longitude : 0,
                  "date": DateTime.now().toString(),
                  "status": value ? "1" : "0",
                  "desc": jsonEncode(
                      {"text": "Sincronizacion desde autorizaciones"})
                });
                setState(() {
                  isLoading = false;
                });
                getAuth();
              });
            },
            child: isLoading
                ? asyncProcess()
                : SingleChildScrollView(
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height + 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            header(),
                            buscador(),
                            const SizedBox(
                              height: 15,
                            ),
                            authList.isEmpty?empty(context):Expanded(
                                child: SingleChildScrollView(
                                    child: Column(
                              children: authList
                                  .map((e) => getFilter(e)
                                      ? AuthCard(
                                          update: getValidation, current: e)
                                      : Container())
                                  .toList(),
                            )))
                          ],
                        )),
                  )),
      ),
      Visibility(
          visible: isLoadingOne,
          child: const Center(
            child: LoadingJunghanns(),
          ))
    ]);
  }

  Widget buscador() {
    return Container(
        height: size.height * 0.06,
        margin: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
        child: TextFormField(
            controller: searchTo,
            onChanged: (value) => setState(() {
                  valueSearch = value.toLowerCase();
                }),
            textAlignVertical: TextAlignVertical.center,
            style: TextStyles.blueJ15SemiBold,
            decoration: InputDecoration(
              hintText: "Buscar ...",
              hintStyle: TextStyles.grey15Itw,
              filled: true,
              fillColor: ColorsJunghanns.whiteJ,
              contentPadding: const EdgeInsets.only(left: 24),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(width: 1, color: ColorsJunghanns.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
                  child: Icon(
                    Icons.search,
                    color: ColorsJunghanns.blue,
                  )),
            )));
  }

  Widget header() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          color: ColorsJunghanns.lightBlue,
          padding: EdgeInsets.only(
              right: 15, left: 15, top: 10, bottom: size.height * .06),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ruta de trabajo",
                style: TextStyles.blue27_7,
              ),
              Text(
                "  Autorizaciones",
                style: TextStyles.green15_4,
              ),
            ],
          )),
      Container(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checkDate(DateTime.now()),
                      style: JunnyText.bluea4(FontWeight.w700, 17),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                      alignment: Alignment.center,
                      decoration: JunnyDecoration.orange255(8),
                      padding: const EdgeInsets.only(
                          left: 5, right: 5, top: 5, bottom: 5),
                      child: RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: prefs.nameRouteD,
                            style: TextStyles.white17_5),
                      ])))),
            ],
          )),
    ]);
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
}
