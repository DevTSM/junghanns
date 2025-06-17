import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:provider/provider.dart';

import '../../database/async.dart';
import '../../models/authorization.dart';
import '../../preferences/global_variables.dart';
import '../../services/store.dart';
import '../../styles/text.dart';
import '../../util/location.dart';
import '../../util/navigator.dart';

class ShowCancelAuthorization extends StatefulWidget {
  final String idAuth;
  final String idEmisor;
  const ShowCancelAuthorization({Key? key, required this.idAuth, required this.idEmisor}) : super(key: key);

  @override
  State<ShowCancelAuthorization> createState() => _ShowCancelAuthorizationState();
}

class _ShowCancelAuthorizationState extends State<ShowCancelAuthorization> {
  AuthorizationModel? currentAuth;
  bool loading = true;
  late bool isLoadingOne;
  late List<AuthorizationModel> authList;
  late ProviderJunghanns provider;
  late bool isLoading;


  @override
  void initState() {
    super.initState();
    provider = Provider.of<ProviderJunghanns>(context, listen: false);
    isLoadingOne = false;
    authList = [];
    fetchAuthorization();
  }

  String capitalizeWords(String text) {
    return text
        .toLowerCase()
        .split(' ')
        .map((word) =>
    word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }

  fetchAuthorization() async {
    setState(() {
      loading = true;
    });

    List<AuthorizationModel> authList = [];

    final users = await handler.retrieveUsers();
    for (var user in users) {
      for (var auth in user.auth) {
        auth.setClient = user;

        final exists = authList.any((a) => a.idAuth == auth.idAuth);
        if (!exists) {
          authList.add(auth);
        }
      }
    }

    AuthorizationModel found = authList.firstWhere(
          (auth) => auth.idAuth.toString() == widget.idAuth,
      orElse: () => AuthorizationModel.fromState(),
    );

    if (found.isEmpty()) {
      Position? currentLocation =
      await LocationJunny().getCurrentLocation();
      Async async = Async(provider: provider);

      bool value = await async.initAsync();

      await handler.inserBitacora({
        "lat": currentLocation?.latitude ?? 0,
        "lng": currentLocation?.longitude ?? 0,
        "date": DateTime.now().toString(),
        "status": value ? "1" : "0",
        "desc": jsonEncode({"text": "Sincronizacion desde autorizaciones"})
      });

      setState(() {
        isLoading = false;
      });

      /// Después de sincronizar, intentar obtener de nuevo la autorización
      final usersAfterSync = await handler.retrieveUsers();
      authList.clear();

      for (var user in usersAfterSync) {
        for (var auth in user.auth) {
          auth.setClient = user;

          final exists = authList.any((a) => a.idAuth == auth.idAuth);
          if (!exists) {
            authList.add(auth);
          }
        }
      }

      found = authList.firstWhere(
            (auth) => auth.idAuth.toString() == widget.idAuth,
        orElse: () => AuthorizationModel.fromState(),
      );
    }

    setState(() {
      currentAuth = found;
      loading = false;
    });
  }

  getValidation(AuthorizationModel current, String code) async {
    setState(() {
      isLoadingOne = true;
    });
    await getCancelAuth2({
      "version": 2,
      "id_auth": current.idAuth,
      "emisor": widget.idEmisor,
      "id_user": prefs.nameUserD
    }).then((answer) async {

      setState(() {
        isLoadingOne = false;
      });


      if (answer.error) {
        if (!mounted) return;

        setState(() {
          isLoadingOne = false;
        });

        navigatorKey.currentState?.pop();

        AwesomeDialog(
          context: navigatorKey.currentContext!,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: answer.message,
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: true,
          btnOkText: "Aceptar",
          btnOkOnPress: () {
            setState(() => isLoadingOne = false);
          },
        ).show();
      } else {
        setState(() {
          isLoadingOne = true;
        });
        current.client.delete(current.idAuth);

        await handler.updateUser(current.client).then((value) async {
          if (!mounted) return;

          setState(() {
            isLoadingOne = false;
          });

          navigatorKey.currentState?.pop();

          AwesomeDialog(
            context: navigatorKey.currentContext!,
            dialogType: DialogType.success,
            animType: AnimType.rightSlide,
            title: 'Operación exitosa',
            dismissOnTouchOutside: false,
            btnOkText: "Aceptar",
            btnOkOnPress: () {
            },
          ).show();
        });
      }
    });
  }

  Future<void> _handleButtonPress() async {
    getValidation(currentAuth!, "CONFIRMACION");
  }
  void _handleRejectPress() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: ColorsJunghanns.red,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(3),
                bottomRight: Radius.circular(3),
              ),
            ),
            child: const Text(
              'Solicitar Baja Autorización',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (loading || currentAuth == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  SpinKitCircle(color: ColorsJunghanns.blue),
                  SizedBox(height: 10),
                  Text(
                    'Cargando información...',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: JunnyColor.grey_255,
                            fontSize: 15,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Se ha enviado una solicitud para cancelar una autorización ',
                            ),
                            TextSpan(
                              text: '${currentAuth?.idAuth}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: JunnyColor.grey_255,
                                fontSize: 15,
                              ),
                            ),
                            const TextSpan(
                              text: ' enviada por error. Por favor, revisa la información y acepta la solicitud si estás de acuerdo.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: JunnyColor.grey_255,),
                const SizedBox(height: 10),
                DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  dashPattern: [6, 4],
                  color:  JunnyColor.grey_255,
                  strokeWidth: 1.2,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dirección
                        Row(
                          children: [
                            const Icon(FontAwesomeIcons.userLarge, color: JunnyColor.grey_255, size: 13),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${currentAuth!.idClient}  ${capitalizeWords(currentAuth!.client.name)}",
                                style: JunnyText.grey_255(FontWeight.w400, 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(FontAwesomeIcons.shieldHalved, color: JunnyColor.grey_255, size: 13),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${capitalizeWords(currentAuth!.authText)} ${capitalizeWords(currentAuth!.reason)}",
                                style: JunnyText.grey_255(FontWeight.w400, 12),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(FontAwesomeIcons.shoppingCart, color: JunnyColor.grey_255, size: 13),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AutoSizeText(
                                "${currentAuth!.product.stock} x ${capitalizeWords(currentAuth!.product.description)}",
                                style: JunnyText.grey_255(FontWeight.w400, 12),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(FontAwesomeIcons.dollar, color: JunnyColor.grey_255, size: 13),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AutoSizeText(
                                  "${currentAuth!.product.price.toStringAsFixed(2)}",
                                  style: JunnyText.grey_255(FontWeight.w400, 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoadingOne ? null : _handleButtonPress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsJunghanns.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                    ),
                    child: isLoadingOne
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'ACEPTAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoadingOne ? null : _handleRejectPress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsJunghanns.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                    ),
                    child: const Text(
                      'RECHAZAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
showAuthorizationCancel(BuildContext context, String id, String idEmisor) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        content: ShowCancelAuthorization(idAuth: id, idEmisor: idEmisor),
      ),
    ),
  );

}
