// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/components/bottom_bar.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/need_async.dart';
import 'package:junghanns/components/without_internet.dart';
import 'package:junghanns/models/config.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/product.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/auth.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/product.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../../models/authorization.dart';

class ShoppingCartRefill extends StatefulWidget {
  CustomerModel customerCurrent;
  ShoppingCartRefill({
    Key? key,
    required this.customerCurrent,
  }) : super(key: key);

  @override
  State<ShoppingCartRefill> createState() => _ShoppingCartRefillState();
}

class _ShoppingCartRefillState extends State<ShoppingCartRefill> {
  late Size size;
  late NumberFormat formatMoney = NumberFormat("\$#,##0.00");
  late ProviderJunghanns provider;
  late List<ProductModel> refillList;
  late List<ConfigModel> configList;
  late bool isLoading, isRange;
  late double latSale, lngSale,distance;
  late List<AuthorizationModel> authList;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    configList=[];
    refillList=[];
    authList = [];
    isLoading = false;
    isRange = false;
    distance = 0;
    latSale = 0;
    lngSale = 0;
    getDataRefill();
  }
  @override
  void dispose(){
    super.dispose();
    //provider.initShopping(CustomerModel.fromState());
  }

  getAuth() async {
    authList.clear();
    await getAuthorization(widget.customerCurrent.idClient, prefs.idRouteD)
        .then((answer) {
      log(answer.body.toString());
      if (!answer.error) {
        answer.body
            .map((e) => authList.add(AuthorizationModel.fromService(e)))
            .toList();
        widget.customerCurrent.setAuth(authList);
      } else {
        authList.addAll(widget.customerCurrent.auth);
      }
    });

  }

  getDataRefill() async {
    Timer(const Duration(milliseconds: 800), () async {
      provider.initShopping(widget.customerCurrent);
      List<ProductModel> data=await handler.retrieveRefill();
      setState(() {
        data.map((e) => refillList.add(e)).toList();
      });
    });
  }
  
  showConfirmSale() {
    setState(() {
      isProcessing = true; // Deshabilitar el botón
    });
    showDialog(
          context: context,
          builder: (BuildContext context) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                width: size.width * .75,
                decoration: Decorations.whiteS1Card,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DefaultTextStyle(
            style: TextStyles.blueJ22Bold,
            child: const Text("¿Pago en Efectivo?")),
                    DefaultTextStyle(
            style: TextStyles.blueJ215R,
            child: const Text(
              "Deseas registrar la venta de:",
            )),
        DefaultTextStyle(
            style: TextStyles.greenJ24Bold,
            child: Text(formatMoney.format(provider.basketCurrent.totalPrice))),
                  Material(child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child:ButtonJunghanns(fun: () async {
                    Navigator.pop(context);
                    //onLoading();
                    setState(() {
                      isLoading = true;
                    });
                    await setCurrentLocation();
                    if (isRange) {
                      if (latSale != 0 && lngSale != 0) {
                        funSale();
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                        Fluttertoast.showToast(
                          msg: "Sin coordenadas ",
                          timeInSecForIosWeb: 16,
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.TOP,
                          webShowClose: true,
                        );
                      }
                    } else {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }, decoration: Decorations.blueBorder12, style: TextStyles.white18SemiBoldIt, label: "Si")),
                  const SizedBox(width: 25,),
           Expanded(child:ButtonJunghanns(
              fun:() async {
                    Navigator.pop(context);
                  },
                   decoration: Decorations.redCard, style: TextStyles.white18SemiBoldIt, label: 
                   "No",)),
        ],
      ))
                  ],
                ),
              ),
            );
          });
    setState(() {
      isProcessing = false; // Reactivar el botón si es necesario
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
          LocationData currentLocation = await locationInstance
              .getLocation()
              .timeout(const Duration(seconds: 15));
              latSale=currentLocation.latitude!;
              lngSale=currentLocation.longitude!;
          await funCheckDistance(currentLocation);
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
        isRange = false;
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
  
  funCheckDistance(LocationData currentLocation) async {
    try {
      if (provider.connectionStatus < 4) {
        await getConfig(widget.customerCurrent.idClient).then((answer) {
          if (answer.error) {
            Fluttertoast.showToast(
              msg: answer.message,
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
            );
            configList.addAll(widget.customerCurrent.configList);
          } else {
            for (var item in answer.body) {
              configList.add(ConfigModel.fromService(item));
            }
            setState(() {
              distance = calculateDistance(
                      widget.customerCurrent.lat,
                      widget.customerCurrent.lng,
                      currentLocation.latitude,
                      currentLocation.longitude) *
                  1000;
              isRange = distance <= configList.last.valor;
              log(" distance $distance isRange $isRange");
            });
          }
        });
      } else {
        setState(() {
          distance = calculateDistance(
                  widget.customerCurrent.lat,
                  widget.customerCurrent.lng,
                  currentLocation.latitude,
                  currentLocation.longitude) *
              1000;
          isRange = distance <=
              (widget.customerCurrent.configList.isNotEmpty
                  ? widget.customerCurrent.configList.first.valor
                  : 0);
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
          backgroundColor: ColorsJunghanns.red);
      return false;
    }
  }
  
  funSale() async {
    Map<String, dynamic> data = {};
      data["id_cliente"]= provider.basketCurrent.idCustomer;
      data["id_ruta"]= provider.basketCurrent.idRoute;
      data["latitud"]= "$latSale";
      data["longitud"]="$lngSale";
      data["venta"]= List.from(provider.basketCurrent.sales.map((element) => {"cantidad": element.number,
        "id_producto": element.idProduct,
        "precio_unitario": element.price
      }).toList());
      data["formas_de_pago"]= [{
        "tipo": "E",
        "importe": (provider.basketCurrent.sales.map((e) => e.price).toList()).reduce((value, element) => value+element),
      }];
      data["id_data_origen"]= provider.basketCurrent.idDataOrigin;
      data["tipo_operacion"]= "R";
    Map<String, dynamic> dataLocal = {
      "idCustomer": provider.basketCurrent.idCustomer,
      "idRoute": provider.basketCurrent.idRoute,
      "lat": "$latSale",
      "lng": "$lngSale",
      "saleItems": jsonEncode(List.from(provider.basketCurrent.sales.map((element) => {"cantidad": element.number,
        "id_producto": element.idProduct,
        "precio_unitario": element.price
      }).toList())),
      "paymentMethod": jsonEncode([{
        "tipo": "E",
        "importe": (provider.basketCurrent.sales.map((e) => e.price).toList()).reduce((value, element) => value+element),
      }]),
      "idOrigin": provider.basketCurrent.idDataOrigin,
      "type":"R",
      "isUpdate":0
    };
    int id= await handler.insertSale(dataLocal);
    data["id_local"]=id;
    
    await postSale(data).then((answer) async {
      setState(() {
        isLoading = false;
      });
      if (!answer.error){
        await handler.updateSale({'isUpdate': 1,
      'fecha':DateTime.now().toString()}, id).then((value){
        widget.customerCurrent.setMoney(((provider.basketCurrent.sales.map((element) => element.price*element.number).toList()).reduce((value, element) => value+element))+widget.customerCurrent.purse,isOffline:true,type:0);
    widget.customerCurrent.addHistory({
    'fecha':DateTime.now().toString(),
    'tipo':"RECARGA",
    'descripcion':"${provider.basketCurrent.sales.first.idProduct} - ${provider.basketCurrent.sales.first.description}",
    'importe':provider.basketCurrent.sales .map((e) => e.number*e.price).toList().reduce((value, element) => value+element),
    'cantidad':provider.basketCurrent.sales .map((e) => e.number).toList().reduce((value, element) => value+element)
  });
    widget.customerCurrent.setType(7);
        return AwesomeDialog(
          context: context,
          dialogType:
             DialogType.success,
          animType: AnimType.rightSlide,
          title:'Recarga registrada con exito',
          dismissOnTouchOutside: false,
          btnOkText: "Aceptar",
          btnOkOnPress: () => Navigator.pop(context, true),
        ).show();
        });
      }else{
        await handler.updateSale({"isError":1,'isUpdate': 1,},id).then((value) => AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title:'¡Upss!',
          dismissOnTouchOutside: false,
          desc: answer.status == 1002 ? "No es posible registrar una recarga sin red, verifica tu conexion." : answer.message,
          btnOkText: "Aceptar",
          btnOkOnPress: () => Navigator.pop(context, true),
        ).show());
        
      }
    });
        //Navigator.pop(context,true);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    provider = Provider.of<ProviderJunghanns>(context);
    return Scaffold(
      backgroundColor: ColorsJunghanns.white,
      appBar: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: Container(),),
      body: Stack(
        children: [header(), isLoading ? const LoadingJunghanns() : itemList()],
      ),
      bottomNavigationBar: bottomBar(() {}, 2,context, isHome: false),
    );
  }

  Widget header() {
    return Container(
        color: ColorsJunghanns.green,
        padding: EdgeInsets.only(
            right: 15, left: 23, top: 10, bottom: size.height * .05),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              provider.connectionStatus == 4? const WithoutInternet():provider.isNeedAsync?const NeedAsync():Container(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: ColorsJunghanns.white,
                      )),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(right: 8, top: 10),
                            child: Text(
                              //shoppingBasket.length.toString(),
                              provider.basketCurrent.sales.isNotEmpty? (provider.basketCurrent.sales.map((e) => e.number).toList()).reduce((value, element) => value+element).toString():"0",
                              style: TextStyles.white24SemiBoldIt,
                            ),
                          ),
                          Image.asset(
                            "assets/icons/shoppingIcon.png",
                            width: 60,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        formatMoney.format(provider.basketCurrent.sales.isNotEmpty?(provider.basketCurrent.sales.map((e) => e.price*e.number).toList()).reduce((value, element) => value+element):0.0),
                        style: TextStyles.white40Bold,
                      )
                    ],
                  )),
                  SizedBox(
                    width: size.width * .1,
                  ),
                ],
              ),
            ]));
  }

  Widget itemList() {
    return Container(
      margin: EdgeInsets.only(top: size.height * .22),
      padding: const EdgeInsets.only(left: 10, right: 10),
      width: double.infinity,
      child: refillList.isEmpty
          ? Center(
              child: Text(
              "Sin recargas",
              style: TextStyles.blue18SemiBoldIt,
            ))
          : Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                    child: SizedBox(
                  width: size.width,
                  child: GridView.custom(
                    gridDelegate: SliverWovenGridDelegate.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 13,
                      crossAxisSpacing: 13,
                      pattern: [
                        const WovenGridTile(.85),
                        const WovenGridTile(.85),
                      ],
                    ),
                    childrenDelegate: SliverChildBuilderDelegate(
                        (context, index) => ProductSaleCard(
                          isRefill: true,
                                    update: (ProductModel productCurrent,
                                        int isAdd) {
                                      provider.updateProductShopping(
                                          context, productCurrent, isAdd);
                                      setState(() {});
                                    },
                                    productCurrent: refillList[index],  customerCurrent: widget.customerCurrent,
                                  ),
                        childCount: refillList.length),
                  ),
                )),
                Visibility(
                    visible: provider.basketCurrent.sales.isNotEmpty,
                    child: Container(
                        margin: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 30, top: 30),
                        width: double.infinity,
                        height: 45,
                        alignment: Alignment.center,
                        child: ButtonJunghanns(
                          decoration: isProcessing
                              ? Decorations.greyBorder12 // Botón deshabilitado
                              : Decorations.blueBorder12, // Botón habilitado
                          fun: isProcessing
                              ? null // Deshabilitar botón si está procesando
                              : () async {
                            showConfirmSale(); // Encapsular la llamada a caseSale dentro de una función anónima
                          }, // Lógica del botón
                          label: isProcessing
                              ? "Procesando..." // Texto cuando está deshabilitado
                              : "Terminar venta", // Texto cuando está habilitado
                          style: isProcessing
                              ? TextStyles.white17_5 // Estilo deshabilitado
                              : TextStyles.white17_5,
                        )/*ButtonJunghanns(
                          decoration: Decorations.blueBorder12,
                          fun: () => showConfirmSale(),
                          label: "Terminar venta",
                          style: TextStyles.white17_5,
                        )*/))
              ],
            ),
    );
  }
}
