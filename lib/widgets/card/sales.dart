import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/components/modal/show_count.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/operation_customer.dart';
import 'package:junghanns/models/sale.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/services/customer.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/util/location.dart';

class SalesCard extends StatelessWidget {
  SaleModel saleCurrent;
  SalesCard({Key? key, required this.saleCurrent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 18, bottom: 10),
      child: Row(
        children: [
          Image.asset(
              "assets/icons/${(saleCurrent.type == "VENTA" || saleCurrent.type == "CTAMOVIL") ? "saleIcon.png" : "withLiquidIcon.png"}"),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                saleCurrent.description,
                style: TextStyles.blue16_7,
              ),
              Visibility(
                  visible: (saleCurrent.type == "VENTA" ||
                      saleCurrent.type == "CTAMOVIL"),
                  child: Row(
                    children: [
                      Text(
                        "Cantidad: ${saleCurrent.count} \$${saleCurrent.amount}",
                        style: TextStyles.grey14_4,
                      ),
                    ],
                  )),
              Text(DateFormat('yyyy-MM-dd | HH:mm').format(saleCurrent.date),
                  style: TextStyles.grey14_4),
            ],
          )),
        ],
      ),
    );
  }
}

class OperationsCard extends StatelessWidget {
  Function update;
  OperationCustomerModel current;
  CustomerModel currentClient;
  bool onlyView;
  OperationsCard({Key? key, required this.current,required this.currentClient,required this.update,this.onlyView=false}) : super(key: key);

  devolucion(BuildContext context, int count) async {
    Position currentLocation = (await LocationJunny().getCurrentLocation())!;
    if (currentLocation.latitude != 0 && currentLocation.longitude != 0) {
      Map<String, dynamic> data = {
        "idDocumento": current.idDocument,
        "tipo":current.type,
        "total":count*(current.total/current.amount),
        "folio":current.folio,
        "idCliente":currentClient.idClient,
        "date":DateTime.now().toString(),
        "desc":current.description,
        "cantidad": count,
        "lat": currentLocation.latitude,
        "lng": currentLocation.longitude,
        "isUpdate": 0,
        "isError": 0
      };
      int id = await handler.insertDevolucion(data);
      await setPrestamoOrComodato({
        "id_documento": current.idDocument,
        "cantidad": count,
        "lat": currentLocation.latitude.toString(),
        "lon": currentLocation.longitude.toString(),
        "id_ruta": prefs.idRouteD
      }).then((answer) async {
        if (answer.error) {
          if (answer.status != 1002) {
            await handler.updateDevolucion({"id": id, "isError": 1}).then(
                (value) async => 
              await handler.inserBitacora({
                "lat": currentLocation.latitude,
                "lng": currentLocation.longitude,
                "date": DateTime.now().toString(),
                "status": "No registrado",
                "desc": jsonEncode({
                  "Error": answer.message,
                  "Operacion": "Devolucion de ${current.type}",
                  "id_Documento": data["idDocumento"]
                })
              }).then((value){
                AwesomeDialog(
                  context: context,
                  dialogType: answer.status == 1002
                    ? DialogType.warning
                    : DialogType.error,
                  animType: AnimType.rightSlide,
                  title: answer.message,
                  dismissOnTouchOutside: false,
                  btnOkText: "Aceptar",
                  btnOkOnPress: () => Navigator.pop(context),
                ).show();
              })
            );
          } else {
            //se elimina la operacion del cliente 
            (currentClient.operation.where((element) => 
              element.folio==current.folio).firstOrNull
              ?? OperationCustomerModel.fromState()).updateCount=current.amount-count;
            //se actualiza en la base local
          await handler.updateUser(currentClient).then((value){
            update();
            AwesomeDialog(
              context: context,
              dialogType:
                  answer.status == 1002 ? DialogType.warning : DialogType.error,
              animType: AnimType.rightSlide,
              title: answer.message,
              dismissOnTouchOutside: false,
              btnOkText: "Aceptar",
              btnOkOnPress: () => Navigator.pop(context),
            ).show();
          });
            
          }
        } else {
          //se elimina la operacion del cliente 
          currentClient.operation.removeWhere((element) => 
            element.folio==current.folio);
          //se actualiza en la base local
          await handler.updateUser(currentClient);
          await handler.updateDevolucion({"id": id, "isUpdate": 1})
              .then((value){
            update();
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.rightSlide,
              title: "Devolucion realizada con exito",
              dismissOnTouchOutside: false,
              btnOkText: "Aceptar",
              btnOkOnPress: () => Navigator.pop(context),
            ).show();
          });
        }
      });
    } else {
      Fluttertoast.showToast(
        msg: "Revisa los permisos de la app",
        timeInSecForIosWeb: 2,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        webShowClose: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: current.typeInt != 3 && !current.isReturned
        ? () => showCount(context, devolucion, current)
        : null,
      child: Container(
        color: current.isReturned && !onlyView
          ? JunnyColor.grey_255.withOpacity(.2)
          : null,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children:[
                onlyView
                  ? Image.asset(
                    "assets/icons/saleIcon.png"
                  )
                  : ClipOval(
                    child: Container(
                      width: 70,
                      height: 70,
                      color: current.isReturned
                        ? JunnyColor.green24
                        : JunnyColor.yellow52,
                      child: const Icon(
                        FontAwesomeIcons.shoppingBasket,
                        color: JunnyColor.white,
                        size: 35
                      ),
                    ),
                ),
                
                Visibility(
                  visible: current.isReturned && !onlyView,
                  child: Container(
                    decoration: JunnyDecoration.blueCEOpacity_5Blue(50)
                      .copyWith(color: JunnyColor.blueA1),
                    child: Text(
                      ' devuelto ',
                      style: JunnyText.bluea4(FontWeight.w300, 11)
                        .copyWith(color: JunnyColor.white),
                    )
                  )
                )
              ]
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  current.isReturned &&!onlyView
                  ? Text(
                    current.description,
                    style: JunnyText.bluea4(FontWeight.w600, 14)
                  )
                  : RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${current.amount} X ",
                          style: JunnyText.bluea4(FontWeight.w700, 16),
                        ),
                        TextSpan(
                          text: current.description,
                          style: JunnyText.bluea4(FontWeight.w600, 14),
                        )
                      ]
                    )
                  ),
                  Text(
                    "P.U: ${checkDouble(current.priceU.toString())} | Total: ${
                      checkDouble(current.total.toString())}",
                    style: JunnyText.grey_255(FontWeight.w400, 14),
                  ),
                  Visibility(
                    visible: !onlyView,
                    child:Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Cant. O: ",
                                style: JunnyText.grey_255(FontWeight.w400, 14)
                                  .copyWith(color: JunnyColor.blueC2)
                              ),
                              TextSpan(
                                text: "${current.amount+current.amountReturned}",
                                style: JunnyText.grey_255(FontWeight.w400, 14)
                              ),
                            ]
                          )
                        ),
                        const SizedBox(width: 10),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Cant. D: ",
                                style: JunnyText.grey_255(FontWeight.w400, 14)
                                  .copyWith(color: JunnyColor.blueC2)
                              ),
                              TextSpan(
                                text: "${current.amountReturned}",
                                style: JunnyText.grey_255(FontWeight.w400, 14)
                              ),
                            ]
                          )
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${DateFormat(onlyView ? 'HH:mm' : 'yyyy-MM-dd | HH:mm')
                      .format(current.date)} hrs. (F${current.folio})",
                    style: JunnyText.grey_255(FontWeight.w400, 14),
                  ),
                ],
              )
            ),
          ],
        ),
      )
    );
  }
}
