import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:junghanns/components/empty/empty.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/widgets/card/product_inventary.dart';
import 'package:provider/provider.dart';

import '../../models/customer.dart';
import '../../provider/provider.dart';
import '../../util/location.dart';
import '../../widgets/button/button_reception.dart';
import '../../widgets/modal/decline.dart';
import '../../widgets/modal/validation_modal.dart';
import '../home/home_principal.dart';

class ReceptionOfProducts extends StatefulWidget {
  const ReceptionOfProducts({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReceptionOfProductsState();
}

class _ReceptionOfProductsState extends State<ReceptionOfProducts> {
  late TextEditingController searchTo;
  late Size size;
  late bool isLoading;
  late bool isLoadingOne;
  late Position _currentLocation;
  List specialData = [];
  Timer? _timer;
  String? errorMessage;
  String? errorMessage1;
  // Estado para mostrar el banner
  bool showErrorBanner = false;
  bool isDistanceValid = false; // Indica si la distancia está dentro del rango permitido
  double? currentDistance;

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
    searchTo = TextEditingController();
    isLoading = false;
    isLoadingOne = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
    Provider.of<ProviderJunghanns>(context, listen: false).getDistancePlanta();
    validateReception();
    funCheckDistance();
  }

  Future<void> _fetchData() async {
    await Provider.of<ProviderJunghanns>(context, listen: false).fetchStockValidation();
    await funCheckDistance();
    await _refreshTimer();
  }

  Future<void> _refreshInventory() async {
    setState(() => isLoadingOne = true);
    await _fetchData();
    await validateReception();
    setState(() => isLoadingOne = false);
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

    /*if (provider.validationList.first.status =='P' && provider.validationList.first.valid == 'Ruta'){
      showReceiptModal(context);
    }*/
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
          isDistanceValid = distance <= provider.planteDistance[0].allowedDistance;
        });
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

  void _handleAction(String status, {required String comment}) async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);

    setState(() {
      isLoadingOne = true; // Muestra el indicador de carga
    });

    final validation = provider.validationList.first;
    final products = validation.idValidation;

    _currentLocation = (await LocationJunny().getCurrentLocation())!;
    provider.receiptionProducts(
      idValidacion: products,
      lat: _currentLocation.latitude,
      lng: _currentLocation.longitude,
      status: status,
      comment: status == 'R' ? comment : null,
    );

    provider.fetchStockValidation();
    provider.synchronizeListDelivery();
    await _refreshInventory();
    await _fetchData();
    await validateReception();

    setState(() {
      isLoadingOne = false; // Muestra el indicador de carga
    });
  }

  validateReception() {
    setState(() {
      errorMessage = null;
      showErrorBanner = false; // Resetea el estado del banner
      final provider = Provider.of<ProviderJunghanns>(context, listen: false);
      final validationList = provider.validationList;

      final hasData = validationList.isNotEmpty && (validationList.first.status != 'P' && validationList.first.valid != 'Planta');

      if (hasData){
        errorMessage = "Se completo la última ";
        errorMessage1 = "recepción con éxito.";
        showErrorBanner = true;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    final validationList = provider.validationList;
    final hasData = validationList.isNotEmpty && (validationList.first.status == 'P' && validationList.first.valid != 'Planta');

    return RefreshIndicator(
      onRefresh: () async{
        await _refreshInventory();
        await _fetchData();
        await validateReception();

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
              leading: IconButton(
                /*onPressed: () => Navigator.pushReplacementNamed(context, '/HomePrincipal')*//*Navigator.pop(context)*//*,*/
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
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: ColorsJunghanns.blue,
                ),
              ),
            ),
            body: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  header(),
                  const SizedBox(height: 20),
                  if (showErrorBanner) ...[
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: ColorsJunghanns.greenJ,
                            width: 0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ColorsJunghanns.greenJ.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: ColorsJunghanns.greenJ,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                errorMessage ?? '',
                                style: const TextStyle(
                                  color: ColorsJunghanns.greenJ,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                errorMessage1 ?? '',
                                style: const TextStyle(
                                  color: ColorsJunghanns.greenJ,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],


                  provider.validationList.isEmpty || provider.validationList.first.valid == 'Planta'|| provider.validationList.first.status == 'A'|| provider.validationList.first.status == 'R'
                      ? empty(context)
                      : GridView.builder(
                    shrinkWrap: true,  // Importante para que funcione dentro de SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(),  // Desactiva el scroll interno
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 cards por fila
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: provider.validationList.first.products.length,
                    itemBuilder: (context, index) {
                      final products = provider.validationList.first.products;
                      return ProductInventaryCardPriority(
                        productCurrent: products[index],
                      );
                    },
                  ),
                  const SizedBox(height: 100), // Añade espacio adicional para permitir el scroll
                ],
              ),
            ),
          ),
          // Aquí se muestra el botón de distancia si la distancia no es válida
          if (hasData && !isDistanceValid)
            _buttonDistance(-15),
          // El botón de Aceptar/ Rechazar solo se muestra si la distancia es válida
          if (isDistanceValid)
            Positioned(
              bottom: 25,
              left: 20,
              right: 20,
              child: hasData
                  ? CustomButtonProduct(
                onValidate: () {
                  _handleAction('A', comment: '');
                },
                onReject: () {
                  showDeclineProduct(
                    context: context,
                    onReject: (comment) {
                      _handleAction('R', comment: comment);
                    },
                  );
                },
                validateText: 'ACEPTAR',
                rejectText: 'RECHAZAR',
                validateColor: ColorsJunghanns.blueJ,
                rejectColor: ColorsJunghanns.red,
                validateIcon: Icons.check_circle,
                rejectIcon: Icons.cancel,
              )
                  : Container(),
            ),
          /*Positioned(
            bottom: 25,
            left: 20,
            right: 20,
            child: hasData
                ? CustomButtonProduct(
              onValidate: () {
                _handleAction('A', comment: '');
              },
              onReject: () {
                showDeclineProduct(
                  context: context,
                  onReject: (comment) {
                    _handleAction('R', comment: comment);
                  },
                );
              },
              validateText: 'ACEPTAR',
              rejectText: 'RECHAZAR',
              validateColor: ColorsJunghanns.blueJ,
              rejectColor: ColorsJunghanns.red,
              validateIcon: Icons.check_circle,
              rejectIcon: Icons.cancel,
            )
                : Container(), // Si no se cumple la condición, no se muestra nada
          ),*/
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
        padding: const EdgeInsets.all(10), // Ajuste de padding externo
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
                  ? 'DISTANCIA DE ${currentDistance!.toStringAsFixed(2)} mtrs EXCEDE EL LÍMITE DE RECEPCIÓN !!'
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
                "Recepción de productos",
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
