import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/without_internet.dart';
import 'package:junghanns/components/without_location.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/services/store.dart';
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
  //
  late TextEditingController buscadorC;
  late List<CustomerModel> searchList;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    customerList = [];
    buscadorC = TextEditingController();
    searchList = [];
    getCustomerListDB();
  }

  getCustomerListDB() async {
    customerList.clear();
    searchList.clear();
    List<CustomerModel> dataList = await handler.retrieveUsers();
    setState(() {
      dataList.map((e) {
        if (e.type == 1 || e.type == 2 || e.type == 3 || e.type == 4) {
          customerList.add(e);
        }
      }).toList();
      customerList.sort((a, b) => a.orden.compareTo(b.orden));
      searchList = customerList;
      getListUpdate(dataList, dataList.isEmpty ? 0 : dataList.last.id);
    });
  }

  getListUpdate(List<CustomerModel> users, int id) {
    log("Ultimo cliente $id");
    Timer(const Duration(milliseconds: 800), () async {
      await getCustomers().then((answer) {
        if (prefs.token == "") {
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
        } else {
          if (!answer.error) {
            List<CustomerModel> list = [];
            List<CustomerModel> listDelete=[];
            for (var item in answer.body) {
              CustomerModel customer = CustomerModel.fromPayload(item);
              listDelete.add(customer);
              var exits = users
                  .where((element) => element.idClient == customer.idClient);
              if (exits.isEmpty) {
                list.add(customer);
                if (customer.type == 1 ||
                    customer.type == 2 ||
                    customer.type == 3 ||
                    customer.type == 4) {
                  customerList.add(customer);
                }
              }
            }
            users.map((e){
              if(listDelete.where((element) => element.idClient==e.idClient).isEmpty){
                e.setType(7);
                handler.updateUser(e);
              }
            }).toList();
            if (list.isNotEmpty) {
              handler.insertUser(list);
              customerList.sort((a, b) => a.orden.compareTo(b.orden));
              searchList = customerList;
            }

          }
        }
      });
      getPermission();
      setState(() {
        isLoading = false;
      });
    });
  }

  getPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      provider.permission = true;
    } else {
      provider.permission = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    provider = Provider.of<ProviderJunghanns>(context);
    return Stack(children: [
      RefreshIndicator(
          onRefresh: () async {
            getCustomerListDB();
          },
          child: SizedBox(
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                    visible: provider.connectionStatus == 4,
                    child: const WithoutInternet()),
                Visibility(
                    visible: !provider.permission,
                    child: const WithoutLocation()),
                header(),
                const SizedBox(
                  height: 15,
                ),
                buscador(),
                customerList.isNotEmpty
                    ? Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                        children: searchList.map((e) {
                          return Column(children: [
                            RoutesCard(
                                updateList: getCustomerListDB,
                                indexHome: 2,
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
                                  child:
                                      Image.asset("assets/icons/userIcon.png"),
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
                        "Sin clientes en ruta",
                        style: TextStyles.blue18SemiBoldIt,
                      )))
              ],
            ),
          )),
      Visibility(visible: isLoading, child: const LoadingJunghanns())
    ]);
  }

  Widget header() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          color: ColorsJunghanns.lightBlue,
          padding: EdgeInsets.only(
              right: 15, left: 15, top: 10, bottom: size.height * .06),
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
                        style: TextStyles.blue19_7,
                      ),
                      Text(
                        "${customerList.length} clientes para visitar",
                        style: TextStyles.grey14_4,
                      )
                    ],
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
                            text: prefs.nameRouteD,
                            style: TextStyles.white17_5),
                      ])))),
            ],
          )),
    ]);
  }

  Widget buscador() {
    return Container(
        height: size.height * 0.06,
        margin: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
        child: TextFormField(
            controller: buscadorC,
            onChanged: (value) => funSearch(value),
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
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              suffixIcon: const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
                  child: Icon(
                    Icons.search,
                    color: ColorsJunghanns.blue,
                  )),
            )));
  }

  funSearch(String value) {
    if (buscadorC.text != "") {
      searchList = [];
      setState(() {
        for (var element in customerList) {
          if (element.name
              .toLowerCase()
              .startsWith(buscadorC.text.toLowerCase())) {
            searchList.add(element);
          } else {
            if (element.address
                .toLowerCase()
                .startsWith(buscadorC.text.toLowerCase())) {
              searchList.add(element);
            } else {
              if (element.idClient
                  .toString()
                  .toLowerCase()
                  .startsWith(buscadorC.text.toLowerCase())) {
                searchList.add(element);
              }
            }
          }
        }
      });
    } else {
      setState(() {
        searchList = customerList;
      });
    }
  }
}
