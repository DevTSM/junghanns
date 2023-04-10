// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:junghanns/widgets/card/product.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/components/bottom_bar.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/components/loading.dart';
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
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    configList=[];
    refillList=[];
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
    provider.initShopping(CustomerModel.fromState());
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
              fun:() {
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
    Map<String, dynamic> data = {
      "id_cliente": provider.basketCurrent.idCustomer,
      "id_ruta": provider.basketCurrent.idRoute,
      "latitud": "$latSale",
      "longitud": "$lngSale",
      "venta": List.from(provider.basketCurrent.sales.map((element) => {"cantidad": element.number,
        "id_producto": element.idProduct,
        "precio_unitario": element.price
      }).toList()),
      "id_autorizacion": null,
      "formas_de_pago": [{
        "tipo": "E",
        "importe": (provider.basketCurrent.sales.map((e) => e.price).toList()).reduce((value, element) => value+element),
      }],
      "id_data_origen": provider.basketCurrent.idDataOrigin,
      "folio": null,
      "tipo_operacion": "R",
      "version": "1.13"
    };
    Map<String, dynamic> dataLocal = {
      "idCustomer": provider.basketCurrent.idCustomer,
      "idRoute": provider.basketCurrent.idRoute,
      "lat": "$latSale",
      "lng": "$lngSale",
      "saleItems": jsonEncode(List.from(provider.basketCurrent.sales.map((element) => {"cantidad": element.number,
        "id_producto": element.idProduct,
        "precio_unitario": element.price
      }).toList())),
      "idAuth":  null,
      "paymentMethod": jsonEncode([{
        "tipo": "E",
        "importe": (provider.basketCurrent.sales.map((e) => e.price).toList()).reduce((value, element) => value+element),
      }]),
      "idOrigin": provider.basketCurrent.idDataOrigin,
      "folio":  null,
      "type":"R",
      "isUpdate":0
    };
    int id= await handler.insertSale(dataLocal);
    
    widget.customerCurrent.setMoney(((provider.basketCurrent.sales.map((element) => element.price*element.number).toList()).reduce((value, element) => value+element))+widget.customerCurrent.purse,isOffline:true,type:0);
    widget.customerCurrent.setType(7);
    await postSale(data).then((answer) async {
      setState(() {
        isLoading = false;
      });
      if (!answer.error){
        await handler.updateSale(1, id).then((value){
          Fluttertoast.showToast(
          msg: "Venta realizada con exito",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
        
        });
        
      }
    });
        Navigator.pop(context,true);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    provider = Provider.of<ProviderJunghanns>(context);
    return Scaffold(
      backgroundColor: ColorsJunghanns.white,
      appBar: AppBar(
        backgroundColor: ColorsJunghanns.greenJ,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: ColorsJunghanns.greenJ,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light),
        leading: GestureDetector(
          child: Container(
              padding: const EdgeInsets.only(left: 24),
              child: Image.asset("assets/icons/menuWhite.png")),
          onTap: () {},
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [header(), isLoading ? const LoadingJunghanns() : itemList()],
      ),
      bottomNavigationBar: bottomBar(() {}, 2, isHome: false, context: context),
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
              Visibility(
                  visible: provider.connectionStatus == 4,
                  child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: const WithoutInternet())),
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
                                        bool isAdd) {
                                      provider.updateProductShopping(
                                          productCurrent, isAdd);
                                      setState(() {});
                                    },
                                    productCurrent: refillList[index],
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
                        height: 40,
                        alignment: Alignment.center,
                        child: ButtonJunghanns(
                          decoration: Decorations.blueBorder12,
                          fun: () => showConfirmSale(),
                          label: "Terminar venta",
                          style: TextStyles.white17_5,
                        )))
              ],
            ),
    );
  }
}
