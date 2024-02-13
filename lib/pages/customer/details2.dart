// ignore_for_file: sized_box_for_whitespace, avoid_unnecessary_containers, must_be_immutable
import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:junghanns/components/bottom_bar.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/modal/show_data.dart';
import 'package:junghanns/components/select.dart';
import 'package:junghanns/models/authorization.dart';
import 'package:junghanns/models/config.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/operation_customer.dart';
import 'package:junghanns/models/stop_ruta.dart';
import 'package:junghanns/pages/address/edit_address.dart';
import 'package:junghanns/pages/home/cuentas.dart';
import 'package:junghanns/pages/shop/shopping_cart.dart';
import 'package:junghanns/pages/shop/shopping_cart_refill.dart';
import 'package:junghanns/pages/shop/stops.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/balance.dart';
import 'package:junghanns/widgets/card/sales.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';

import '../../services/auth.dart';

class DetailsCustomer2 extends StatefulWidget {
  CustomerModel customerCurrent;
  int indexHome;
  DetailsCustomer2(
      {Key? key, required this.customerCurrent, required this.indexHome})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _DetailsCustomer2State();
}

class _DetailsCustomer2State extends State<DetailsCustomer2> {
  late ProviderJunghanns provider;
  late dynamic pickedImageFile;
  late List<ConfigModel> configList;
  late List<AuthorizationModel> authList;
  late List<OperationCustomerModel> operations;
  late List<Map<String,dynamic>> items;
  late LocationData currentLocation;
  late Map<String,dynamic> currentItem;
  late Size size;
  late int itemBar;
  late double dif;
  late bool isRange;
  late bool isLoading, isLoadingHistory, isLoadingRange;

  @override
  void initState() {
    super.initState();
    pickedImageFile = null;
    configList = [];
    authList = [];
    operations=[];
    items=[];
    currentItem={};
    dif = 0;
    itemBar=0;
    isRange = false;
    isLoading = false;
    isLoadingHistory = false;
    isLoadingRange = false;
    currentLocation = LocationData.fromMap({});
    setCurrentLocation();
    getHistory();
    getDataP();
    log("======= Venta permitida > ${widget.customerCurrent.ventaPermitida}");
  }

  

  setCurrentLocation() async {
    try {
      setState(() {
        isLoadingRange = true;
      });
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
        log("permission ${permission.toString()}");
        provider.permission = false;
        isRange = false;
      }
      setState(() {
        isLoadingRange = false;
      });
    } catch (e) {
      setState(() {
        isLoadingRange = false;
      });
      Fluttertoast.showToast(
          msg: "Dispositivo sin coordenadas",
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
              //log("-------- ${configList.length} ");
            }}
            setState(() {
              dif = calculateDistance(
                      widget.customerCurrent.lat,
                      widget.customerCurrent.lng,
                      currentLocation.latitude,
                      currentLocation.longitude) *
                  1000;
              isRange = dif <= configList.last.valor;
            });
        });
      } else {
        configList.addAll(widget.customerCurrent.configList);
        setState(() {
          dif = calculateDistance(
                  widget.customerCurrent.lat,
                  widget.customerCurrent.lng,
                  currentLocation.latitude,
                  currentLocation.longitude) *
              1000;
          isRange = dif <=
              (widget.customerCurrent.configList.isNotEmpty
                  ? widget.customerCurrent.configList.last.valor
                  : 0);
        });
      }
    } catch (e) {
      log("***ERROR -- $e");
      Fluttertoast.showToast(
          msg: "Conexion inestable con el back.",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
          backgroundColor: ColorsJunghanns.red);
      return false;
    }
  }

  getHistory() async {
    setState(() {
      isLoadingHistory = true;
    });
    await getHistoryCustomer(widget.customerCurrent.idClient).then((answer) {
      setState(() {
        isLoadingHistory = false;
      });
      if (!answer.error) {
        setState(() {
          widget.customerCurrent.setHistory(answer.body);
          handler.updateUser(widget.customerCurrent);
        });
      }
    });
  }
  
  getDataP() async {
    if(itemBar == 1){
      setState(() {
        isLoading=true;
        operations.clear();
      });
    }
    //obtenemos la lista de operaciones por sincronizar
    List<Map<String,dynamic>> listOperationHandler = 
      await handler.retrieveDevolucionAsync();
    await getCreditos(widget.customerCurrent.idClient).then((answer) async {
      setState(() {
        isLoading=false;
      });
      if (!answer.error) {
        operations.clear();
        for(var e in answer.body){
          OperationCustomerModel currentOperation = 
            OperationCustomerModel.fromServices(e);
            //validamos que tenga algo que devolver 
            if(currentOperation.amount > 0){
            //validamos que no exista en un registro local que haya sido devuelto
            if(listOperationHandler.where((element) => 
              (element["idDocumento"]??"") == currentOperation.folio).isEmpty){
              setState((){
                operations.add(OperationCustomerModel.fromServices(e));
              });
            }
          }
        }
        //si no hay operaciones y el itembar este en "por cobrar" se regresa al dashboard
        if(itemBar == 1 && operations.isEmpty){
          setState(()=> itemBar = 0);
        }
        //actualizamos las listas locales "por cobrar"
        widget.customerCurrent.setCreditos(operations);
      } else {
        setState((){
          operations = widget.customerCurrent.operation;
          //si no hay operaciones y el itembar este en "por cobrar" se regresa al dashboard
          if(itemBar == 1 && operations.isEmpty){
            itemBar = 0;
          }
        });
        Fluttertoast.showToast(
          msg: "Conexión inestable con la planta jusoft",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      }
      List<Map<String,dynamic>> currentList = await handler.retrieveDevolucion();
      //buscamos los registros locales de devoluciones de ese cliente
      currentList = currentList.where((element) => element["idCliente"] 
        == widget.customerCurrent.idClient).toList();
      currentList.map((e){
        var exits = operations.where((element) => 
          element.idDocument == e["idDocumento"]);
        if(exits.isNotEmpty){
          exits.first.returnedAmount = 
            exits.first.amountReturned + int.parse(e["cantidad"].toString());
        }else{
          OperationCustomerModel tem = OperationCustomerModel.fromDataBase(e);
          tem.returnedAmount = tem.amount;
          tem.updateCount = 0;
          setState(()=> operations.add(tem));
        }
      }).toList();
      items.clear(); 
      if(operations.where((element) => element.typeInt == 1).isNotEmpty){
          items.add({"id":1,"descripcion":"Comodato"});
        }
      if(operations.where((element) => element.typeInt == 2).isNotEmpty){
        items.add({"id":2,"descripcion":"Prestamo"});
      }
      if(operations.where((element) => element.typeInt == 3).isNotEmpty){
        items.add({"id":3,"descripcion":"Credito"});
      }
      if(items.isNotEmpty){
        currentItem = items.first;
      }
    });
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

  showSelectPR() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(25),
              width: size.width * .75,
              height: size.height * .24,
              decoration: Decorations.lightBlueS1Card,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ButtonJunghanns(
                        isIcon: true,
                        icon: Image.asset(
                          "assets/icons/shopP2.png",
                          width: size.width * 0.14,
                        ),
                        fun: () => navigatorShopping(),
                        decoration: Decorations.blueBorder12,
                        style: TextStyles.white14_5,
                        label: "Productos"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                      child: ButtonJunghanns(
                          isIcon: true,
                          icon: Image.asset("assets/icons/shopR1.png",
                              width: size.width * 0.14),
                          fun: () => navigatorShoppingRefill(),
                          decoration: Decorations.whiteSblackCard,
                          style: TextStyles.blue16_4,
                          label: "Recargas"))
                ],
              ),
            ),
          );
        });
  }

  navigatorShopping() async {
    Navigator.pop(context);
    try {
      Navigator.push(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) => ShoppingCart(
                index: widget.indexHome,
                    customerCurrent: widget.customerCurrent,
                    authList: authList,
                  ))).then((value) => setState(() {
            log("se actualizo =====> ${widget.customerCurrent.auth.length}  ${widget.customerCurrent.id}");
            getHistory();
            log("se actualizo =====> ${widget.customerCurrent.type}  ${widget.customerCurrent.id}");
          }));
    } catch (e) {
      log(e.toString());
    }
  }

  navigatorShoppingRefill() {
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => ShoppingCartRefill(
                  customerCurrent: widget.customerCurrent,
                ))).then((value) => setState(() {
          getHistory();
        }));
  }

  funCheckDistanceSale(bool isSale) async {
    setState(() {
      isLoading = true;
    });
    await setCurrentLocation();
    await getAuth();
    setState(() {
      isLoading = false;
    });
    if (isRange) {
      if (isSale) {
        showSelectPR();
      } else {
        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (BuildContext context) => Stops(
                      customerCurrent: widget.customerCurrent,
                      distance: (configList.isNotEmpty
                          ? configList.last.valor
                          : 0))));
        }
      }
    } else {
      Fluttertoast.showToast(
        msg: "Estás a ${dif.ceil()} mtrs del domicilio",
        timeInSecForIosWeb: 16,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        webShowClose: true,
      );
    }
  }

  funCurrentLocation() {
    Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => EditAddress(
                lat: widget.customerCurrent.lat,
                lng: widget.customerCurrent.lng)));
  }

  _pickImage(int type) async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.getImage(
        source: type == 1 ? ImageSource.camera : ImageSource.gallery,
        maxHeight: 1500,
        maxWidth: 1500,
        imageQuality: 50,
      );
      setState(() {
        pickedImageFile = File(pickedImage!.path);
      });

      if (pickedImageFile != null) {
        final img = await pickedImage!.readAsBytes();
        File fileData =
            File.fromRawPath(img.buffer.asUint8List(0, img.lengthInBytes));
        var multipartFile = http.MultipartFile.fromBytes(
          'image',
          img.buffer.asUint8List(),
          filename: 'avatar.png', // use the real name if available, or omit
          contentType: MediaType('image', 'png'),
        );
        await updateAvatar(multipartFile,
            widget.customerCurrent.idClient.toString(), "SANDBOX");
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg:
            "No fue posible ${type == 1 ? "abrir la camara" : "abrir la galeria"},por favor revisa los permisos e intentelo mas tarde.",
        timeInSecForIosWeb: 2,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: ColorsJunghanns.red,
        gravity: ToastGravity.TOP,
        webShowClose: true,
      );
    }
  }

  funGoMaps() async {
    log("Go Maps");
    if (widget.customerCurrent.lat != 0 && widget.customerCurrent.lng != 0) {
      log("Go Maps Yes");
      var map = await MapLauncher.isMapAvailable(MapType.google);
      if (map ?? false) {
        log(" lat ->${widget.customerCurrent.lat} long ->${widget.customerCurrent.lng}");
        await MapLauncher.showMarker(
          mapType: MapType.google,
          coords:
              Coords(widget.customerCurrent.lat, widget.customerCurrent.lng),
          title: widget.customerCurrent.name,
          description: "",
        );
      } else {
        log("Go Maps Not");
        Fluttertoast.showToast(
          msg: "Sin mapa disponible",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      }
    } else {
      log("No LAT y No LNG");
      Fluttertoast.showToast(
        msg: "Sin coordenadas",
        timeInSecForIosWeb: 2,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        webShowClose: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      size = MediaQuery.of(context).size;
    });
    provider = Provider.of<ProviderJunghanns>(context);
    return !provider.asyncProcess
        ? Stack(children: [
            Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(10),
                child: Container(
                  color: JunnyColor.bluea4,
                ),),
              backgroundColor: ColorsJunghanns.lightBlue,
              body: refreshScroll(),
              bottomNavigationBar: bottomBar(() {}, widget.indexHome,context,
                  isHome: false),
            ),
            Visibility(visible: isLoading, child: const LoadingJunghanns())
          ])
        : Scaffold(
            body: Stack(
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
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
          ));
  }

  Widget refreshScroll() {
    return RefreshIndicator(
      child: SingleChildScrollView(
        child: Column(
          children: [
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
                )
              )
            ),
            header(),
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
                )
              )
            ),
            Visibility(
              visible: operations.isNotEmpty,
              child: Container(
                decoration: Decorations.green16Bottom,
                child:Row(
                  children: [
                    Expanded(
                      child:GestureDetector(
                        onTap: ()=>setState(()=>itemBar=0),
                        child:Container(
                          alignment: Alignment.center,
                          decoration: itemBar==0
                            ?Decorations.blue16Bottom
                            :const BoxDecoration(color: Colors.transparent),
                          padding: const EdgeInsets.all(5),
                          child:AutoSizeText(
                            "Venta",
                            style: TextStyles.white18SemiBold,
                          )
                        )
                      )
                    ),
                    Visibility(
                      visible: operations.isNotEmpty,
                      child: Expanded(
                        child:GestureDetector(
                          onTap: ()=>setState( ()=> itemBar = 1),
                          child:Container(
                            alignment: Alignment.center,
                            decoration: itemBar == 1
                              ? Decorations.blue16Bottom
                              : const BoxDecoration(color: Colors.transparent),
                            padding: const EdgeInsets.all(5),
                            child:AutoSizeText(
                              "Por cobrar",
                              style: TextStyles.white18SemiBold,
                            )
                          )
                        )
                      )
                    ),
                  ],
                )
              )
            ),
            itemBar ==0 ?balances() : creditosWidget(),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      onRefresh: () async {
        setCurrentLocation();
        getDataP();
      }
    );
  }

  Widget header() {
    return Container(
      color: ColorsJunghanns.blue,
      padding: EdgeInsets.only(
        right: 15, left: 23, top: 5, bottom: size.height * .03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios,
              color: ColorsJunghanns.white,
            )
          ),
          Expanded(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: ColorsJunghanns.green,
                      size: 28,
                    ),
                    Expanded(
                      child: AutoSizeText(
                        widget.customerCurrent.address,
                        style: TextStyles.white20SemiBoldIt,
                      )
                    )
                  ],
                ),
                onTap: () => funGoMaps(),
              ),
              Container(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: RichText(
                  text: TextSpan(
                    text: "Ref. Domicilio: ",
                    style: TextStyles.green16Itw,
                    children: <TextSpan>[
                      TextSpan(
                        text: widget.customerCurrent.referenceAddress,
                        style: TextStyles.white16SemiBoldIt
                      ),
                    ],
                  ),
                )
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${widget.customerCurrent.idClient}",
                      style: TextStyles.green18Itw,
                    ),
                    TextSpan(
                      text: "  |  ",
                      style: TextStyles.white60It18,
                    ),
                    TextSpan(
                      text: widget.customerCurrent.name,
                      style: TextStyles.white15It,
                    )
                  ]
                )
              )
            ],
          )
        ),
        const SizedBox(
          width: 10,
        ),
        GestureDetector(
          onTap: () => _pickImage(1),
          child: Image.asset(
            "assets/icons/photo.png",
            width: size.width * .13,
          )
        )
      ],
    ),
  );
  }

  Widget balances() {
    return Container(
      margin: EdgeInsets.only(top: size.height * .01),
      child: Column(
        children: [
          //photoCard(),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
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
                          widget.customerCurrent.category,
                          style: TextStyles.grey14_4,
                        )
                      ],
                    ),
                  )
                ),
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
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: widget.customerCurrent.nameRoute,
                            style: TextStyles.white17_5
                          ),
                        ]
                      )
                    )
                  )
                ),
              ],
            )
          ),
          const SizedBox(
            height: 15,
          ),
          Visibility(
            visible: widget.customerCurrent.horario1 != ""
              && !widget.customerCurrent.horario1.contains("00:00"),
            child: _horariosPref()
          ),
          Container(
            decoration: Decorations.lightBlueBorder5,
            margin: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/icons/invoice${widget.customerCurrent.invoice 
                        ? "Green" : "Red"}.png",
                        width: 40,
                      ),
                      Text(
                        widget.customerCurrent.invoice
                          ? "Solicita Factura"
                          : "No Solicita Factura",
                        style: TextStyles.grey14_4,
                      )
                    ],
                  )
                ),
                SizedBox(
                  width: widget.customerCurrent.invoice ? 10 : 0,
                ),
              ],
            ),
          ),
          Visibility(
            visible: widget.customerCurrent.invoice,
            child:Container(
              padding: const EdgeInsets.only(left: 15,right: 15,top: 10),
              child:ButtonJunghanns(
                fun: ()=> showDataBilling(context,widget.customerCurrent.billing), 
                decoration: Decorations.greenBorder5, 
                style: TextStyles.white17_5, 
                label: "Ver datos de facturación"
              )
            )
          ),
          SizedBox(
            height: widget.customerCurrent.descServiceS != "" ? 15 : 0,
          ),
          Visibility(
            visible: widget.customerCurrent.descServiceS != "",
            child: observation(
              "Descripción de servicio",
              widget.customerCurrent.descServiceS
            )
          ),
          const SizedBox(
            height: 10,
          ),
          observation(
            "Observaciones de servicio", 
            widget.customerCurrent.observation
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.only(left: 15,right: 15),
            width: double.infinity,
            child: ButtonJunghanns(
              decoration: JunnyDecoration.blueCEOpacity_5Blue(8),
              style: JunnyText.bluea4(FontWeight.w500, 16),
              fun: ()=> showCuentas(context, widget.customerCurrent.idClient),
              isIcon: true,
              icon: Image.asset(
                "assets/icons/transfer.png",
                color: JunnyColor.blueC2,
                height: 30,
              ),
              label: "Cuentas bancarias"
            )
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: itemBalance(
                    "liquitIcon.png", 
                    "Precio Liquido",
                    widget.customerCurrent.priceLiquid, 
                    size.width - 40
                  )
                ),
                Expanded(
                  child: itemBalance(
                    "cashIcon.png", 
                    "Monedero",
                    widget.customerCurrent.purse, 
                    size.width - 40
                  )
                ),
                Expanded(
                  child: itemBalance(
                    "creditIcon.png", 
                    "Por cobrar",
                    widget.customerCurrent.byCollect, 
                    size.width - 40
                  )
                )
              ],
            )
          ),
          const SizedBox(
            height: 15,
          ),
          Visibility(
            visible: widget.customerCurrent.notifS != ""
              && widget.customerCurrent.ventaPermitida!=0,
            child: observation(
              "Notificación de servicio", 
              widget.customerCurrent.notifS
            )
          ),
          Visibility(
            visible: widget.customerCurrent.ventaPermitida == 0,
            child: _ventaSuspendida(
              "VENTA NO PERMITIDA",
              "El registro de ventas de crédito o contado se encuentra bloqueado debido a algún adeudo en su cuenta."
            )
          ),
          SizedBox(
            height: widget.customerCurrent.notifS != "" ? 15 : 10,
          ),
          _paradaVentaButtons(),
          const SizedBox(
            height: 20,
          ),
          history()
        ],
      ),
    );
  }

  Widget _paradaVentaButtons(){
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: isLoadingRange
        ? const SpinKitCircle (color: ColorsJunghanns.blue)
        : isRange 
          ? prefs.statusRoute == "INRT" 
            || prefs.statusRoute == "FNCM" 
            || prefs.statusRoute == "FNRT"
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Visibility(
                      visible: widget.customerCurrent.ventaPermitida==1,
                      child: Expanded(
                        child: ButtonJunghanns(
                          decoration: Decorations.greenBorder5,
                          style: TextStyles.white17_5,
                          fun: ()=> funCheckDistanceSale(true),
                          isIcon: true,
                          icon: Image.asset(
                            "assets/icons/shoppingCardWhiteIcon.png",
                            height: 30,
                          ),
                          label: "Venta"
                        )
                      )
                    ),
                    Visibility(
                      visible: widget.customerCurrent.ventaPermitida == 1,
                      child: const SizedBox(width: 10)
                    ),
                    Expanded(
                      child: ButtonJunghanns(
                        decoration: Decorations.whiteBorder5Red,
                        style: TextStyles.red17_6,
                        fun: () => funCheckDistanceSale(false),
                        isIcon: true,
                        icon: const Icon(
                          Icons.tour,
                          color: JunnyColor.red5c,
                          size: 30,),
                        label: "Parada"
                      )
                    )
                  ],
                )
              : ButtonJunghanns(
                  fun: () async {
                    setState(()=> isLoading = true);
                    StopRuta stop = StopRuta(
                      id: 1,
                      update: 0,
                      lat: currentLocation.latitude!,
                      lng: currentLocation.longitude!,
                      status: "INRT"
                    );
                    int id = 0;
                    try {
                      id = await handler.insertStopRuta(stop);
                    } catch (e) {
                      Fluttertoast.showToast(
                        msg: "Local:$e",
                        timeInSecForIosWeb: 2,
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.TOP,
                        webShowClose: true,
                      );
                    }
                    await setInitRoute(
                      currentLocation.latitude!,
                      currentLocation.longitude!
                    ).then((answer) {
                      setState(()=> isLoading = false);
                      if (!answer.error) {
                        handler.updateStopRuta(1, id);
                      } else {
                        log("StopRuta por actualizar");
                      }
                    });
                    setState(()=> prefs.statusRoute = "INRT");
                  },
                  decoration: Decorations.greenBorder5,
                  style: TextStyles.white17_6,
                  label: "Iniciar ruta"
                )
          : ButtonJunghanns(
              fun: () {},
              decoration: Decorations.whiteBorder5Red,
              style: TextStyles.red17_6,
              label: "ESTÁS A ${dif.ceil()} mtrs DEL CLIENTE !!"
            )
    );
  }

  Widget _horariosPref(){
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 15,right: 15,bottom: 10),
      decoration: JunnyDecoration.orange255(10)
        .copyWith(color: JunnyColor.blueA1.withOpacity(.1)),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text(
              "Horario preferente",
              style: JunnyText.bluea4(FontWeight.w600, 14)
          ),
          const SizedBox(height: 3),
          widget.customerCurrent.horario2!=""
        ? Row(
            children: [
              Expanded(
                child: AutoSizeText(
                  "${widget.customerCurrent.horario1} o ",
                  maxLines: 1,
                  style: JunnyText.bluea4(FontWeight.w600, 14)
                ),
              ),
              Expanded(
                child: AutoSizeText(
                  widget.customerCurrent.horario2,
                  maxLines: 1,
                  style: JunnyText.bluea4(FontWeight.w600, 14)
                ),
              ),
            ],
          )
        : Text(
            widget.customerCurrent.horario1,
            style: JunnyText.bluea4(FontWeight.w600, 14)
          ),
        ],
      )
    );
  }
  
   Widget _ventaSuspendida(String title, String descripcion) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(left: 15, right: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8)
      ),
      child: Container(
        decoration: JunnyDecoration.orange255(8)
          .copyWith(color: const Color.fromARGB(255, 211, 18, 82)),
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: JunnyText.bluea4(FontWeight.w600, 14)
                      .copyWith(color: JunnyColor.white),
                  )
                ),
                const Icon(
                  Icons.lock_outline,
                  color: JunnyColor.white,
                  size: 30,
                )
              ],
            ),
            Container(
              padding: const EdgeInsets.only(left: 4, right: 4, bottom: 5, top: 5),
              child: Text(
                descripcion,
                style: JunnyText.grey_255(FontWeight.w300, 12)
                  .copyWith(color: JunnyColor.white)
              )
            ),
          ],
        )
      ),
    );
  }

  Widget creditosWidget(){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10,right: 10,top: 20),
          child:selectMap(
            context, 
            (value)=>setState(()=>currentItem=value), 
            items, 
            currentItem
          )
        ),
        Column(
          children:
            operations.where((element) => 
                element.typeInt==currentItem["id"])
                .toList().map((e) => 
              OperationsCard(
                current: e,
                update:getDataP,
                currentClient:widget.customerCurrent
              )
            ).toList()
        )
      ],
    );
    
  }

  Widget observation(String titleO, String textO) {
    return Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
              side: titleO == "Observaciones de servicio"
                  ? BorderSide.none
                  : titleO == "Descripción de servicio"
                      ? const BorderSide(
                          color: ColorsJunghanns.greenJ, width: 1)
                      : const BorderSide(color: Colors.orange, width: 1),
              borderRadius: BorderRadius.circular(8)),
          child: Container(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 10, bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                        titleO,
                        style: titleO == "Observaciones de servicio"
                            ? TextStyles.blueJ20Bold
                            : titleO == "Descripción de servicio"
                                ? TextStyles.greenJ20Bold
                                : TextStyles.orangeJ20Bold,
                      )),
                      titleO == "Observaciones de servicio"
                          ? Image.asset(
                              "assets/icons/observationIcon.png",
                              width: 50,
                            )
                          : Icon(
                              titleO == "Descripción de servicio"
                                  ? FontAwesomeIcons.exclamationCircle
                                  : FontAwesomeIcons.exclamationTriangle,
                              color: titleO == "Descripción de servicio"
                                  ? ColorsJunghanns.greenJ
                                  : ColorsJunghanns.orange,
                              size: 28,
                            ),
                    ],
                  ),
                  Container(
                      padding: const EdgeInsets.only(
                          left: 4, right: 4, bottom: 5, top: 8),
                      child: Text(textO,
                          textAlign: TextAlign.justify,
                          style: TextStyles.grey17_4)),
                  /*Container(
                    width: double.infinity,
                    alignment: Alignment.bottomRight,
                    child: Image.asset(
                      "assets/icons/editIcon.png",
                      width: 25,
                    ),
                  )*/
                ],
              )),
        ));
  }

  Widget photoCard() {
    return Container(
        width: double.infinity,
        height: size.width * .50,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            image: widget.customerCurrent.img == "" ||
                    widget.customerCurrent.img ==
                        "https://sandbox.junghanns.app/img/clientes/address/SANDBOX/"
                ? const DecorationImage(
                    image: AssetImage("assets/images/withoutPicture.png"),
                    fit: BoxFit.cover)
                : DecorationImage(
                    image: NetworkImage(widget.customerCurrent.img),
                    fit: BoxFit.cover)),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            pickedImageFile != null
                ? Container(
                    width: double.infinity,
                    height: size.width * .50,
                    child: Card(
                      child: Image.file(
                        pickedImageFile,
                        fit: BoxFit.cover,
                      ),
                    ))
                : Container(),
            GestureDetector(
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 15, right: 15, top: 10, bottom: 10),
                  margin: const EdgeInsets.all(10),
                  decoration: Decorations.greenBorder5,
                  child: const Text(
                    "Ubicación Actual",
                    style: TextStyles.white17_5,
                  ),
                ),
                onTap: () => funCurrentLocation())
          ],
        ));
  }

  Widget history() {
    return Container(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //
            photoCard(),
            //
            const SizedBox(
              height: 20,
            ),
            const Text(
              "\t\t\t\tHistorial de visitas",
              style: TextStyles.blue25_7,
            ),
            const SizedBox(
              height: 20,
            ),
            widget.customerCurrent.history.isEmpty
                ? Container(
                    padding: const EdgeInsets.only(top: 20, bottom: 50),
                    alignment: Alignment.center,
                    child: const Text(
                      "Sin historial",
                      style: TextStyles.grey17_4,
                    ))
                : Column(
                    children: widget.customerCurrent.history
                        .map((e) => Column(
                              children: [
                                SalesCard(saleCurrent: e),
                                Row(children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: (size.width * .07) + 15),
                                    color: ColorsJunghanns.grey,
                                    width: .5,
                                    height: 15,
                                  )
                                ])
                              ],
                            ))
                        .toList(),
                  )
          ],
        ));
  }
}
