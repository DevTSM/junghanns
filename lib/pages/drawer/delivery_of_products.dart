import 'dart:async';

import 'package:device_information/device_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:junghanns/widgets/card/product_others_card.dart';
import 'package:junghanns/widgets/card/product_returns_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/button_delivery.dart';
import '../../components/need_async.dart';
import '../../components/without_internet.dart';
import '../../models/customer.dart';
import '../../provider/provider.dart';
import '../../util/location.dart';
import '../../util/navigator.dart';
import '../../widgets/card/product_addditional_card.dart';
import '../../widgets/modal/add_additional_product.dart';
import '../../widgets/modal/add_missing_product.dart';
import '../../widgets/modal/sync_data.dart';
import '../home/home_principal.dart';

class DeliveryOfProducts extends StatefulWidget {
  const DeliveryOfProducts({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DeliveryOfProductsState();
}
class _DeliveryOfProductsState extends State<DeliveryOfProducts> {
  late Size size;
  late bool isLoading;
  late bool isLoadingOne;
  late Position _currentLocation;
  Timer? _timer;
  bool isDeliverySuccessful = false;
  bool isValidating = false;
  bool isButtonDisabled = false;
  bool areFieldsEditable = true; // Nuevo estado para editar los campos
  List specialData = [];
  String? errorMessage;
  // Estado para mostrar el banner
  bool showErrorBanner = false;
  bool isExpanded = false;

  final TextEditingController _vaciosController = TextEditingController();
  final TextEditingController _llenosController = TextEditingController();
  final TextEditingController _suciosCteController = TextEditingController();
  final TextEditingController _rotosCteController = TextEditingController();
  final TextEditingController _suciosRutaController = TextEditingController();
  final TextEditingController _rotosRutaController = TextEditingController();
  final TextEditingController _aLaParController = TextEditingController();
  final TextEditingController _otrosController = TextEditingController();
  final TextEditingController _comodatoController = TextEditingController();
  final TextEditingController _prestamoController = TextEditingController();
  final TextEditingController _enCamionetaController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    Future.microtask(() {
      print('En la vista');
      validateSyncDta();
      final provider = Provider.of<ProviderJunghanns>(context, listen: false);
      Provider.of<ProviderJunghanns>(context, listen: false).fetchStockDelivery();
      Provider.of<ProviderJunghanns>(context, listen: false).refreshList(prefs.token);
      Provider.of<ProviderJunghanns>(context, listen: false).loadLists(prefs.token);
      Provider.of<ProviderJunghanns>(context, listen: false).updateStock();
      /*print('Llamando loadList de l guardado de las listas');*//*
      Provider.of<ProviderJunghanns>(context, listen: false).loadLists();*/
      Provider.of<ProviderJunghanns>(context, listen: false).loadMissingProducts(prefs.token);
      // Imprimir los productos que se han cargado
      print('Productos faltantes cargados: ${provider.missingProducts.length}');
      print('Llamando loadListAdicional de la guardado de las listas');
      Provider.of<ProviderJunghanns>(context, listen: false).loadAdditionalProducts();

    });
    _refreshTimer();
    _refreshData();
    _loadSavedValues();


    _suciosRutaController.addListener(_updateLlenos);
    _rotosRutaController.addListener(_updateLlenos);
  }
  Future<void> _refreshTimer() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    provider.fetchStockValidation();
    final filteredData = provider.validationList.where((validation) {
      return validation.status == "P" && validation.valid == "Planta";
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
    provider.fetchStockValidation();
    final filteredData = provider.validationList.where((validation) {
      return validation.status == "P" && validation.valid == "Planta";
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

    if (mounted) {
      _updateControllersWithCurrentStock();
    }
  }

  validateSyncDta() {
    setState(() {

      final provider = Provider.of<ProviderJunghanns>(context, listen: false);
      final validationList = provider.validationList;

      final hasData = validationList.isNotEmpty && (validationList.first.status != 'P' && validationList.first.valid != 'Planta');

      if (hasData){
        provider.synchronizeListDelivery();
      }
    });
  }

  Future<void> _loadSavedValues() async {
    final prefs = await SharedPreferences.getInstance();
    // Verifica si el estado de la validación está en "P" (pendiente)
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    await provider.fetchStockValidation(); // Asegura que se tiene la última lista de validaciones
    final isPending = provider.validationList.any((validation) => validation.status == "P");

    // Carga los valores solo si la validación está pendiente
    if (isPending) {
      setState(() {
        _rotosRutaController.text = prefs.getString('rotosRuta') ?? '';
        _suciosRutaController.text = prefs.getString('suciosRuta') ?? '';
      });
    }
  }

  void _saveValues() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    await provider.fetchStockValidation();

    final isPending = provider.validationList.any((validation) => validation.status == "P");

    if (isPending) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rotosRuta', _rotosRutaController.text);
      await prefs.setString('suciosRuta', _suciosRutaController.text);
    }
  }

  Future<void> _updateControllersWithCurrentStock() async {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context, listen: false);
    /*await providerJunghanns.fetchStockDelivery();*/
    //await providerJunghanns.updateStock();
    final currentStock = providerJunghanns.carboyAccesories;
    // providerJunghanns.fetchStockDelivery();

    if (currentStock.isNotEmpty) {
      // Asigna los valores actualizados a los controladores
      _vaciosController.text = currentStock.first.carboys.empty.toString();
      _llenosController.text = currentStock.first.carboys.full.toString();
      _rotosCteController.text = currentStock.first.carboys.brokenCte.toString();
      _suciosCteController.text = currentStock.first.carboys.dirtyCte.toString();
      _aLaParController.text = currentStock.first.carboys.aLongWay.toString();
      _comodatoController.text = currentStock.first.carboys.loan.toString();
      _prestamoController.text = currentStock.first.carboys.pLoan.toString();
      _enCamionetaController.text = currentStock.first.carboys.full.toString();
      _updateLlenos();
    }
    validateInputs();
  }
  void _updateLlenos() {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context, listen: false);
    final currentStock = providerJunghanns.carboyAccesories;

    if (currentStock.isNotEmpty) {
      int llenos = currentStock.first.carboys.full;

      // Obtener valores de los controladores
      int rotosRuta = int.tryParse(_rotosRutaController.text) ?? 0;
      int suciosRuta = int.tryParse(_suciosRutaController.text) ?? 0;

      // Verificar si la suma de rotos y sucios excede los llenos disponibles
      if ((rotosRuta + suciosRuta) > llenos) {
        // Determinar cuánto queda disponible después de asignar a uno de los campos
        int maxPermitido = llenos;

        // Ajustar "rotos" primero si la suma excede los llenos
        if (rotosRuta > maxPermitido) {
          rotosRuta = maxPermitido;
          _rotosRutaController.text = rotosRuta.toString();
        }
        maxPermitido -= rotosRuta;

        // Luego ajustar "sucios" con lo que queda disponible
        if (suciosRuta > maxPermitido) {
          suciosRuta = maxPermitido;
          _suciosRutaController.text = suciosRuta.toString();
        }
      }

      // Actualizar el valor de llenos, restando los rotos y sucios
      int llenosRestantes = llenos - (rotosRuta + suciosRuta);
      _llenosController.text = llenosRestantes.toString();
    }
  }
  // Valida si hay valores negativos en los controladores
  void validateInputs() {
    setState(() {
      errorMessage = null;
      showErrorBanner = false; // Resetea el estado del banner

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
    //Loading
    final uiProvider = Provider.of<ProviderJunghanns>(context, listen: false);
    setState(() {
      isLoadingOne = true;
    });

    _currentLocation = (await LocationJunny().getCurrentLocation())!;
    String marca = await DeviceInformation.deviceManufacturer;

    int vacios = int.tryParse(_vaciosController.text) ?? 0;
    int llenos = int.tryParse(_llenosController.text) ?? 0;
    int rotosCte = int.tryParse(_rotosCteController.text) ?? 0;
    int suciosCte = int.tryParse(_suciosCteController.text) ?? 0;
    int rotosRuta = int.tryParse(_rotosRutaController.text) ?? 0;
    int suciosRuta = int.tryParse(_suciosRutaController.text) ?? 0;
    int aLaPar = int.tryParse(_aLaParController.text) ?? 0;
    int comodato = int.tryParse(_comodatoController.text) ?? 0;
    int prestamo = int.tryParse(_prestamoController.text) ?? 0;

    // Obtener listas de productos
    List<Map<String, dynamic>> missingProducts = providerJunghanns.missingProducts.map((product) {
      return {
        "id_producto": product.idProduct,
        "cantidad": product.count,
      };
    }).toList();

    List<Map<String, dynamic>> additionalProducts = providerJunghanns.additionalProducts.map((product) {
      return {
        "id_producto": product.products,
        "cantidad": product.count,
      };
    }).toList();

    List<Map<String, dynamic>> otherProducts = providerJunghanns.stockAccesories.map((product) {
      if (product.others.isNotEmpty) {
        return {
          "id_producto": product.others.first.id,
          "cantidad": product.others.first.count,
        };
      } else {

        return {
          "id_producto": null,
          "cantidad": 0,
        };
      }
    }).toList();

    // Estructurar los datos
    Map<String, dynamic> deliveryData = {
      "garrafon": {
        "vacios": vacios,
        "llenos": llenos,
        "sucios_cte": suciosCte,
        "rotos_cte": rotosCte,
        "sucios_ruta": suciosRuta,
        "rotos_ruta": rotosRuta,
        "a_la_par": aLaPar,
        "comodato": comodato,
        "prestamo": prestamo,
      },
      "faltantes": missingProducts,
      "otros": otherProducts,
      "adicionales": additionalProducts,
    };

    await providerJunghanns.deliverProducts(
      idRuta: prefs.idRouteD,
      lat: _currentLocation.latitude,
      lng: _currentLocation.longitude,
      team: marca,
      delivery: deliveryData, provider: providerJunghanns,
    );

    await _refreshData();
    providerJunghanns.fetchStockValidation();

    // Filtrar los datos según las condiciones especificadas
    final filteredData = providerJunghanns.validationList.where((validation) {
      return validation.status == "P" && validation.valid == "Planta";
    }).toList();

    // Verificar si hay datos filtrados
    setState(() {
      if (filteredData.isNotEmpty) {
        specialData = filteredData;// Asigna los datos filtrados a specialData
        isDeliverySuccessful = true;
        // Imprimir el contenido de specialData para confirmarlo
        print('Contenido de specialData (filtrado): $specialData');
      } else {
        specialData = [];  // Si no hay datos que cumplan las condiciones, asignar un arreglo vacío
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
    await providerJunghanns.fetchStockValidation();
    await providerJunghanns.validationDelivery();
    if (mounted) {
      setState(() {
        specialData == null;

      });
      final filteredData = providerJunghanns.validationList.where((validation) {
        return validation.status != "P" && validation.valid == "Planta";
      }).toList();

      // Verificar si alguna validación fue rechazada
      bool isRejected = providerJunghanns.validationList.any((validation) => validation.status == "R");
      // Verificar si alguna validación esta Pendiente
      bool isPendiente = providerJunghanns.validationList.any((validation) => validation.status == "P");

      // Limpiar los inputs si filteredData tiene elementos
      if (filteredData.isNotEmpty) {
        _rotosRutaController.clear();
        _suciosRutaController.clear();
      }

      // Si hay una validación rechazada, habilitar los campos de entrada
      if (isRejected) {
        setState(() {
          areFieldsEditable = true;// Habilitar el campo nuevamente
          _rotosRutaController.text = "";
          _suciosRutaController.text = "";
        });
      }
// Guardar temporalmente los valores en SharedPreferences al verificar
      // Guardar los valores de rotosRuta y suciosRuta
      if (isPendiente) {
        setState(() {
          _saveValues();
        });
      }


      await _refreshData();
      isLoadingOne = false;
    }
    setState(() {
      isButtonDisabled = false; // Habilitar el botón al finalizar el proceso
    });
  }

  @override
  void dispose() {
    /*_saveValues();*/
    _suciosRutaController.removeListener(_updateLlenos);
    _rotosRutaController.removeListener(_updateLlenos);
    _suciosRutaController.dispose();
    _rotosRutaController.dispose();
    _llenosController.dispose();
    _vaciosController.dispose();
    _rotosCteController.dispose();
    _suciosCteController.dispose();
    _aLaParController.dispose();
    _otrosController.dispose();
    _comodatoController.dispose();
    _prestamoController.dispose();
    _enCamionetaController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final providerJunghanns = Provider.of<ProviderJunghanns>(context);
    size = MediaQuery.of(context).size;
    //Realizando test de esta function
    //providerJunghanns.updateStock();
    _updateControllersWithCurrentStock();


    return GestureDetector(
      onTap: () {
        // Desenfocar el campo de texto al tocar fuera de él
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
                          Navigator.pop(context); // Solo hacer pop si hay algo que cerrar
                        } else {
                          // Opcional: puedes navegar a HomePrincipal si no hay más pantallas
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePrincipal()),
                          );
                        }
                      },

                      /*onPressed: () {
                        Navigator.pop(context);
                      },*/
                      /*Navigator.pop(context)*/
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
                      child: providerJunghanns.stockAccesories.isEmpty
                      ? empty(context)
                      :ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        children: [
                          _sectionWithPlus(
                            "PRODUCTOS EN STOCK",
                            Icons.add,
                            _inputFieldsForStock(),
                                () {
                              print("Añadir producto con stock");
                            },
                            showPlus: false,
                          ),
                          /*_sectionWithPlus(
                            "OTROS PRODUCTOS",
                            Icons.add,
                            _othersStock(),
                                () {
                              print("Añadir producto otros");
                            }, showPlus: false,
                          ),*/
                          _sectionWithPlus(
                            "PRODUCTOS FALTANTES",
                            Icons.add,
                            _missingProducts(),
                                () {
                              _showAddMissingProductModal(context: context, controller: providerJunghanns);
                                },
                            showPlus: false,
                          ),
                          _sectionWithPlus(
                            "PRODUCTOS ADICIONALES",
                            Icons.add,
                            _additionalProducts(),
                                () {
                              _showAddAdditionalProductModal(context: context, controller: providerJunghanns);
                            }, showPlus: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                              ],
                            ),
                ),
          ),
          _buildActionButton(-15),
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
  Widget _buildActionButton(double bottomPadding) {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
/*provider.updateStock();*/
    final hasData = provider.carboyAccesories.isNotEmpty;

    final icon = specialData != null && specialData!.isNotEmpty
        ? Icons.check_circle
        : hasData
        ? Icons.send
        : Icons.send;

    return Positioned(
      bottom: bottomPadding + 35,
      left: 20,
      right: 20,

        child: CustomButtonDelivery(
          onValidate: isButtonDisabled ? null : (specialData != null && specialData!.isNotEmpty
              ? () {
            setState(() {
              areFieldsEditable = false; // Deshabilitar los campos al validar
            });
            _validateAccessories(provider);
          }
              : hasData
              ? () {
            _deliverProduct(provider);
          }
              : null),
          validateText: specialData != null && specialData!.isNotEmpty ? 'VERIFICAR' : 'ENVIAR',
          validateColor: specialData != null && specialData!.isNotEmpty ? ColorsJunghanns.blueJ : (hasData ? ColorsJunghanns.blueJ : ColorsJunghanns.grey),
          icon: icon,
        ), /*CustomButtonDelivery(
          onValidate: () {
            _deliverProduct(provider);
            // Implementar lógica de validación si es necesario
          },
          validateText: 'ENVIAR',
          icon: Icons.send,
        ),*/
    );
  }
  Widget textField(
      TextEditingController controller,
      String hintText,
      IconData iconData, {
        bool enabled = true,
      }) {
    return Center(
      child: Container(
        width: size.width * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          textAlignVertical: TextAlignVertical.center,
          /*enabled: enabled,*/
          enabled: enabled && areFieldsEditable,
          style: TextStyles.blue18SemiBoldIt.copyWith(
            color: enabled ? ColorsJunghanns.blueJ : Colors.grey[400],
          ),
          decoration: InputDecoration(
            labelText: hintText,
            labelStyle: TextStyles.blue18SemiBoldIt.copyWith(
              color: /*enabled*/ (enabled && areFieldsEditable) ? Colors.grey[800] : Colors.grey[600],
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: /*enabled*/(enabled && areFieldsEditable) ? ColorsJunghanns.blueJ : ColorsJunghanns.grey,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:/* enabled */(enabled && areFieldsEditable)? ColorsJunghanns.blueJ : ColorsJunghanns.grey,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ColorsJunghanns.blueJ, width: 2),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(right: 0),
              child: Icon(
                iconData,
                color: ColorsJunghanns.grey,
                size: 24,
              ),
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ),
    );
  }
  Widget _inputFieldsForStock() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            'EN CAMIONETA',
            style: TextStyles.blue18SemiBoldIt,
          ),
        ),
        // Campos de llenos y vacíos deshabilitados
        // textField(_enCamionetaController, 'En camioneta', FontAwesomeIcons.droplet, enabled: false),
        // const SizedBox(height: 10),
        textField(_llenosController, 'Llenos', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            'POR ENTREGAR',
            style: TextStyles.blue18SemiBoldIt,
          ),
        ),
        textField(_vaciosController, 'Vacios', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),
        textField(_rotosCteController, 'Rotos de clientes', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),
        textField(_suciosCteController, 'Sucios de clientes', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),
        textField(_rotosRutaController, 'Rotos ruta', FontAwesomeIcons.droplet),
        const SizedBox(height: 10),
        textField(_suciosRutaController, 'Sucios ruta', FontAwesomeIcons.droplet),
        const SizedBox(height: 10),
        textField(_aLaParController, 'A la par', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),
        textField(_comodatoController, 'Comodato', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),
        textField(_prestamoController, 'Prestamo', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),

        // Otros
        _othersStock(),
        const SizedBox(height: 10),

        // Devoluciones
        _returnsStock(),
      ],
    );
  }

  Widget _othersStock() {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context);
    final productsOthers = providerJunghanns.accessoriesWithStock;

    final availableProducts = productsOthers.isNotEmpty
        ? productsOthers.first.others.where((product) => product.count > 0).toList()
        : [];

    // Solo muestra la sección si hay productos disponibles
    if (availableProducts.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              'OTROS',
              style: TextStyles.blue18SemiBoldIt,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: availableProducts.length,
            itemBuilder: (context, index) {
              final product = availableProducts[index];
              return ProductOthersCard(
                product: product,
              );
            },
          ),
        ],
      );
    }
    return SizedBox.shrink();
  }

  Widget _returnsStock() {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context);
    final productsReturns = providerJunghanns.returnsWithStock;

    final availableProducts = productsReturns.isNotEmpty
        ? productsReturns.first.returns.where((product) => product.count > 0).toList()
        : [];

    // Solo muestra la sección si hay productos disponibles
    if (availableProducts.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              'DEVOLUCIONES',
              style: TextStyles.blue18SemiBoldIt,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: availableProducts.length,
            itemBuilder: (context, index) {
              final product = availableProducts[index];
              return ProductReturnsCard(
                product: product,
              );
            },
          ),
        ],
      );
    }
    return SizedBox.shrink();
  }
  Widget _sectionWithPlus(
      String title,
      IconData icon,
      Widget content,
      VoidCallback onPressed, {
        required bool showPlus,
      }) {
    ValueNotifier<bool> isExpanded = ValueNotifier(false);

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            // Si está expandido, no alteres el estado
            if (isExpanded.value) return;
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: isExpanded,
              builder: (context, expanded, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: expanded ? ColorsJunghanns.blueJ : Colors.transparent,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      child: ExpansionTile(
                        onExpansionChanged: (value) {
                          isExpanded.value = value;
                        },
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 12), // Ajusta el ancho según sea necesario
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: expanded ? ColorsJunghanns.white : ColorsJunghanns.blue,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (showPlus)
                              IconButton(
                                icon: Icon(icon, color: expanded ? ColorsJunghanns.blue : ColorsJunghanns.blueJ),
                                onPressed: onPressed,
                              ),
                          ],
                        ),

                        tilePadding: const EdgeInsets.symmetric(horizontal: 10),
                        collapsedIconColor: ColorsJunghanns.blueJ,
                        iconColor: expanded ? ColorsJunghanns.white : ColorsJunghanns.blue,
                        backgroundColor: Colors.transparent,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: ColorsJunghanns.lightBlue,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorsJunghanns.blueJ.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                width: 3,
                                color: ColorsJunghanns.blueJ,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            child: content,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /*Widget _sectionWithPlus(String title, IconData icon,  Widget content,  VoidCallback onPressed, {required bool showPlus} ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: ColorsJunghanns.blue,
                ),
              ),
              IconButton(
                onPressed: showPlus ? onPressed : null,
                icon: showPlus ? Icon(icon, color: ColorsJunghanns.orange) : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        content,
      ],
    );
  }*/
  void _showAddAdditionalProductModal({required BuildContext context, required ProviderJunghanns controller}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddAdditionalProductModal(controller: controller);
      },
    );
  }
  void _showAddMissingProductModal({required BuildContext context, required ProviderJunghanns controller}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddMissingProductModal(controller: controller);
      },
    );
  }
  Widget _missingProducts() {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context);
    final missingProducts = providerJunghanns.missingProducts;

    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: () {
                _showAddMissingProductModal(context: context, controller: providerJunghanns);
              },
              icon: Icon(Icons.add),
              label: const Text('Agregar', style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsJunghanns.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        if (missingProducts.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: missingProducts.length,
            itemBuilder: (context, index) {
              final product = missingProducts[index];
              return ProductMissingCard(
                product: product,
              );
            },
          ),
      ],
    );
  }

  /*Widget _missingProducts() {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context);
    final missingProducts = providerJunghanns.missingProducts;
    if (missingProducts.isEmpty) {
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: missingProducts.length,
      itemBuilder: (context, index) {
        final product = missingProducts[index];
        return ProductMissingCard(
          product: product,
        );
      },
    );
  }*/
  Widget _additionalProducts() {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context);
    final additionalProducts = providerJunghanns.additionalProducts;

    if (additionalProducts.isEmpty) {
    }
    return Column(
      children:[
        Center(
          child: SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: () {
                _showAddAdditionalProductModal(context: context, controller: providerJunghanns);
              },
              icon: Icon(Icons.add),
              label: const Text('Agregar', style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsJunghanns.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        if (additionalProducts.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: additionalProducts.length,
            itemBuilder: (context, index) {
            final product = additionalProducts[index];
            return AdditionalProductCard(
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
                "Entrega de productos",
                style: TextStyles.blue27_7,
              ),
              /*Text(
                "  Entrega de productos",
                style: TextStyles.green15_4,
              ),*/
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
