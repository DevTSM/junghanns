import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/modal/logout.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/routes.dart';
import 'package:provider/provider.dart';
import '../../preferences/global_variables.dart';

class Routes extends StatefulWidget {
  const Routes({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  late ProviderJunghanns provider;
  late List<CustomerModel> customerList;
  late Size size;
  late bool isLoading;
  @override
  void initState() {
    super.initState();
    isLoading = false;
    customerList = [];
    getDataCustomerList();
    
  }
  getPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
          provider.permission=true;
        }else{
          provider.permission=false;
        }
  }
  getDataCustomerList() async {
    Timer(const Duration(milliseconds: 1000), () async {
    if(provider.connectionStatus<4){
    customerList.clear();
    setState(() {
          isLoading = true;
        });
    await getListCustomer(prefs.idRouteD, DateTime.now(), "R").then((answer) {
      setState(() {
          isLoading = false;
        });
      if(prefs.token!=""){
      if (answer.error) {
        Fluttertoast.showToast(
          msg: "Sin clientes en ruta",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
        
      } else {
        setState(() {
          answer.body.map((e) {
            customerList.add(CustomerModel.fromList(e, prefs.idRouteD,2));
          }).toList();
        });
        getPermission();
      }
      }else{
          Fluttertoast.showToast(
          msg: "Las credenciales caducaron.",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
          Timer(const Duration(milliseconds: 2000), () async {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          });
        }
    });
    }
  });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    provider = Provider.of<ProviderJunghanns>(context);
    
    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      appBar: AppBar(
        backgroundColor: ColorsJunghanns.whiteJ,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: ColorsJunghanns.whiteJ,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.dark),
        leading: GestureDetector(
          child: Container(
              padding: const EdgeInsets.only(left: 24),
              child: Image.asset("assets/icons/menu.png")),
          onTap: () {},
        ),
        elevation: 0,
      ),
      body: SizedBox(
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
                visible: provider.connectionStatus == 4,
                child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: ColorsJunghanns.red,
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: const Text(
                      "Sin conexion a internet",
                      style: TextStyles.white14_5,
                    ))),
                    Visibility(
                visible: !provider.permission,
                child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: ColorsJunghanns.red,
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: const Text(
                      "No has proporcionado permisos de ubicación",
                      style: TextStyles.white14_5,
                    ))),
            header(),
            const SizedBox(
              height: 15,
            ),
            provider.connectionStatus < 4
                ? isLoading
                    ? const Center(
                        child: LoadingJunghanns(),
                      )
                    : customerList.isNotEmpty
                        ? Expanded(
                            child: SingleChildScrollView(
                                child: Column(
                            children: customerList.map((e) {
                              return Column(children: [
                                RoutesCard(
                                    icon: Container(
                                      decoration: BoxDecoration(
                                        color: Color(int.parse(
                                            e.color
                                                .toUpperCase()
                                                .replaceAll("#", "FF"),
                                            radix: 16)),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(30),
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      height: size.width * .14,
                                      width: size.width * .14,
                                      child: Image.asset(
                                          "assets/icons/userIcon.png"),
                                    ),
                                    customerCurrent: e),
                                Row(children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: (size.width * .07) + 15),
                                    color: ColorsJunghanns.grey,
                                    width: .5,
                                    height: 15,
                                  )
                                ])
                              ]);
                            }).toList(),
                          )))
                        : Expanded(
                            child: Center(
                                child: Text(
                            "Sin clientes",
                            style: TextStyles.blue18SemiBoldIt,
                          )))
                : Expanded(
                    child: FutureBuilder(
                        future: handler.retrieveUsersType(2),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<CustomerModel>> snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                                itemCount: snapshot.data?.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(children: [
                                    RoutesCard(
                                        icon: Container(
                                          decoration: BoxDecoration(
                                            color: Color(int.parse(
                                                snapshot.data?[index].color ??
                                                    ""
                                                        .toUpperCase()
                                                        .replaceAll("#", "FF"),
                                                radix: 16)),
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(30),
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          height: size.width * .14,
                                          width: size.width * .14,
                                          child: Image.asset(
                                              "assets/icons/userIcon.png"),
                                        ),
                                        customerCurrent: snapshot.data![index]),
                                    Row(children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: (size.width * .07) + 15),
                                        color: ColorsJunghanns.grey,
                                        width: .5,
                                        height: 15,
                                      )
                                    ])
                                  ]);
                                });
                          } else {
                            return Container();
                          }
                        }))
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          color: ColorsJunghanns.lightBlue,
          padding: EdgeInsets.only(
              right: 15, left: 10, top: 10, bottom: size.height * .06),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.only(left: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Ruta de trabajo",
                            style: TextStyles.blue27_7,
                          ),
                          Text(
                            "  Clientes programados para visita",
                            style: TextStyles.green15_4,
                          ),
                        ],
                      ))),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                child: Image.asset(
                  "assets/icons/workRoute.png",
                  width: size.width * .13,
                ),
                onTap: () {
                  showConfirmLogOut(context,size);
                },
              )
            ],
          )),
      Container(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: Row(
            children: [
              Expanded(
                  flex: 4,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          checkDate(DateTime.now()),
                          style: TextStyles.blue19_7,
                        ),
                        Text(
                          "${customerList.length} clientes para visitar",
                          style: TextStyles.grey14_4,
                        )
                      ],
                    ),
                  )),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                      alignment: Alignment.center,
                      decoration: Decorations.orangeBorder5,
                      padding: const EdgeInsets.only(
                          left: 5, right: 5, top: 5, bottom: 5),
                      child: RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: prefs.nameRouteD, style: TextStyles.white17_5),
                      ])))),
            ],
          )),
    ]);
  }
}
