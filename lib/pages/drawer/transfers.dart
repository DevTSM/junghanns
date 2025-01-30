import 'dart:async';
import 'dart:math';

import 'package:device_info/device_info.dart';
import 'package:device_information/device_information.dart';
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
import 'package:mac_address/mac_address.dart';
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

import '../../widgets/card/product_others_card.dart';
import '../../widgets/modal/add_missing_product.dart';

import '../home/home_principal.dart';

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


      final provider = Provider.of<ProviderJunghanns>(context, listen: false);
      //Provider.of<ProviderJunghanns>(context, listen: false).fetchStockDelivery();
      Provider.of<ProviderJunghanns>(context, listen: false).refreshList(prefs.token);
      Provider.of<ProviderJunghanns>(context, listen: false).loadLists(prefs.token);
      Provider.of<ProviderJunghanns>(context, listen: false).updateStock();
      Provider.of<ProviderJunghanns>(context, listen: false).loadMissingProducts(prefs.token);

    });
    _refreshTimer();
    _refreshData();
     _loadSavedValues();


    _llenosController.addListener(_updateLlenos);
    _liquidosController.addListener(_updateLlenos);
    _vaciosController.addListener(_updateVacios);

    _llenos11LController.addListener(_updateLlenos11L);
    _liquidos11LController.addListener(_updateLlenos11L);
    _vacios11LController.addListener(_updateVacios11L);

    _llenosDesmineralizadosController.addListener(_updateLlenosDesmineralizados);
    _liquidosDesmineralizadosController.addListener(_updateLlenosDesmineralizados);

  }

  getDataSolicitud() async {
    setState(() {
      isLoading = true;
    });
    await getProducts().then((answer) {
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
          products = List.from(answer.body);
          product = products.isNotEmpty
              ? products.first
              : {
            "products": {"id": []}
          };
        });
      }
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

  void _updateLlenos() {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context, listen: false);
    final currentStock = providerJunghanns.carboyAccesories;

    if (currentStock.isNotEmpty) {
      int llenosDisponibles = currentStock.first.carboys.full;

      int llenosTransf = int.tryParse(_llenosController.text) ?? 0;
      int liquidos = int.tryParse(_liquidosController.text) ?? 0;


      // Ajustar llenos y líquidos para no exceder los llenos disponibles
      if ((llenosTransf + liquidos) > llenosDisponibles) {
        int excedente = (llenosTransf + liquidos) - llenosDisponibles;

        // Si se modifica "llenosTransf", ajustar "líquidos"
        if (_llenosController.text.isNotEmpty) {
          if (llenosTransf > llenosDisponibles) {
            llenosTransf = llenosDisponibles;
          }
          liquidos = llenosDisponibles - llenosTransf;
        }
        // Si se modifica "líquidos", ajustar "llenosTransf"
        else if (_liquidosController.text.isNotEmpty) {
          if (liquidos > llenosDisponibles) {
            liquidos = llenosDisponibles;
          }
          llenosTransf = llenosDisponibles - liquidos;
        }

        // Actualizar los valores en los controladores
        _llenosController.text = llenosTransf.toString();
        _liquidosController.text = liquidos.toString();
      }
    }
  }

  void _updateVacios() {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context, listen: false);
    final currentStock = providerJunghanns.carboyAccesories;

    if (currentStock.isNotEmpty) {
      int vaciosDisponibles = currentStock.first.carboys.empty;

      int vaciosIngresados = int.tryParse(_vaciosController.text) ?? 0;

      // Verificar si los vacíos ingresados exceden los disponibles
      if (vaciosIngresados > vaciosDisponibles) {
        // Ajustar al máximo permitido
        vaciosIngresados = vaciosDisponibles;
        _vaciosController.text = vaciosIngresados.toString();
      }
    }
  }

  void _updateLlenos11L() {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context, listen: false);
    final currentStock = providerJunghanns.carboyAccesories;

    // Imprimir el valor de currentStock
    print('currentStock: $currentStock');
    if (currentStock.isNotEmpty) {
      int llenosDisponibles = currentStock.first.carboysEleven.full;

      int llenosTransf = int.tryParse(_llenos11LController.text) ?? 0;
      int liquidos = int.tryParse(_liquidos11LController.text) ?? 0;


      // Ajustar llenos y líquidos para no exceder los llenos disponibles
      if ((llenosTransf + liquidos) > llenosDisponibles) {
        int excedente = (llenosTransf + liquidos) - llenosDisponibles;

        // Si se modifica "llenosTransf", ajustar "líquidos"
        if (_llenos11LController.text.isNotEmpty) {
          if (llenosTransf > llenosDisponibles) {
            llenosTransf = llenosDisponibles;
          }
          liquidos = llenosDisponibles - llenosTransf;
        }
        // Si se modifica "líquidos", ajustar "llenosTransf"
        else if (_liquidos11LController.text.isNotEmpty) {
          if (liquidos > llenosDisponibles) {
            liquidos = llenosDisponibles;
          }
          llenosTransf = llenosDisponibles - liquidos;
        }

        // Actualizar los valores en los controladores
        _llenos11LController.text = llenosTransf.toString();
        _liquidos11LController.text = liquidos.toString();
      }
    }
  }

  void _updateVacios11L() {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context, listen: false);
    final currentStock = providerJunghanns.carboyAccesories;

    if (currentStock.isNotEmpty) {
      int vaciosDisponibles = currentStock.first.carboysEleven.empty;

      int vaciosIngresados = int.tryParse(_vacios11LController.text) ?? 0;

      // Verificar si los vacíos ingresados exceden los disponibles
      if (vaciosIngresados > vaciosDisponibles) {
        // Ajustar al máximo permitido
        vaciosIngresados = vaciosDisponibles;
        _vacios11LController.text = vaciosIngresados.toString();
      }
    }
  }

  void _updateLlenosDesmineralizados() {
    final providerJunghanns = Provider.of<ProviderJunghanns>(context, listen: false);
    final currentStock = providerJunghanns.carboyAccesories;

    // Imprimir el valor de currentStock
    print('currentStock dentro de la vista: $currentStock');

    if (currentStock.isNotEmpty) {
      int llenosDisponibles = currentStock.first.demineralizeds.full;

      // Imprimir el valor de llenosDisponibles
      print('llenosDisponibles Dentro d ela vista: $llenosDisponibles');

      int llenosTransf = int.tryParse(_llenosDesmineralizadosController.text) ?? 0;
      int liquidos = int.tryParse(_liquidosDesmineralizadosController.text) ?? 0;


      // Ajustar llenos y líquidos para no exceder los llenos disponibles
      if ((llenosTransf + liquidos) > llenosDisponibles) {
        int excedente = (llenosTransf + liquidos) - llenosDisponibles;

        // Si se modifica "llenosTransf", ajustar "líquidos"
        if (_llenosDesmineralizadosController.text.isNotEmpty) {
          if (llenosTransf > llenosDisponibles) {
            llenosTransf = llenosDisponibles;
          }
          liquidos = llenosDisponibles - llenosTransf;
        }
        // Si se modifica "líquidos", ajustar "llenosTransf"
        else if (_liquidosDesmineralizadosController.text.isNotEmpty) {
          if (liquidos > llenosDisponibles) {
            liquidos = llenosDisponibles;
          }
          llenosTransf = llenosDisponibles - liquidos;
        }

        // Actualizar los valores en los controladores
        _llenosDesmineralizadosController.text = llenosTransf.toString();
        _liquidosDesmineralizadosController.text = liquidos.toString();
      }
    }
  }

  Future<void> _refreshTimer() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);

    await provider.fetchValidation();
    provider.getDistancePlanta();
    _loadSavedValues();
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


  Future<void> _loadSavedValues() async {
    final prefs = await SharedPreferences.getInstance();
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);

    provider.fetchValidation();

    final isPending = provider.validationList.any((validation) =>
    validation.status == "P" &&
        validation.valid == 'Ruta' &&
        validation.typeValidation == 'T');

    if (isPending) {
      setState(() {
        _llenosController.text = prefs.getString('llenos20L') ?? '';
        _liquidosController.text = prefs.getString('liquidos20L') ?? '';
        _vaciosController.text = prefs.getString('vacios20L') ?? '';

        _llenosDesmineralizadosController.text = prefs.getString('llenosDesmi') ?? '';
        _liquidosDesmineralizadosController.text = prefs.getString('liquidosDesmi') ?? '';

        _llenos11LController.text = prefs.getString('llenos11L') ?? '';
        _liquidos11LController.text = prefs.getString('liquidos11L') ?? '';
        _vacios11LController.text = prefs.getString('vacios11L') ?? '';

        // Imprime los valores cargados
        print('Valores cargados:');
        print('llenos20L: ${_llenosController.text}');
        print('liquidos20L: ${_liquidosController.text}');
        print('vacios20L: ${_vaciosController.text}');
        print('llenosDesmi: ${_llenosDesmineralizadosController.text}');
        print('liquidosDesmi: ${_liquidosDesmineralizadosController.text}');
        print('llenos11L: ${_llenos11LController.text}');
        print('liquidos11L: ${_liquidos11LController.text}');
        print('vacios11L: ${_vacios11LController.text}');
      });
    }
  }

  /*Future<void> _loadSavedValues() async {
    final prefs = await SharedPreferences.getInstance();
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    //await provider.fetchStockValidation();

    provider.fetchValidation();

    final isPending = provider.validationList.any((validation) => validation.status == "P" && validation.valid == 'Ruta'&& validation.typeValidation == 'T');

    if (isPending) {
      setState(() {
        _llenosController.text = prefs.getString('llenos20L') ?? '';
        _liquidosController.text = prefs.getString('liquidos20L') ?? '';
        _vaciosController.text = prefs.getString('vacios20L') ?? '';
        //Desmineralizado
        _llenosDesmineralizadosController.text = prefs.getString('llenosDesmi') ?? '';
        _liquidosDesmineralizadosController.text = prefs.getString('liquidosDesmi') ?? '';
        //11 L
        _llenos11LController.text = prefs.getString('llenos11L') ?? '';
        _liquidos11LController.text = prefs.getString('liquidos11L') ?? '';
        _vacios11LController.text = prefs.getString('vacios11L') ?? '';
      });
    }
  }*/
  void _saveValues() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    await provider.fetchValidation();

    final isPending = provider.validationList.any((validation) =>
    validation.status == "P" &&
        validation.valid == 'Ruta' &&
        validation.typeValidation == 'T');

    if (isPending) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('llenos20L', _llenosController.text);
      await prefs.setString('liquidos20L', _liquidosController.text);
      await prefs.setString('vacios20L', _vaciosController.text);

      // Imprime los valores guardados
      print('Valores guardados (20L):');
      print('llenos20L: ${_llenosController.text}');
      print('liquidos20L: ${_liquidosController.text}');
      print('vacios20L: ${_vaciosController.text}');
    }
  }


  /*void _saveValues() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
   // await provider.fetchStockValidation();

    await provider.fetchValidation();

    final isPending = provider.validationList.any((validation) => validation.status == "P" && validation.valid == 'Ruta'&& validation.typeValidation == 'T');

    if (isPending) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('llenos20L', _llenosController.text);
      await prefs.setString('liquidos20L', _liquidosController.text);
      await prefs.setString('vacios20L', _vaciosController.text);
    }
  }*/
  void _saveValuesDesmineralizados() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    await provider.fetchValidation();

    final isPending = provider.validationList.any((validation) =>
    validation.status == "P" &&
        validation.valid == 'Ruta' &&
        validation.typeValidation == 'T');

    if (isPending) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('llenosDesmi', _llenosDesmineralizadosController.text);
      await prefs.setString('liquidosDesmi', _liquidosDesmineralizadosController.text);

      // Imprime los valores guardados
      print('Valores guardados (Desmineralizados):');
      print('llenosDesmi: ${_llenosDesmineralizadosController.text}');
      print('liquidosDesmi: ${_liquidosDesmineralizadosController.text}');
    }
  }

  /*void _saveValuesDesmineralizados() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    //await provider.fetchStockValidation();

    await provider.fetchValidation();

    final isPending = provider.validationList.any((validation) => validation.status == "P" && validation.valid == 'Ruta'&& validation.typeValidation == 'T');

    if (isPending) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('llenosDesmi', _llenosDesmineralizadosController.text);
      await prefs.setString('liquidosDesmi', _liquidosDesmineralizadosController.text);
    }
  }*/
  void _saveValues11L() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    await provider.fetchValidation();

    final isPending = provider.validationList.any((validation) =>
    validation.status == "P" &&
        validation.valid == 'Ruta' &&
        validation.typeValidation == 'T');

    if (isPending) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('llenos11L', _llenos11LController.text);
      await prefs.setString('liquidos11L', _liquidos11LController.text);
      await prefs.setString('vacios11L', _vacios11LController.text);

      // Imprime los valores guardados
      print('Valores guardados (11L):');
      print('llenos11L: ${_llenos11LController.text}');
      print('liquidos11L: ${_liquidos11LController.text}');
      print('vacios11L: ${_vacios11LController.text}');
    }
  }

  /*void _saveValues11L() async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    //await provider.fetchStockValidation();

    await provider.fetchValidation();

    final isPending = provider.validationList.any((validation) => validation.status == "P" && validation.valid == 'Ruta'&& validation.typeValidation == 'T');

    if (isPending) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('llenos11L', _llenos11LController.text);
      await prefs.setString('liquidos11L', _liquidos11LController.text);
      await prefs.setString('vacios11L', _vacios11LController.text);
    }
  }*/

  
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
    String modelo =await DeviceInformation.deviceModel;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String serial = await GetMac.macAddress;
    if(serial.isEmpty||serial.length<2){
      serial=androidInfo.id??"";
    }

    int vacios = int.tryParse(_vaciosController.text) ?? 0;
    int llenos = int.tryParse(_llenosController.text) ?? 0;
    int liquidos = int.tryParse(_liquidosController.text) ?? 0;
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
    int liquidosDesmineralizado = int.tryParse(_liquidosDesmineralizadosController.text) ?? 0;
    int rotosCteDesmineralizado = int.tryParse(_rotosCteDesmineralizadosController.text) ?? 0;
    int suciosCteDesmineralizado = int.tryParse(_suciosCteDesmineralizadosController.text) ?? 0;
    int rotosRutaDesmineralizado = int.tryParse(_rotosCteDesmineralizadosController.text) ?? 0;
    int suciosRutaDesmineralizado = int.tryParse(_suciosRutaDesmineralizadosController.text) ?? 0;
    int prestamoDesmineralizado = int.tryParse(_prestamoDesmineralizadosController.text) ?? 0;

    //11 L
    int vacios11L = int.tryParse(_vacios11LController.text) ?? 0;
    int liquidos11L = int.tryParse(_liquidos11LController.text) ?? 0;
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

    // Estructurar los datos
    Map<String, dynamic> deliveryData = {
      "garrafon": {
        "vacios": vacios,
        "llenos": 0,
        /*"sucios_cte": 0,
        "rotos_cte": 0,
        "sucios_ruta": 0,
        "rotos_ruta": 0,
        "a_la_par": 0,
        "comodato": 0,
        "prestamo": 0,
        "mal_sabor": 0,*/
        "liquido_20": liquidos,
      },
      "desmineralizados": {
        "llenos_des": 0,
        /*"rotos_cte": 0,
        "sucios_cte": 0,
        "roto_ruta_des": 0,
        "sucio_ruta_des": 0,
        "prestamo": 0,*/
        "liquido_desmi": liquidosDesmineralizado,
      },
      "garradon11l": {
        "llenos_11": 0,
        "vacios_11": vacios11L,
        /*"roto_cte_11": 0,
        "sucios_cte_11": 0,
        "roto_ruta_11": 0,
        "sucio_ruta_11": 0,
        "a_la_par_11": 0,
        "comodato_11": 0,
        "prestamo_11": 0,
        "mal_sabor_11": 0,*/
        "liquido_11": liquidos11L
      },
      "faltantes": [],
      "otros": missingProducts,
      "adicionales": [],
      "devoluciones": [],
    };

    int? deliveryId = route['id']; // Extrae un entero del Map

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

    bool isPendiente = providerJunghanns.validationList.any((validation) => validation.status == "P" && validation.valid == 'Ruta' && validation.typeValidation == 'T');

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

    await providerJunghanns.fetchValidation();
    await providerJunghanns.validationTranfers();

    if (mounted) {
      setState(() {
        specialData == null;

      });
      final filteredData = providerJunghanns.validationList.where((validation) {
        return validation.status != "P" && validation.valid == "Ruta" && validation.typeValidation == 'T';
      }).toList();

      bool isRejected = providerJunghanns.validationList.any((validation) => validation.status == "R");
      bool isPendiente = providerJunghanns.validationList.any((validation) => validation.status == "P" && validation.valid == 'Ruta' && validation.typeValidation == 'T');

      if (filteredData.isNotEmpty) {
        _liquidosController.clear();
        _llenosController.clear();
        _vaciosController.clear();
        //Desmineralizado
        _llenosDesmineralizadosController.clear();
        _liquidosDesmineralizadosController.clear();
        //11 L
        _llenos11LController.clear();
        _liquidos11LController.clear();
        _vacios11LController.clear();

      }

      if (isRejected) {
        setState(() {
          areFieldsEditable = true;
          _liquidosController.text = "";
          _llenosController.text = "";
          _vaciosController.text = "";
          //Desmineralizado
          _llenosDesmineralizadosController.text = "";
          _liquidosDesmineralizadosController.text = "";
          //11 L
          _llenos11LController.text = "";
          _liquidos11LController.text = "";
          _vacios11LController.text = "";

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
    _suciosRutaController.dispose();
    _rotosRutaController.dispose();
    _suciosRutaController.dispose();
    _rotosRutaController.dispose();
    _llenosController.removeListener(_updateLlenos);
    _vaciosController.removeListener(_updateVacios);
    _liquidosController.removeListener(_updateLlenos);
    _rotosCteController.dispose();
    _suciosCteController.dispose();
    _aLaParController.dispose();
    _otrosController.dispose();
    _comodatoController.dispose();
    _prestamoController.dispose();
    _enCamionetaController.dispose();
    _malSaborController.dispose();
    //Desmineralizado
    _suciosRutaDesmineralizadosController.dispose();
    _rotosRutaDesmineralizadosController.dispose();
    _llenosDesmineralizadosController.removeListener(_updateLlenosDesmineralizados);
    _liquidosDesmineralizadosController.removeListener(_updateLlenosDesmineralizados);
    _rotosCteDesmineralizadosController.dispose();
    _suciosCteDesmineralizadosController.dispose();
    _prestamoDesmineralizadosController.dispose();
    //11 L
    _suciosRuta11LController.dispose();
    _rotosRuta11LController.dispose();
    _vacios11LController.removeListener(_updateVacios11L);
    _llenos11LController.removeListener(_updateLlenos11L);
    _liquidos11LController.removeListener(_updateLlenos11L);
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
                                : Column(
                              children: [
                                Expanded(
                                  child: ListView(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                        child: /*Visibility(
                                          visible: routes.isNotEmpty,
                                          child: selectMap(context, (Map<String, dynamic>? value) {
                                            setState(() {
                                              route = value!;
                                            });
                                          }, routes, route),
                                        ),*/
                                        Visibility(
                                          visible: routes.isNotEmpty,
                                          child: IgnorePointer(
                                            ignoring: specialData != null && specialData!.isNotEmpty, // Bloquea si el botón está en 'VERIFICAR'
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
                                      _sectionWithPlus(
                                        "GARRAFÓN 20 LITROS",
                                        Icons.add,
                                        _inputFieldsForStock(),
                                            () {
                                          print("Añadir producto con stock");
                                        },
                                        showPlus: false,
                                        index: 1,
                                      ),
                                      _sectionWithPlus(
                                        "DESMINERALIZADOS",
                                        Icons.add,
                                        _inputFieldsForStockDesmineralizados(),
                                            () {
                                          print("Añadir productos desmineralizados");
                                        },
                                        showPlus: false,
                                        index: 2,
                                      ),
                                      _sectionWithPlus(
                                        "GARRAFÓN 11 LITROS",
                                        Icons.add,
                                        _inputFieldsForStock11L(),
                                            () {
                                          print("Añadir productos 11 L");
                                        },
                                        showPlus: false,
                                        index: 3,
                                      ),
                                      _sectionWithPlus(
                                        "ACCESORIOS Y OTROS",
                                        Icons.add,
                                        _missingProducts(),
                                            () {
                                          _showAddMissingProductModal(context: context, controller: providerJunghanns);
                                        },
                                        showPlus: false,
                                        index: 4,
                                      ),
                                    ],
                                  ),
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
      bottom: bottomPadding + 40,
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

        /*textField(_llenosController, 'Llenos', FontAwesomeIcons.droplet),
        const SizedBox(height: 10),*/
        textField(_vaciosController, 'Vacios', FontAwesomeIcons.droplet),
        const SizedBox(height: 10),
        textField(_liquidosController, 'Liquidos', FontAwesomeIcons.droplet),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _inputFieldsForStockDesmineralizados() {
    return Column(
      children: [
        /*textField(_llenosDesmineralizadosController, 'Llenos', FontAwesomeIcons.droplet),
        const SizedBox(height: 10),*/
        textField(_liquidosDesmineralizadosController, 'Liquidos', FontAwesomeIcons.droplet),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _inputFieldsForStock11L() {
    return Column(
      children: [
        /*textField(_llenos11LController, 'Llenos', FontAwesomeIcons.droplet),
        const SizedBox(height: 10),*/
        textField(_vacios11LController, 'Vacios', FontAwesomeIcons.droplet),
        const SizedBox(height: 10),
        textField(_liquidos11LController, 'Liquidos', FontAwesomeIcons.droplet),
        const SizedBox(height: 10),
      ],
    );
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

  void _showAddMissingProductModal({required BuildContext context, required ProviderJunghanns controller}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddOthersProductModal(controller: controller);
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
        //_othersStock(),
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
              'ACCESORIOS Y OTROS',
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
