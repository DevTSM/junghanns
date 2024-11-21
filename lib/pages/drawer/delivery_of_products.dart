import 'dart:async';
import 'dart:math';

import 'package:device_information/device_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  //bool isExpanded = false;
  late List<ValueNotifier<bool>> isExpandedList;
  //Distancia
  bool isDistanceValid = false; // Indica si la distancia está dentro del rango permitido
  double? currentDistance;

  //Garrafon 20 Lts
  final TextEditingController _vaciosController = TextEditingController();
  final TextEditingController _llenosController = TextEditingController();
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
  final TextEditingController _suciosCteDesmineralizadosController = TextEditingController();
  final TextEditingController _rotosCteDesmineralizadosController = TextEditingController();
  final TextEditingController _suciosRutaDesmineralizadosController = TextEditingController();
  final TextEditingController _rotosRutaDesmineralizadosController = TextEditingController();
  final TextEditingController _prestamoDesmineralizadosController = TextEditingController();
  //Garrafon 11 Lts
  final TextEditingController _vacios11LController = TextEditingController();
  final TextEditingController _llenos11LController = TextEditingController();
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
    isExpandedList = List.generate(7, (_) => ValueNotifier<bool>(false));

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
      Provider.of<ProviderJunghanns>(context, listen: false).loadMissingProducts(prefs.token);
      Provider.of<ProviderJunghanns>(context, listen: false).loadAdditionalProducts();
      Provider.of<ProviderJunghanns>(context, listen: false).getDistancePlanta();

    });
    _refreshTimer();
    _refreshData();
    _loadSavedValues();
    funCheckDistance();

    _suciosRutaController.addListener(_updateLlenos);
    _rotosRutaController.addListener(_updateLlenos);

    _suciosRutaDesmineralizadosController.addListener(_updateLlenosDesmineralizados);
    _rotosRutaDesmineralizadosController.addListener(_updateLlenosDesmineralizados);

    _suciosRuta11LController.addListener(_updateLlenos11L);
    _rotosRuta11LController.addListener(_updateLlenos11L);
  }
  //Calcular dstancia
  funCheckDistance() async {
    // Obtener ubicación actual
    _currentLocation = (await LocationJunny().getCurrentLocation())!;

    if (_currentLocation != null) {
      final provider = Provider.of<ProviderJunghanns>(context, listen: false);

      // Obtener distancia de la planta desde el provider
      if (provider.planteDistance.isNotEmpty) {
        final latitude1 = provider.planteDistance[0].lat;
        final longitude1 = provider.planteDistance[0].long;
        final latitude2 = _currentLocation!.latitude!;
        final longitude2 = _currentLocation!.longitude!;
        // Calcular distancia
        double distance = _calculateHaversineDistance(
          latitude1,
          longitude1,
          latitude2,
          longitude2,
        );
        // Actualizar estado
        setState(() {
          currentDistance = distance;
          isDistanceValid = distance <= provider.planteDistance[0].allowedDistance/*100*/;
        });
        print('Distancia ${currentDistance}');
      }
    }
  }

  double _calculateHaversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Radio de la Tierra en mtrs
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Retorna la distancia en mtrs
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
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
    await funCheckDistance();

    if (mounted) {
      _updateControllersWithCurrentStock();
      _updateControllersDesmineralido();
      _updateControllers11L();
    }
  }

  validateSyncDta() {
    setState(()  {

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
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    await provider.fetchStockValidation();
    final isPending = provider.validationList.any((validation) => validation.status == "P" && validation.valid == 'Planta');

    if (isPending) {
      setState(() {
        _rotosRutaController.text = prefs.getString('rotosRuta') ?? '';
        _suciosRutaController.text = prefs.getString('suciosRuta') ?? '';
        //Desmineralizado
        _rotosRutaDesmineralizadosController.text = prefs.getString('rotosRutaDesmineralizados') ?? '';
        _suciosRutaDesmineralizadosController.text = prefs.getString('suciosRutaDesmineralizados') ?? '';
        //11 L
        _rotosRuta11LController.text = prefs.getString('rotosRuta11L') ?? '';
        _suciosRuta11LController.text = prefs.getString('suciosRuta11L') ?? '';
      });
    }
  }

  void _saveValues() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    await provider.fetchStockValidation();

    final isPending = provider.validationList.any((validation) => validation.status == "P" && validation.valid == 'Planta');

    if (isPending) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rotosRuta', _rotosRutaController.text);
      await prefs.setString('suciosRuta', _suciosRutaController.text);
    }
  }
  void _saveValuesDesmineralizados() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    await provider.fetchStockValidation();

    final isPending = provider.validationList.any((validation) => validation.status == "P" && validation.valid == 'Planta');

    if (isPending) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rotosRutaDesmineralizados', _rotosRutaDesmineralizadosController.text);
      await prefs.setString('suciosRutaDesmineralizados', _suciosRutaDesmineralizadosController.text);
    }
  }
  void _saveValues11L() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    await provider.fetchStockValidation();

    final isPending = provider.validationList.any((validation) => validation.status == "P" && validation.valid == 'Planta');

    if (isPending) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rotosRuta11L', _rotosRuta11LController.text);
      await prefs.setString('suciosRuta11L', _suciosRuta11LController.text);
    }
  }

  Future<void> _updateControllersWithCurrentStock() async {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context, listen: false);
    final currentStock = providerJunghanns.carboyAccesories;

    if (currentStock.isNotEmpty) {
      _vaciosController.text = currentStock.first.carboys.empty.toString();
      _llenosController.text = currentStock.first.carboys.full.toString();
      _rotosCteController.text = currentStock.first.carboys.brokenCte.toString();
      _suciosCteController.text = currentStock.first.carboys.dirtyCte.toString();
      _malSaborController.text = currentStock.first.carboys.badTaste.toString();
      _aLaParController.text = currentStock.first.carboys.aLongWay.toString();
      _comodatoController.text = currentStock.first.carboys.loan.toString();
      _prestamoController.text = currentStock.first.carboys.pLoan.toString();
      _enCamionetaController.text = currentStock.first.carboys.full.toString();
      _updateLlenos();
    }
    validateInputs();
  }
  Future<void> _updateControllersDesmineralido() async {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context, listen: false);
    final currentStock = providerJunghanns.demineralizedAccesories;

    if (currentStock.isNotEmpty) {
      _llenosDesmineralizadosController.text = currentStock.first.demineralizeds.full.toString();
      _rotosCteDesmineralizadosController.text = currentStock.first.demineralizeds.brokenCte.toString();
      _suciosCteDesmineralizadosController.text = currentStock.first.demineralizeds.dirtyCte.toString();
      _prestamoDesmineralizadosController.text = currentStock.first.demineralizeds.pLoan.toString();
      _updateLlenosDesmineralizados();
    }
    validateInputs();
  }
  void _updateLlenosDesmineralizados() {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context, listen: false);
    final currentStock = providerJunghanns.demineralizedAccesories;

    if (currentStock.isNotEmpty) {
      int llenos = currentStock.first.demineralizeds.full;

      int rotosRuta = int.tryParse(_rotosRutaDesmineralizadosController.text) ?? 0;
      int suciosRuta = int.tryParse(_suciosRutaDesmineralizadosController.text) ?? 0;

      // Verificar si la suma de rotos y sucios excede los llenos disponibles
      if ((rotosRuta + suciosRuta) > llenos) {
        // Determinar cuánto queda disponible después de asignar a uno de los campos
        int maxPermitido = llenos;

        // Ajustar "rotos" primero si la suma excede los llenos
        if (rotosRuta > maxPermitido) {
          rotosRuta = maxPermitido;
          _rotosRutaDesmineralizadosController.text = rotosRuta.toString();
        }
        maxPermitido -= rotosRuta;

        // Luego ajustar "sucios" con lo que queda disponible
        if (suciosRuta > maxPermitido) {
          suciosRuta = maxPermitido;
          _suciosRutaDesmineralizadosController.text = suciosRuta.toString();
        }
      }

      // Actualizar el valor de llenos, restando los rotos y sucios
      int llenosRestantes = llenos - (rotosRuta + suciosRuta);
      _llenosDesmineralizadosController.text = llenosRestantes.toString();
    }
  }
  void _updateLlenos() {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context, listen: false);
    final currentStock = providerJunghanns.carboyAccesories;

    if (currentStock.isNotEmpty) {
      int llenos = currentStock.first.carboys.full;

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

  Future<void> _updateControllers11L() async {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context, listen: false);
    final currentStock = providerJunghanns.carboyElevenAccesories;

    if (currentStock.isNotEmpty) {
      _vacios11LController.text = currentStock.first.carboysEleven.empty.toString();
      _llenos11LController.text = currentStock.first.carboysEleven.full.toString();
      _rotosCte11LController.text = currentStock.first.carboysEleven.brokenCte.toString();
      _suciosCte11LController.text = currentStock.first.carboysEleven.dirtyCte.toString();
      _malSabor11LController.text = currentStock.first.carboysEleven.badTaste.toString();
      _aLaPar11LController.text = currentStock.first.carboysEleven.aLongWay.toString();
      _comodato11LController.text = currentStock.first.carboysEleven.loan.toString();
      _prestamo11LController.text = currentStock.first.carboysEleven.pLoan.toString();
      _updateLlenos11L();
    }
    validateInputs();
  }
  void _updateLlenos11L() {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context, listen: false);
    final currentStock = providerJunghanns.carboyElevenAccesories;

    if (currentStock.isNotEmpty) {
      int llenos = currentStock.first.carboysEleven.full;

      int rotosRuta = int.tryParse(_rotosRuta11LController.text) ?? 0;
      int suciosRuta = int.tryParse(_suciosRuta11LController.text) ?? 0;

      // Verificar si la suma de rotos y sucios excede los llenos disponibles
      if ((rotosRuta + suciosRuta) > llenos) {
        // Determinar cuánto queda disponible después de asignar a uno de los campos
        int maxPermitido = llenos;

        // Ajustar "rotos" primero si la suma excede los llenos
        if (rotosRuta > maxPermitido) {
          rotosRuta = maxPermitido;
          _rotosRuta11LController.text = rotosRuta.toString();
        }
        maxPermitido -= rotosRuta;

        // Luego ajustar "sucios" con lo que queda disponible
        if (suciosRuta > maxPermitido) {
          suciosRuta = maxPermitido;
          _suciosRuta11LController.text = suciosRuta.toString();
        }
      }

      // Actualizar el valor de llenos, restando los rotos y sucios
      int llenosRestantes = llenos - (rotosRuta + suciosRuta);
      _llenos11LController.text = llenosRestantes.toString();
    }
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
    int malSabor = int.tryParse(_malSaborController.text) ?? 0;

    //Desmineralizado
    int llenosDesmineralizado = int.tryParse(_llenosDesmineralizadosController.text) ?? 0;
    int rotosCteDesmineralizado = int.tryParse(_rotosCteDesmineralizadosController.text) ?? 0;
    int suciosCteDesmineralizado = int.tryParse(_suciosCteDesmineralizadosController.text) ?? 0;
    int rotosRutaDesmineralizado = int.tryParse(_rotosCteDesmineralizadosController.text) ?? 0;
    int suciosRutaDesmineralizado = int.tryParse(_suciosRutaDesmineralizadosController.text) ?? 0;
    int prestamoDesmineralizado = int.tryParse(_prestamoDesmineralizadosController.text) ?? 0;

    //11 L
    int vacios11L = int.tryParse(_vacios11LController.text) ?? 0;
    int llenos11L = int.tryParse(_llenos11LController.text) ?? 0;
    int rotosCte11L = int.tryParse(_rotosCte11LController.text) ?? 0;
    int suciosCte11L = int.tryParse(_suciosCte11LController.text) ?? 0;
    int rotosRuta11L = int.tryParse(_rotosRuta11LController.text) ?? 0;
    int suciosRuta11L = int.tryParse(_suciosRuta11LController.text) ?? 0;
    int aLaPar11L = int.tryParse(_aLaPar11LController.text) ?? 0;
    int comodato11L = int.tryParse(_comodato11LController.text) ?? 0;
    int prestamo11L = int.tryParse(_prestamo11LController.text) ?? 0;
    int malSabor11L = int.tryParse(_malSabor11LController.text) ?? 0;

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

    List<Map<String, dynamic>> returnsProducts = providerJunghanns.returnsWithStock.map((product) {
      return {
        'id_devolucion': product.returns.first.id,
        'cantidad': product.returns.first.count,
        'folio': product.returns.first.folio,
        'producto': product.returns.first.product,
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
        "mal_sabor": malSabor,
      },
      "desmineralizados": {
        "llenos_des": llenosDesmineralizado,
        "rotos_cte": rotosCteDesmineralizado,
        "sucios_cte": suciosCteDesmineralizado,
        "roto_ruta_des": rotosRutaDesmineralizado,
        "sucio_ruta_des": suciosRutaDesmineralizado,
        "prestamo": prestamoDesmineralizado,
      },
      "garradon11l": {
        "llenos_11": llenos11L,
        "vacios_11": vacios11L,
        "roto_cte_11": rotosCte11L,
        "sucios_cte_11": suciosCte11L,
        "roto_ruta_11": rotosRuta11L,
        "sucio_ruta_11": suciosRuta11L,
        "a_la_par_11": aLaPar11L,
        "comodato_11": comodato11L,
        "prestamo_11": prestamo11L,
        "mal_sabor_11": malSabor11L,
      },
      "faltantes": missingProducts,
      "otros": otherProducts,
      "adicionales": additionalProducts,
      "devoluciones": returnsProducts,
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

    final filteredData = providerJunghanns.validationList.where((validation) {
      return validation.status == "P" && validation.valid == "Planta";
    }).toList();

    bool isPendiente = providerJunghanns.validationList.any((validation) => validation.status == "P" && validation.valid == 'Planta');

    if (isPendiente) {
      setState(() {
        _saveValues();
        _saveValuesDesmineralizados();
        _saveValues11L();
      });
    }

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

      bool isRejected = providerJunghanns.validationList.any((validation) => validation.status == "R");
      bool isPendiente = providerJunghanns.validationList.any((validation) => validation.status == "P" && validation.valid == 'Planta');

      if (filteredData.isNotEmpty) {
        _rotosRutaController.clear();
        _suciosRutaController.clear();
        //Desmineralizado
        _rotosRutaDesmineralizadosController.clear();
        _suciosRutaDesmineralizadosController.clear();
        //11 L
        _rotosRuta11LController.clear();
        _suciosRuta11LController.clear();
      }

      if (isRejected) {
        setState(() {
          areFieldsEditable = true;
          _rotosRutaController.text = "";
          _suciosRutaController.text = "";
          //Desmineralizado
          _rotosRutaDesmineralizadosController.text = "";
          _suciosRutaDesmineralizadosController.text = "";
          //11 L
          _rotosRuta11LController.text = "";
          _suciosRuta11LController.text = "";
        });
      }

      if (isPendiente) {
        setState(() {
          _saveValues();
          _saveValuesDesmineralizados();
          _saveValues11L();
        });
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
    _malSaborController.dispose();
    //Desmineralizado
    _suciosRutaDesmineralizadosController.removeListener(_updateLlenosDesmineralizados);
    _rotosRutaDesmineralizadosController.removeListener(_updateLlenosDesmineralizados);
    _llenosDesmineralizadosController.dispose();
    _rotosCteDesmineralizadosController.dispose();
    _suciosCteDesmineralizadosController.dispose();
    _prestamoDesmineralizadosController.dispose();
    //11 L
    _suciosRuta11LController.removeListener(_updateLlenos11L);
    _rotosRuta11LController.removeListener(_updateLlenos11L);
    _vacios11LController.dispose();
    _llenos11LController.dispose();
    _rotosCte11LController.dispose();
    _suciosCte11LController.dispose();
    _malSabor11LController.dispose();
    _aLaPar11LController.dispose();
    _comodato11LController.dispose();
    _prestamo11LController.dispose();
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
    _updateControllersWithCurrentStock();
    _updateControllersDesmineralido();
    _updateControllers11L();


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
                      /*child: providerJunghanns.carboyAccesories.isEmpty*/
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
                              carboy.carboys.badTaste == 0
                          )
                      ? empty(context)
                      :ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        children: [
                          _sectionWithPlus(
                            "GARRAFÓN 20 LITROS",
                            Icons.add,
                            _inputFieldsForStock(),
                                () {
                              print("Añadir producto con stock");
                            },
                            showPlus: false, index: 1,
                          ),
                          _sectionWithPlus(
                            "DESMINERALIZADOS",
                            Icons.add,
                            _inputFieldsForStockDesmineralizados(),
                                () {
                              print("Añadir productos desminalizados");
                            },
                            showPlus: false, index: 2,
                          ),
                          _sectionWithPlus(
                            "GARRAFÓN 11 LITROS",
                            Icons.add,
                            _inputFieldsForStock11L(),
                                () {
                              print("Añadir productos 11 L");
                            },
                            showPlus: false, index: 3,
                          ),
                          _sectionWithPlus(
                            "PRODUCTOS FALTANTES",
                            Icons.add,
                            _missingProducts(),
                                () {
                              _showAddMissingProductModal(context: context, controller: providerJunghanns);
                                },
                            showPlus: false, index: 4,
                          ),
                          _sectionWithPlus(
                            "PRODUCTOS ADICIONALES",
                            Icons.add,
                            _additionalProducts(),
                                () {
                              _showAddAdditionalProductModal(context: context, controller: providerJunghanns);
                            }, showPlus: false, index: 5,
                          ),
                          _sectionWithPlus(
                            "PRESTAMOS Y COMODATOS",
                            Icons.add,
                            _returnsStock(),
                                () {
                              print("Prestamos");
                            },
                            showPlus: false, index: 6,
                          ),
                        ],
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
          // Segunda validación: Si la distancia es válida o no
            if (isDistanceValid)
              _buildActionButton(-15)
            else
              _buttonDistance(-15),
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
  Widget _buttonDistance(double bottomPadding){
    return Positioned(
      bottom: bottomPadding + 35,
      left: 20,
      right: 20,
      child: Padding(
          padding: const EdgeInsets.all(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: ColorsJunghanns.red,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
                child: Text(
                  currentDistance != null
                      ? 'DISTANCIA DE ${currentDistance!.toStringAsFixed(2)} mtrs EXCEDE EL LÍMITE DE ENTREGA !!'
                      : 'Calculando distancia...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ColorsJunghanns.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,

                    decoration: TextDecoration.none,
                  ),
                ),
          ),
        ),
      ),
    );
  }
  Widget _buildActionButton(double bottomPadding) {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
/*provider.updateStock();*/
    final hasData = provider.carboyAccesories.isNotEmpty;

    final icon = specialData != null && specialData!.isNotEmpty
        ? const SpinKitCircle(
      color: ColorsJunghanns.white, size: 24.0,
    )
        : Icon(
      hasData ? Icons.send : Icons.send,
      color: ColorsJunghanns.white, size: 18.0,  // Color del icono de envío
    );
        /*? Icons.check_circle
        : hasData
        ? Icons.send
        : Icons.send;*/

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
        ),
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
        textField(_malSaborController, 'Mal sabor', FontAwesomeIcons.droplet, enabled: false),
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

        /*// Devoluciones
        _returnsStock(),*/
      ],
    );
  }

  Widget _inputFieldsForStockDesmineralizados() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            'EN CAMIONETA',
            style: TextStyles.blue18SemiBoldIt,
          ),
        ),
        textField(_llenosDesmineralizadosController, 'Llenos', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            'POR ENTREGAR',
            style: TextStyles.blue18SemiBoldIt,
          ),
        ),
        textField(_rotosCteDesmineralizadosController, 'Rotos de clientes', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),
        textField(_suciosCteDesmineralizadosController, 'Sucios de clientes', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),
        textField(_rotosRutaDesmineralizadosController, 'Rotos ruta', FontAwesomeIcons.droplet),
        const SizedBox(height: 10),
        textField(_suciosRutaDesmineralizadosController, 'Sucios ruta', FontAwesomeIcons.droplet),
        const SizedBox(height: 10),
        textField(_prestamoDesmineralizadosController, 'Prestamo', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _inputFieldsForStock11L() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            'EN CAMIONETA',
            style: TextStyles.blue18SemiBoldIt,
          ),
        ),
        textField(_llenos11LController, 'Llenos', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            'POR ENTREGAR',
            style: TextStyles.blue18SemiBoldIt,
          ),
        ),
        textField(_vacios11LController, 'Vacios', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),
        textField(_rotosCte11LController, 'Rotos de clientes', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),
        textField(_suciosCte11LController, 'Sucios de clientes', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),
        textField(_malSabor11LController, 'Mal sabor', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),
        textField(_rotosRuta11LController, 'Rotos ruta', FontAwesomeIcons.droplet),
        const SizedBox(height: 10),
        textField(_suciosRuta11LController, 'Sucios ruta', FontAwesomeIcons.droplet),
        const SizedBox(height: 10),
        textField(_aLaPar11LController, 'A la par', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),
        textField(_comodato11LController, 'Comodato', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),
        textField(_prestamo11LController, 'Prestamo', FontAwesomeIcons.droplet, enabled: false),
        const SizedBox(height: 10),
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
          /*Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              'DEVOLUCIONES',
              style: TextStyles.blue18SemiBoldIt,
            ),
          ),*/
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
    // Retorna un mensaje si no hay productos disponibles
    return const Center(
      child: Text(
        "No hay nada que mostrar",
        style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
      ),
    );
    //return SizedBox.shrink();
  }
  Widget _sectionWithPlus(
      String title,
      IconData icon,
      Widget content,
      VoidCallback onPressed, {
        required bool showPlus,
        required int index,
      }) {
    if (index < 0 || index >= isExpandedList.length) {
      return Container();
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            // Si está expandido, no alteres el estado
            if (isExpandedList[index].value) return;
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
              valueListenable: isExpandedList[index],
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
                          isExpandedList[index].value = value;
                        },
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 12),
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
