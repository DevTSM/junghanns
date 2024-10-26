import 'dart:async';

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
import 'package:junghanns/widgets/modal/delete_reception.dart';
import 'package:provider/provider.dart';

import '../../models/customer.dart';
import '../../provider/provider.dart';
import '../../util/location.dart';
import '../../widgets/button/button_reception.dart';
import '../../widgets/modal/decline.dart';

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
  Timer? _timer;

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
      Provider.of<ProviderJunghanns>(context, listen: false).fetchStockValidation();
    });
  }

  Future<void> _refreshInventory() async {
    Provider.of<ProviderJunghanns>(context, listen: false).fetchStockValidation();
  }

  void _handleAction(String status, {required String comment}) async {
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    final validation = provider.validationList.first;
    final products = validation.idValidation;

    setState(() {
      isLoadingOne = true; // Muestra el indicador de carga
    });

    _currentLocation = (await LocationJunny().getCurrentLocation())!;
    provider.receiptionProducts(
      idValidacion: products,
      lat: _currentLocation.latitude,
      lng: _currentLocation.longitude,
      status: status,
      comment: status == 'R' ? comment : null,
    );

    provider.fetchStockValidation();
    await _refreshInventory();

    setState(() {
      isLoadingOne = false; // Muestra el indicador de carga
    });
  }


  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
    final validationList = provider.validationList;
    final hasData = validationList.isNotEmpty && (validationList.first.status == 'P' && validationList.first.valid != 'Planta');

    return RefreshIndicator(
      onRefresh: _refreshInventory,
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
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: ColorsJunghanns.blue,
                ),
              ),
            ),
            body: SingleChildScrollView(  // Asegura que el contenido se pueda desplazar
              physics: const AlwaysScrollableScrollPhysics(),  // Para permitir siempre el scroll
              child: Column(
                children: [
                  header(),
                  const SizedBox(height: 20),
                  provider.validationList.isEmpty || provider.validationList.first.valid == 'Planta'
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
          Positioned(
            bottom: 25,
            left: 20,
            right: 20,
            child: CustomButtonProduct(
              onValidate: hasData
                  ? () {
                _handleAction('A', comment: '');
              }
                  : () {},
              onReject: hasData
                  ? () {
                showDeclineProduct(
                  context: context,
                  onReject: (comment) {
                    _handleAction('R', comment: comment);
                  },
                );
              }
                  : () {},
              validateText: 'ACEPTAR',
              rejectText: 'RECHAZAR',
              validateColor: hasData ? ColorsJunghanns.blueJ : ColorsJunghanns.grey,
              rejectColor: hasData ? ColorsJunghanns.red : ColorsJunghanns.grey,
              validateIcon: Icons.check_circle,
              rejectIcon: Icons.cancel,
            ),
          ),
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
