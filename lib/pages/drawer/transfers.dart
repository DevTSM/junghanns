import 'dart:async';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/components/empty/empty.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/product_missing_card.dart';
import 'package:junghanns/widgets/modal/add_others_product.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/button_delivery.dart';
import '../../components/need_async.dart';
import '../../components/select.dart';
import '../../components/without_internet.dart';
import '../../models/customer.dart';
import '../../provider/provider.dart';
import '../../services/store.dart';
import '../../util/location.dart';

import '../../widgets/card/product_addditional_card.dart';
import '../../widgets/card/product_others_card.dart';
import '../../widgets/card/product_transfers_card.dart';
import '../../widgets/modal/add_missing_product.dart';

import '../../widgets/modal/add_transfers_product.dart';
import '../../widgets/modal/decline.dart';
import '../../widgets/modal/decline_trasnfers.dart';
import '../../widgets/modal/informative.dart';
import '../home/home_principal.dart';
import 'mapa_actual.dart';

class Transfers extends StatefulWidget {
  const Transfers({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TransfersState();
}
class _TransfersState extends State<Transfers> {
  late List<Map<String, dynamic>> products, routes;
  late Map<String, dynamic> product, route;
  late Size size;
  late bool isLoading;
  late bool isLoadingOne;
  late Position _currentLocation;
  bool isDeliverySuccessful = false;
  bool isValidating = false;
  bool isButtonDisabled = false;
  bool areFieldsEditable = true; // Nuevo estado para editar los campos
  List specialData = [];
  String? errorMessage;
  // Estado para mostrar el banner
  bool showErrorBanner = false;
  //bool isExpanded = false;
  late List<ValueNotifier<bool>> isExpandedList;
  //Distancia
  bool isDistanceValid = false; // Indica si la distancia está dentro del rango permitido
  double? currentDistance;
  double? plantaLat;
  double? plantaLog;
  bool showDeletePanel = false;
  bool _isMapInteracting = false;



  //Garrafon 20 Lts
  final TextEditingController _vaciosController = TextEditingController();
  final TextEditingController _llenosController = TextEditingController();
  final TextEditingController _liquidosController = TextEditingController();
  final TextEditingController _suciosCteController = TextEditingController();
  final TextEditingController _rotosCteController = TextEditingController();
  final TextEditingController _malSaborController = TextEditingController();
  final TextEditingController _suciosRutaController = TextEditingController();
  final TextEditingController _rotosRutaController = TextEditingController();
  final TextEditingController _aLaParController = TextEditingController();
  final TextEditingController _otrosController = TextEditingController();
  final TextEditingController _comodatoController = TextEditingController();
  final TextEditingController _prestamoController = TextEditingController();
  final TextEditingController _enCamionetaController = TextEditingController();
  //Desmineralizados
  final TextEditingController _llenosDesmineralizadosController = TextEditingController();
  final TextEditingController _liquidosDesmineralizadosController = TextEditingController();
  final TextEditingController _vaciosDesmineralizadosController = TextEditingController();
  final TextEditingController _suciosCteDesmineralizadosController = TextEditingController();
  final TextEditingController _rotosCteDesmineralizadosController = TextEditingController();
  final TextEditingController _suciosRutaDesmineralizadosController = TextEditingController();
  final TextEditingController _rotosRutaDesmineralizadosController = TextEditingController();
  final TextEditingController _prestamoDesmineralizadosController = TextEditingController();
  //Garrafon 11 Lts
  final TextEditingController _vacios11LController = TextEditingController();
  final TextEditingController _llenos11LController = TextEditingController();
  final TextEditingController _liquidos11LController = TextEditingController();
  final TextEditingController _suciosCte11LController = TextEditingController();
  final TextEditingController _rotosCte11LController = TextEditingController();
  final TextEditingController _malSabor11LController = TextEditingController();
  final TextEditingController _suciosRuta11LController = TextEditingController();
  final TextEditingController _rotosRuta11LController = TextEditingController();
  final TextEditingController _aLaPar11LController = TextEditingController();
  final TextEditingController _otros11LController = TextEditingController();
  final TextEditingController _comodato11LController = TextEditingController();
  final TextEditingController _prestamo11LController = TextEditingController();


  @override
  void initState() {
    super.initState();
    // Inicializa la lista de ValueNotifiers
    isExpandedList = List.generate(5, (_) => ValueNotifier<bool>(false));

    _currentLocation = Position(
      altitudeAccuracy: 1,
      headingAccuracy: 1,
      altitude: 1,
      longitude: 0,
      accuracy: 1,
      heading: 1,
      latitude: 0,
      speed: 1,
      speedAccuracy: 1,
      timestamp: DateTime.now(),
    );
    isLoading = false;
    isLoadingOne = false;
    routes = [];
    route = {};
    getDataSolicitud();

    Future.microtask(() {
      print('En la vista');
      Provider.of<ProviderJunghanns>(context, listen: false).refreshList(prefs.token);
      Provider.of<ProviderJunghanns>(context, listen: false).loadLists(prefs.token);
      Provider.of<ProviderJunghanns>(context, listen: false).updateStock();
      Provider.of<ProviderJunghanns>(context, listen: false).loadMissingProducts(prefs.token);

    });
    _refreshTimer();
    _refreshData();
  }

  getDataSolicitud() async {
    setState(() {
      isLoading = true;
    });
    setState(() {
      isLoading = true;
    });
    await getRoutes().then((answer) {
      setState(() {
        isLoading = false;
      });
      if (answer.error) {
        Fluttertoast.showToast(
          msg: answer.message,
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        setState(() {
          routes = List.from(answer.body);
          routes.removeWhere((element) => element["id"]==prefs.idRouteD);
          route = routes.isNotEmpty ? routes.first : {"id": 0};
        });
      }
    });
  }

  Future<void> _refreshTimer() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);

    await provider.fetchValidation();
    provider.getDistancePlanta();
    final filteredData = provider.validationList.where((validation) {
      return validation.status == "P" && validation.valid == "Ruta" &&
          validation.typeValidation == 'T';
    }).toList();
    setState(() {
      if (filteredData.isNotEmpty) {
        specialData = filteredData;
        print('Contenido de specialData (filtrado): $specialData');
      } else {
        specialData = [];
      }
    });
  }
  Future<void> _refreshData() async {
    if (!mounted) return;
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);

    await provider.fetchValidation();

    final filteredData = provider.validationList.where((validation) {
      return validation.status == "P" && validation.valid == "Ruta" &&
          validation.typeValidation == 'T';
    }).toList();

    setState(() {
      if (filteredData.isNotEmpty) {
        specialData = filteredData;
        print('Contenido de specialData (filtrado): $specialData');
      } else {
        specialData = [];
      }
    });
    print('refresh');

    await provider.fetchStockDelivery();
    await provider.updateStock();
    await provider.fetchProducts();
    await provider.fetchProductsStock();

  }

  void validateInputs() {
    setState(() {
      errorMessage = null;
      showErrorBanner = false;

      List<TextEditingController> controllers = [
        _vaciosController,
        _llenosController,
        _suciosCteController,
        _rotosCteController,
        _suciosRutaController,
        _rotosRutaController,
        _aLaParController,
        _otrosController,
        _comodatoController,
        _prestamoController,
        //Desmineralizados
        _llenosDesmineralizadosController,
        _rotosCteDesmineralizadosController,
        _suciosCteDesmineralizadosController,
        _prestamoDesmineralizadosController,
        // 11 L
        _vacios11LController,
        _llenos11LController,
        _rotosCte11LController,
        _suciosCte11LController,
        _malSabor11LController,
        _aLaPar11LController,
        _comodato11LController,
        _prestamo11LController,
      ];

      for (var controller in controllers) {
        int? value = int.tryParse(controller.text);
        if (value != null && value < 0) {
          errorMessage = "Existe un error en la información registrada, no deben existir valores negativos en la entrega. Verifica las ventas capturadas.";
          showErrorBanner = true;
          break;
        }
      }
    });
  }


  Future<void> _deliverProduct(ProviderJunghanns providerJunghanns) async {
    setState(() {
      isButtonDisabled = true;
    });

    setState(() {
      isLoadingOne = true;
    });

    _currentLocation = (await LocationJunny().getCurrentLocation())!;
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    String serial = androidInfo.id ?? "";
    String modelo = androidInfo.model ?? "Desconocido";
    String marca = androidInfo.manufacturer ?? "Desconocido";

    final provider = context.read<ProviderJunghanns>();
    final transfersProducts = provider.transfersProductsList;

    // Variables acumuladoras
    int vacios = 0;
    int liquidos = 0;
    int liquidosDesmineralizado = 0;
    int vacios11L = 0;
    int liquidos11L = 0;

    // Lista de productos que no son de los IDs conocidos
    List<Map<String, dynamic>> missingProducts = [];

    for (var producto in transfersProducts) {
      int id = int.parse(producto.idProduct.toString());
      int cantidad = int.parse(producto.count.toString());

      switch (id) {
        case 21:
          vacios += cantidad;
          break;
        case 22:
          liquidos += cantidad;
          break;
        case 50:
          liquidosDesmineralizado += cantidad;
          break;
        case 125:
          liquidos11L += cantidad;
          break;
        case 136:
          vacios11L += cantidad;
          break;
        default:
          missingProducts.add({
            "id_producto": id,
            "cantidad": cantidad,
          });
      }
    }

    Map<String, dynamic> deliveryData = {
      "garrafon": {
        "vacios": vacios,
        "llenos": 0,
        "liquido_20": liquidos,
      },
      "desmineralizados": {
        "llenos_des": 0,
        "liquido_desmi": liquidosDesmineralizado,
      },
      "garradon11l": {
        "llenos_11": 0,
        "vacios_11": vacios11L,
        "liquido_11": liquidos11L,
      },
      "faltantes": [],
      "otros": missingProducts, // ← ya está en el formato correcto
      "adicionales": [],
      "devoluciones": [],
    };

    int? deliveryId = route['id']; // Extrae un entero del Map

    // Validar si los campos están vacíos y la lista está vacía
    if ((vacios != 0 ||liquidos != 0 ||liquidosDesmineralizado != 0 ||liquidos11L != 0 ||vacios11L != 0 ) || !missingProducts.isEmpty) {
      print('Si se envia con datoss');
    await providerJunghanns.transfersProducts(
      idRuta: prefs.idRouteD,
      lat: _currentLocation.latitude,
      lng: _currentLocation.longitude,
      team: serial,
      brand: marca,
      model: modelo,
      idDestination: deliveryId,
      delivery: deliveryData, provider: providerJunghanns,
    );
    await _refreshData();
    providerJunghanns.fetchValidation(

    );

    final filteredData = providerJunghanns.validationList.where((validation) {
      return validation.status == "P" && validation.valid == "Ruta" && validation.typeValidation == 'T';
    }).toList();

    setState(() {
      if (filteredData.isNotEmpty) {
        specialData = filteredData;
        isDeliverySuccessful = true;
        print('Contenido de specialData (filtrado): $specialData');
      } else {
        specialData = [];
        print('No se encontraron datos que cumplan las condiciones');
      }
    });
    await _refreshTimer();
    setState(() {
      isLoadingOne = false;
    });

    setState(() {
      areFieldsEditable = !isDeliverySuccessful;
    });

    setState(() {
      isButtonDisabled = false;
    });
    } else{

      print('Vacios todos los campos');

      CustomModal.show(
        context: context,
        icon: Icons.cancel_outlined,
        title: "ERROR",
        message: "Datos vacios, verifique la información",
        iconColor: ColorsJunghanns.red,
      );
      setState(() {
        isLoadingOne = false;
      });

      setState(() {
        isButtonDisabled = false;
      });

    }

  }

  void _validateAccessories(ProviderJunghanns providerJunghanns) async {
    setState(() {
      isButtonDisabled = true;
    });
    if (mounted) {
      setState(() {
        isLoadingOne = true;
      });
    }

    await providerJunghanns.fetchValidation();
    await providerJunghanns.validationTranfers();

    if (mounted) {
      setState(() {
        specialData == null;

      });
      final filteredData = providerJunghanns.validationList.where((validation) {
        return validation.status != "P" && validation.valid == "Ruta" && validation.typeValidation == 'T';
      }).toList();

      if (filteredData.isNotEmpty) {
        await providerJunghanns.synchronizeListDelivery();
      }


      await _refreshData();
      isLoadingOne = false;
    }
    setState(() {
      isButtonDisabled = false;
    });
  }

  @override
  void dispose() {
    for (var notifier in isExpandedList) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final providerJunghanns = Provider.of<ProviderJunghanns>(context);
    size = MediaQuery.of(context).size;

    final pendingValidations = providerJunghanns.validationList.where((validation) =>
    validation.status == "P" &&
        validation.valid == "Ruta" &&
        validation.typeValidation == "T").toList();

    double? destinoLat;
    double? destinoLon;

    if (pendingValidations.isNotEmpty) {
      destinoLat = double.tryParse(pendingValidations.first.lat.toString());
      destinoLon = double.tryParse(pendingValidations.first.lon.toString());
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: ColorsJunghanns.whiteJ,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: ColorsJunghanns.whiteJ,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.dark,
              ),
              elevation: 0,
              leading: isLoading
                  ? null
                  : Visibility(
                visible: specialData == null || specialData.isEmpty,
                child: IconButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      // Opcional: puedes navegar a HomePrincipal si no hay más pantallas
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePrincipal()),
                      );
                    }
                  },

                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: ColorsJunghanns.blue,
                  ),
                ),
              ),
            ),
            body: isLoading
                ? const Center(
              child: LoadingJunghanns(),
            )
                : RefreshIndicator(
              onRefresh: _refreshData,
              child: Column(
                children: [
                  providerJunghanns.connectionStatus == 4? const WithoutInternet():providerJunghanns.isNeedAsync?const NeedAsync():Container(),
                  header(),
                  const SizedBox(height: 5),
                  Visibility(
                      visible: prefs.lastRouteUpdate != "",
                      child: Padding(padding: const EdgeInsets.only(left: 15,top: 5,bottom: 5),
                          child:Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Última actualización: ${DateFormat('hh:mm a').format(prefs.lastBitacoraUpdate != "" ? DateTime.parse(prefs.lastBitacoraUpdate) : DateTime.now())}",
                              style: TextStyles.blue13It,
                            ),
                          ))),
                  if (showErrorBanner)
                    Container(
                      width: double.infinity,
                      color: ColorsJunghanns.red,
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          errorMessage ?? '',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 85),
                      child: providerJunghanns.carboyAccesories.isEmpty ||
                          providerJunghanns.carboyAccesories.every((carboy) =>
                          carboy.carboys.empty == 0 &&
                              carboy.carboys.full == 0 &&
                              carboy.carboys.brokenCte == 0 &&
                              carboy.carboys.dirtyCte == 0 &&
                              carboy.carboys.brokenRoute == 0 &&
                              carboy.carboys.dirtyRoute == 0 &&
                              carboy.carboys.aLongWay == 0 &&
                              carboy.carboys.loan == 0 &&
                              carboy.carboys.pLoan == 0 &&
                              carboy.carboys.badTaste == 0)
                          ? empty(context)
                          : NotificationListener<ScrollNotification>(
                        onNotification: (_) => _isMapInteracting ? true : false,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          physics: _isMapInteracting
                              ? const NeverScrollableScrollPhysics()
                              : const AlwaysScrollableScrollPhysics(),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Visibility(
                                visible: routes.isNotEmpty,
                                child: IgnorePointer(
                                  ignoring: specialData != null && specialData!.isNotEmpty,
                                  child: selectMap(
                                    context,
                                        (Map<String, dynamic>? value) {
                                      setState(() {
                                        route = value!;
                                      });
                                    },
                                    routes,
                                    route,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                              child: Listener(
                                onPointerDown: (_) {
                                  setState(() {
                                    _isMapInteracting = true;
                                  });
                                },
                                onPointerUp: (_) {
                                  setState(() {
                                    _isMapInteracting = false;
                                  });
                                },
                                child: MapaUbicacionActual(
                                  destinoLat: destinoLat,
                                  destinoLon: destinoLon,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _sectionWithPlusSimple(
                                    "PRODUCTOS",
                                    Icons.add,
                                    _missingProducts(),
                                        () {
                                      _showAddMissingProductModal(
                                        context: context,
                                        controller: providerJunghanns,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Lógica para decidir qué mostrar
          if (providerJunghanns.carboyAccesories.isNotEmpty &&
              providerJunghanns.carboyAccesories.any((carboy) =>
              carboy.carboys.empty != 0 ||
                  carboy.carboys.full != 0 ||
                  carboy.carboys.brokenCte != 0 ||
                  carboy.carboys.dirtyCte != 0 ||
                  carboy.carboys.brokenRoute != 0 ||
                  carboy.carboys.dirtyRoute != 0 ||
                  carboy.carboys.aLongWay != 0 ||
                  carboy.carboys.loan != 0 ||
                  carboy.carboys.pLoan != 0 ||
                  carboy.carboys.badTaste != 0))
              _buildActionButton(-15),
          /*if (pendingValidations.isNotEmpty) ...[
            // Botón de flechita del lado derecho
            Positioned(
              top: MediaQuery.of(context).size.height * 0.8 - 30,
              right: showDeletePanel ? 100 : 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showDeletePanel = !showDeletePanel;
                  });
                },
                child: Container(
                  height: 80,
                  width: 30,
                  decoration: BoxDecoration(
                    color: ColorsJunghanns.red,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Icon(
                      showDeletePanel ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),

                ),
              ),
            ),

            // Panel flotante del lado derecho
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: MediaQuery.of(context).size.height * 0.8 - 30,
              right: showDeletePanel ? 0 : -100,
              child: Container(
                width: 100,
                height: 80,
                //padding: const EdgeInsets.only(top: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Center(
                  child: SizedBox(
                    width: 60, // ancho total del botón
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsJunghanns.red,
                        padding: EdgeInsets.zero, // 👈 sin padding interno
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        _deletePendingValidation();
                        setState(() {
                          showDeletePanel = false;
                        });
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 45, // 👈 que no sea más grande que el ancho
                      ),
                    ),
                  ),
                ),

              ),
            ),
          ],*/


          Visibility(
            visible: isLoadingOne,
            child: const Center(
              child: LoadingJunghanns(),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction({required String comment,}) async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);

    setState(() {
      isLoadingOne = true; // Muestra el indicador de carga
    });

    final validation = provider.validationList.first;
    final products = validation.idValidation;

    _currentLocation = (await LocationJunny().getCurrentLocation())!;
    provider.deleteValidation(
      idValidacion: products,
      comment: comment,
      lat: _currentLocation.latitude,
      lng: _currentLocation.longitude,

    );

    provider.fetchStockValidation();
    _refreshData();
    provider.synchronizeListDelivery();

    setState(() {
      isLoadingOne = false; // Muestra el indicador de carga
    });
  }

  Widget _buildActionButton(double bottomPadding) {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    final hasData = provider.carboyAccesories.isNotEmpty;

    final isVerifying = specialData != null && specialData!.isNotEmpty;

    final icon = isVerifying
        ? const SpinKitCircle(
      color: ColorsJunghanns.white, size: 24.0,
    )
        : Icon(
      hasData ? Icons.send : Icons.send,
      color: ColorsJunghanns.white, size: 18.0,
    );
    return Stack(
      children: [
        // Botón de Verificar / Enviar
        Positioned(
          bottom: isVerifying ? bottomPadding + 85 : bottomPadding + 40,
          left: 20,
          right: 20,
          child: CustomButtonDelivery(
            onValidate: isButtonDisabled
                ? null
                : (isVerifying
                ? () {
              setState(() {
                areFieldsEditable = false;
              });
              _validateAccessories(provider);
            }
                : hasData
                ? () {
              _deliverProduct(provider);
            }
                : null),
            validateText: isVerifying ? 'VERIFICAR' : 'ENVIAR',
            validateColor: isVerifying
                ? ColorsJunghanns.blueJ
                : (hasData ? ColorsJunghanns.blueJ : ColorsJunghanns.grey),
            icon: icon,
          ),
        ),

        // Botón CANCELAR
        if (isVerifying)
          Positioned(
            bottom: bottomPadding + 22,
            left: 20,
            right: 20,
            child: CustomButtonDelivery(
              onValidate: isButtonDisabled
                  ? null
                  : () {
                setState(() {
                  areFieldsEditable = true;
                });
                showDeclineTrasnfersProduct(
                  context: context,
                  onReject: (comment) {
                    _handleAction(comment: comment);
                  },
                );
              },
              validateText: 'CANCELAR',
              validateColor: ColorsJunghanns.red,
              icon: Icon(
                Icons.cancel,
                color: ColorsJunghanns.white,
                size: 18.0,
              ),
            ),
          ),
      ],
    );
  }


  Widget _sectionWithPlusSimple(
      String title,
      IconData icon,
      Widget content,
      VoidCallback onPressed,
      ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: Icon(icon, color: ColorsJunghanns.blueJ),
                  onPressed: onPressed,
                ),
              ],
            ),
            // Aquí se coloca el contenido debajo del texto y el icono
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: content,
            ),
          ],
        ),
      ),
    );
  }


  void _showAddMissingProductModal({required BuildContext context, required ProviderJunghanns controller}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddTransfersProductModal(controller: controller);
      },
    );
  }

  Widget _missingProducts() {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context);
    final missingProducts = providerJunghanns.transfersProductsList;

    return Column(
      children: [
        if (missingProducts.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: missingProducts.length,
            itemBuilder: (context, index) {
              final product = missingProducts[index];
              return ProductTransfersCard(
                product: product,
              );
            },
          ),
      ],
    );
  }

  Widget header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: ColorsJunghanns.lightBlue,
          padding: EdgeInsets.only(
            right: 15,
            left: 15,
            top: 10,
            bottom: size.height * .01,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Transferencias",
                style: TextStyles.blue27_7,
              ),
            ],
          ),
        ),
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
                      style: JunnyText.green24(FontWeight.w700, 17),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.center,
                  decoration: JunnyDecoration.orange255(8),
                  padding: const EdgeInsets.only(
                    left: 5,
                    right: 5,
                    top: 5,
                    bottom: 5,
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: prefs.nameRouteD,
                          style: TextStyles.white17_5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
