import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/components/empty/empty.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/need_async.dart';
import 'package:junghanns/components/without_internet.dart';
import 'package:junghanns/components/without_location.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/routes.dart';
import 'package:provider/provider.dart';

import '../../preferences/global_variables.dart';
import '../../widgets/modal/receipt_modal.dart';
import '../../widgets/modal/validation_modal.dart';

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
  List specialData = [];

  @override
  void initState() {
    super.initState();
    isLoading = true;
    customerList = [];
    buscadorC = TextEditingController();
    searchList = [];
    getCustomerListDB();
    _refreshTimer();
  }

  Future<void> _refreshTimer() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);

    // Ahora fetchStockValidation devuelve un objeto ValidationModel
    provider.fetchStockValidation();

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
        print('No se encontraron datos que cumplan las condiciones');
      }
    });

    if (provider.validationList.first.status =='P' && provider.validationList.first.valid == 'Ruta'){
      showReceiptModal(context);
    }
  }
  
  funSearch(CustomerModel value) {
    if (buscadorC.text != "") {
      if(value.name.toLowerCase().contains(buscadorC.text.toLowerCase()) ){
        return true;
      }
      if(value.address.toLowerCase().contains(buscadorC.text.toLowerCase()) ){
        return true;
      }
      if(value.idClient.toString().toLowerCase().contains(buscadorC.text.toLowerCase()) ){
        return true;
      }
    } else {
      return true;
    }
    return false;
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
      await getCustomers().then((answer) async {
        prefs.lastRouteUpdate = DateTime.now().toString();
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
            //lista que se va a agregar a local
            List<CustomerModel> list = [];
            //Lista de clientes eliminados
            List<CustomerModel> listDelete=[];
            //se recorre el arreglo de la respuesta
            for (var item in answer.body) {
              CustomerModel customer = CustomerModel.fromPayload(item);
              listDelete.add(customer);
              //se busca si ya existe en los registros locales
              var exits = users
                  .where((element) => element.idClient == customer.idClient);
              //si no existe se agrega 
              if (exits.isEmpty) {
                list.add(customer);
                if (customer.type == 1 ||
                    customer.type == 2 ||
                    customer.type == 3 ||
                    customer.type == 4) {
                      //esta es la lista que se muestra en ruta con 1 => ruta, 2 => especiales, 
                      //3 => segundas vueltas y 4 => clientes llama confirmados
                  customerList.add(customer);
                }
              }
              //el registro del cliente ya existe
              else{
                //se pregunta si el nuevo es segunda vuelta (3)
                if(customer.type==3){
                  //buscamos que de las visitas que tiene el cliente el id ya exista 
                  var exits2=exits.where((element) => element.id==customer.id);
                  if(exits2.isEmpty){
                    //si no existe el id al ultimo se le asigna el type 8 para sacarlo del universo visible
                    //TODO: lo comentamos para segir viendolo en atendidos
                    //exits.first.setType(8);
                    //agregamos a la nueva visita a la lista de nuevos
                  list.add(customer);
                  customerList.add(customer);
                  }else{
                    //si existe no lo agregamos
                    log("El registro ya existe");
                  }
                  log("===> ${exits.first.id} ::: ${customer.id}");
                }
                else{
                  //se actualiza solo una parte de la data del cliente
                  exits.first.updateData(customer);
                  await handler.updateUser(exits.first);
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

          }else{
            Fluttertoast.showToast(
              msg: "Conexion inestable con el back",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
              backgroundColor: ColorsJunghanns.red);
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
                provider.connectionStatus == 4? const WithoutInternet():provider.isNeedAsync?const NeedAsync():Container(),
                Visibility(
                    visible: !provider.permission,
                    child: const WithoutLocation()),
                header(),
                const SizedBox(
                  height: 15,
                ),
                buscador(),
                Visibility(
                visible: prefs.lastRouteUpdate != "",
                child: Padding(padding: const EdgeInsets.only(left: 15,top: 5,bottom: 5),
                child:Text(
                  "Ultima actualización: ${DateFormat('hh:mm a').format(prefs.lastBitacoraUpdate != "" ? DateTime.parse(prefs.lastBitacoraUpdate) : DateTime.now())}",
                  style: TextStyles.blue13It,
                ))),
                customerList.isNotEmpty
                    ? Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                        children: customerList.map((e)=>funSearch(e)?Column(children: [
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
                          ]):Container()
                        ).toList(),
                      )))
                    : Expanded(child:empty(context))
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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            onChanged: (value) => setState(() {
              
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

  
}
