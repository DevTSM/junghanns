import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/models/employee.dart';
import 'package:junghanns/models/saleCambaceo.dart';
import 'package:junghanns/models/type_street.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/text.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:provider/provider.dart';

class NewCustomer extends StatefulWidget {
  const NewCustomer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewCustomerState();
}

class _NewCustomerState extends State<NewCustomer> {
  late bool isLoading;
  late ProviderJunghanns provider;
  late Size size;
  late String typeCustomerS;
  late DateTime dateAux, dateBirth;
  //
  late TextEditingController nameC, lastNameC, companyC, contactC;
  late TextEditingController phoneC, emailC, streetC, numEc, numIc;
  late TextEditingController colonyC, townC, codeC, stateC, referenceC;
  //
  late String errLatLng, errName, errLastN, errDateB, errCompany, errContact;
  late String errPhone, errEmail, errTypeStreet, errStreet, errNumE;
  late String errColony, errTown, errState, errCode, errTypeSaleC, errEmployee;
  //
  late TypeOfStreetModel typeStreetS;
  late List<TypeOfStreetModel> typesStreetsList;
  //
  late SaleCambaceoModel typeSaleCs;
  late List<SaleCambaceoModel> typesSalesCList;
  //
  late EmployeeModel employeeS;
  late List<EmployeeModel> employeesList;
  late double lat, lng;
  //
  late int idNewCustomer = 0;
  late String phoneEdit = "";
  String nameCustomerAPI = "";
  late bool isOTP = false;
  TextEditingController pinC = TextEditingController(text: "");
  //

  @override
  void initState() {
    super.initState();
    //
    isLoading = false;
    lat = lng = 0;
    typeCustomerS = "PARTICULAR";
    //
    nameC = TextEditingController();
    lastNameC = TextEditingController();
    phoneC = TextEditingController();
    emailC = TextEditingController();
    streetC = TextEditingController();
    numEc = TextEditingController();
    numIc = TextEditingController();
    colonyC = TextEditingController();
    townC = TextEditingController();
    codeC = TextEditingController();
    stateC = TextEditingController();
    referenceC = TextEditingController();
    companyC = TextEditingController();
    contactC = TextEditingController();
    //
    dateBirth = dateAux = DateTime(1900);
    //
    errLatLng = errName = errLastN = errDateB = errCompany = errContact = "";
    errPhone = errEmail = errTypeStreet = errStreet = errNumE = "";
    errColony = errTown = errState = errCode = errTypeSaleC = errEmployee = "";
    //
    typesStreetsList = [];
    typeStreetS = TypeOfStreetModel.fromState();
    typesSalesCList = [];
    typeSaleCs = SaleCambaceoModel.fromState();
    employeesList = [];
    employeeS = EmployeeModel.fromState();
    //
    getPermission();
    getListTypesOfStreets();
  }

  getPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      provider.permission = true;
    } else {
      provider.permission = false;
    }
  }

  getListTypesOfStreets() {
    Timer(const Duration(milliseconds: 800), () async {
      if (provider.connectionStatus < 4) {
        setState(() {
          isLoading = true;
        });
        await getTypesOfStreets().then((answer) {
          if (answer.error) {
            Fluttertoast.showToast(
              msg: "Sin vialidades",
              timeInSecForIosWeb: 2,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              webShowClose: true,
            );
          } else {
            log("Lista de vialidades");
            answer.body.map((e) {
              typesStreetsList.add(TypeOfStreetModel.fromService(e));
            }).toList();
          }
          getListTypesOfSalesC();
        });
      }
    });
  }

  getListTypesOfSalesC() async {
    await getTypesOfSalesC().then((answer) {
      if (answer.error) {
        Fluttertoast.showToast(
          msg: "Sin tipos de venta cambaceo",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        log("Lista de ventas cambaceo");
        answer.body.map((e) {
          typesSalesCList.add(SaleCambaceoModel.fromService(e));
        }).toList();
      }
      getListEmployees();
    });
  }

  getListEmployees() async {
    await getEmployees().then((answer) {
      if (answer.error) {
        Fluttertoast.showToast(
          msg: "Sin lista de empleados",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        log("Lista de empleados");
        answer.body.map((e) {
          employeesList.add(EmployeeModel.fromService(e));
        }).toList();
      }
      getStatusRecord();
    });
  }

  getStatusRecord() async {
    await getStatusRecordNewCustomer(prefs.idRouteD).then((answer) async {
      if (answer.error) {
        Fluttertoast.showToast(
          msg: answer.message,
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        log("STATUS RECORD");
        if (answer.body["status"] == "awaiting_validation") {
          phoneEdit = answer.body["tel_movil"];
          idNewCustomer =
              int.parse((answer.body["id_cliente_cambaceo"] ?? -1).toString());
          nameCustomerAPI = answer.body["nombre_lead"];
          Position _currentLocation = await Geolocator.getCurrentPosition();
          lat = _currentLocation.latitude;
          lng = _currentLocation.longitude;
          isOTP = true;
        }
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    provider = Provider.of<ProviderJunghanns>(context);
    return Stack(
      children: [
        Container(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 15),
            color: ColorsJunghanns.lightBlue,
            child: formNewCustomer()),
        //
        Visibility(visible: isOTP, child: otpField()),
        //
        Visibility(
            visible: provider.connectionStatus == 4,
            child: Container(
                color: ColorsJunghanns.whiteJ,
                child: Center(
                    child: Text(
                  "Sin conexión a internet",
                  style: TextStyles.redJ24Bold,
                  textAlign: TextAlign.center,
                )))),
        Visibility(visible: isLoading, child: const LoadingJunghanns())
      ],
    );
  }

  Widget formNewCustomer() {
    return SingleChildScrollView(
        padding: const EdgeInsets.only(left: 1, right: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    ))),
            Text(
              "Nuevo cliente",
              style: TextStyles.blueJ22Bold,
            ),
            buttonLocation(),
            //
            typeCustomer(),
            //
            typeCustomerS == "PARTICULAR"
                ? textField(
                    "*Nombre(s)", "Nombre(s)", errName, nameC, false, false, 1)
                : Container(),
            typeCustomerS == "PARTICULAR"
                ? textField("*Apellidos", "Apellidos", errLastN, lastNameC,
                    false, false, 1)
                : Container(),
            typeCustomerS == "PARTICULAR"
                ? buttonField(
                    "*Fecha Nacimiento",
                    dateBirth.year == 1900
                        ? "Fecha Nacimiento"
                        : "${dateBirth.day} / ${dateBirth.month} / ${dateBirth.year}",
                    errDateB != ""
                        ? Decorations.whiteBorder10Red
                        : Decorations.whiteSblackCard,
                    dateBirth.year == 1900
                        ? TextStyles.grey15Itw
                        : TextStyles.blueJ15SemiBold,
                    selectDate,
                    errDateB)
                : Container(),
            //
            typeCustomerS == "EMPRESA"
                ? textField("*Nombre Empresa", "Razón Social", errCompany,
                    companyC, false, false, 1)
                : Container(),
            typeCustomerS == "EMPRESA"
                ? textField("*Contacto", "Contacto", errContact, contactC,
                    false, false, 1)
                : Container(),
            textField("*Télefono Móvil", "555 555 5555", errPhone, phoneC, true,
                true, 1),
            textField("*E-mail", "ejemplo@midominio.com", errEmail, emailC,
                false, false, 1),
            buttonField(
                "*Tipo Vialidad",
                typeStreetS.id == -1
                    ? "Tipo Vialidad"
                    : typeStreetS.description,
                errTypeStreet != ""
                    ? Decorations.whiteBorder10Red
                    : Decorations.whiteSblackCard,
                typeStreetS.id == -1
                    ? TextStyles.grey15Itw
                    : TextStyles.blueJ15SemiBold,
                selectTypeStreet,
                errTypeStreet),
            textField("*Calle", "Calle", errStreet, streetC, false, false, 1),
            textField("*No. Exterior", "No. Exterior", errNumE, numEc, false,
                false, 1),
            textField(
                "No. Interior", "No, Interiro", "", numIc, false, false, 1),
            textField(
                "*Colonia", "Colonia", errColony, colonyC, false, false, 1),
            textField("*Municipio o Alcaldía", "Municipio o Alcaldia", errTown,
                townC, false, false, 1),
            textField("*Estado", "Estado", errState, stateC, false, false, 1),
            textField("*Código Postal", "Código Postal", errCode, codeC, true,
                false, 1),
            textField("Refecencias del domicilio", "Referencias del domicilio",
                "", referenceC, false, false, 5),
            buttonField(
                "*Tipo de Venta",
                typeSaleCs.id == -1 ? "Tipo de Venta" : typeSaleCs.description,
                errTypeSaleC != ""
                    ? Decorations.whiteBorder10Red
                    : Decorations.whiteSblackCard,
                typeSaleCs.id == -1
                    ? TextStyles.grey15Itw
                    : TextStyles.blueJ15SemiBold,
                selectTypeSaleC,
                errTypeSaleC),
            buttonField(
                "*Personal de Alta",
                employeeS.id == -1 ? "Personal de Alta" : employeeS.employee,
                errEmployee != ""
                    ? Decorations.whiteBorder10Red
                    : Decorations.whiteSblackCard,
                employeeS.id == -1
                    ? TextStyles.grey15Itw
                    : TextStyles.blueJ15SemiBold,
                selectEmployee,
                errEmployee),
            buttonContinue()
          ],
        ));
  }

  Widget buttonLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: const EdgeInsets.only(top: 15),
            height: 35,
            child: ButtonJunghanns(
                fun: () {
                  log("Fun update location");
                  funButtonLocation();
                },
                decoration: Decorations.blueBorder12,
                style: TextStyles.white14SemiBold,
                label: "*ACTUALIZAR UBICACIÓN")),
        errLatLng.isNotEmpty
            ? Container(
                padding: const EdgeInsets.only(top: 5, left: 15),
                child: Text(
                  errLatLng,
                  style: errLatLng == "*Coordenadas actualizadas"
                      ? TextStyles.greenJ13N
                      : TextStyles.redJ13N,
                ))
            : Container()
      ],
    );
  }

  funButtonLocation() async {
    setState(() {
      isLoading = true;
    });
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      provider.permission = true;
      Position _currentLocation = await Geolocator.getCurrentPosition();
      lat = _currentLocation.latitude;
      lng = _currentLocation.longitude;
      errLatLng = "*Coordenadas actualizadas";
      Fluttertoast.showToast(
        msg: "Ubicación actualizada con exito",
        timeInSecForIosWeb: 2,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        webShowClose: true,
      );
    } else {
      Fluttertoast.showToast(
        msg: "No has proporcionado permisos de ubicación",
        timeInSecForIosWeb: 2,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        webShowClose: true,
      );
    }
    log("lat: $lat and lng: $lng");
    setState(() {
      isLoading = false;
    });
  }

  Widget typeCustomer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 15, bottom: 2, left: 10),
          child: Text(
            "*Tipo Cliente",
            style: TextStyles.blue15SemiBold,
          ),
        ),
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
            decoration: Decorations.whiteSblackCard,
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  typeCustomerS,
                  style: TextStyles.blueJ15SemiBold,
                )),
                const Icon(
                  FontAwesomeIcons.caretDown,
                  color: ColorsJunghanns.blue,
                )
              ],
            ),
          ),
          onTap: () {
            log("Show types of customers");
            selectTypeCustomer();
          },
        )
      ],
    );
  }

  void selectTypeCustomer() async {
    await showCupertinoModalPopup<int>(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
              actionScrollController: ScrollController(
                  initialScrollOffset: 1.0, keepScrollOffset: true),
              actions: [
                showItemTypeCustomer("PARTICULAR"),
                showItemTypeCustomer("EMPRESA")
              ]);
        });
  }

  Widget showItemTypeCustomer(String typeC) {
    return GestureDetector(
      child: Container(
          padding: const EdgeInsets.fromLTRB(28, 20, 10, 14),
          child: DefaultTextStyle(
              style: TextStyles.blueJ20Bold,
              child: Text(
                typeC,
              ))),
      onTap: () {
        setState(() {
          typeCustomerS = typeC;
        });
        log("TypeC: $typeCustomerS");
        Navigator.pop(context);
      },
    );
  }

  Widget textField(
      String titleT,
      String hintT,
      String errT,
      TextEditingController controller,
      bool isNumber,
      bool isPhone,
      int numLines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 15, bottom: 2, left: 10),
          child: Text(
            titleT,
            style: TextStyles.blue15SemiBold,
          ),
        ),
        //Field
        Container(
            decoration: Decorations.whiteSblackCard,
            child: TextFormField(
                controller: controller,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyles.blueJ15SemiBold,
                keyboardType:
                    isNumber ? TextInputType.number : TextInputType.text,
                maxLines: numLines,
                maxLength: numLines == 5 ? 200 : null,
                inputFormatters:
                    isPhone ? [MaskedInputFormatter("###  ###  ####")] : [],
                decoration: InputDecoration(
                  hintText: hintT,
                  hintStyle: TextStyles.grey15Itw,
                  filled: true,
                  fillColor: ColorsJunghanns.white,
                  contentPadding: const EdgeInsets.only(left: 12, top: 10),
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderSide: errT != ""
                        ? const BorderSide(width: 1, color: Colors.red)
                        : const BorderSide(width: 0, color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        width: 1, color: ColorsJunghanns.blueJ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ))),
        //
        errT.isNotEmpty
            ? Container(
                padding: const EdgeInsets.only(top: 4, left: 15),
                child: Text(
                  errT,
                  style: TextStyles.redJ13N,
                ))
            : Container()
      ],
    );
  }

  selectDate() {
    showCupertinoModalPopup<int>(
        context: context,
        builder: (BuildContext context) {
          return Container(
              height: 255,
              alignment: Alignment.bottomCenter,
              child: Column(children: [
                Container(
                    color: Colors.white,
                    height: 200,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: CupertinoDatePicker(
                            initialDateTime: dateBirth,
                            maximumDate: DateTime.now(),
                            mode: CupertinoDatePickerMode.date,
                            onDateTimeChanged: (date) {
                              dateAux = date;
                            },
                          ),
                        )
                      ],
                    )),
                Container(
                  height: 55,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    borderRadius: BorderRadius.circular(15.0),
                    color: ColorsJunghanns.blueJ,
                    child:
                        const Text('Seleccionar', style: TextStyles.white17_5),
                    onPressed: () {
                      setState(() {
                        dateBirth = dateAux;
                      });
                      Navigator.pop(context);
                    },
                  ),
                )
              ]));
        });
  }

  void selectTypeStreet() async {
    await showCupertinoModalPopup<int>(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
              actionScrollController: ScrollController(
                  initialScrollOffset: 1.0, keepScrollOffset: true),
              actions: typesStreetsList.map((item) {
                return showItemTypeStreet(item);
              }).toList());
        });
  }

  Widget showItemTypeStreet(TypeOfStreetModel ts) {
    return GestureDetector(
      child: Container(
          padding: const EdgeInsets.fromLTRB(28, 20, 10, 14),
          child: DefaultTextStyle(
              style: TextStyles.blueJ20Bold,
              child: Text(
                ts.description,
              ))),
      onTap: () {
        setState(() {
          typeStreetS = ts;
        });
        log("Type Street: ${typeStreetS.description}");
        Navigator.pop(context);
      },
    );
  }

  void selectTypeSaleC() async {
    await showCupertinoModalPopup<int>(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
              actionScrollController: ScrollController(
                  initialScrollOffset: 1.0, keepScrollOffset: true),
              actions: typesSalesCList.map((item) {
                return showItemTypeSaleC(item);
              }).toList());
        });
  }

  Widget showItemTypeSaleC(SaleCambaceoModel tsc) {
    return GestureDetector(
      child: Container(
          padding: const EdgeInsets.fromLTRB(28, 20, 10, 14),
          child: DefaultTextStyle(
              style: TextStyles.blueJ20Bold,
              child: Text(
                tsc.description,
              ))),
      onTap: () {
        setState(() {
          typeSaleCs = tsc;
        });
        log("Type Sale C: ${typeSaleCs.description}");
        Navigator.pop(context);
      },
    );
  }

  Widget buttonField(String titleB, String textB, BoxDecoration decoB,
      TextStyle textSB, Function funB, String errB) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 15, bottom: 2, left: 10),
          child: Text(
            titleB,
            style: TextStyles.blue15SemiBold,
          ),
        ),
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
            decoration: decoB,
            child: Row(
              children: [
                Expanded(child: Text(textB, style: textSB)),
                const Icon(
                  FontAwesomeIcons.caretDown,
                  color: ColorsJunghanns.blue,
                )
              ],
            ),
          ),
          onTap: () {
            log("Show Picker");
            funB();
          },
        ),
        errB.isNotEmpty
            ? Container(
                padding: const EdgeInsets.only(top: 4, left: 15),
                child: Text(
                  errB,
                  style: TextStyles.redJ13N,
                ))
            : Container()
      ],
    );
  }

  void selectEmployee() async {
    await showCupertinoModalPopup<int>(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
              actionScrollController: ScrollController(
                  initialScrollOffset: 1.0, keepScrollOffset: true),
              actions: employeesList.map((item) {
                return showItemEmployee(item);
              }).toList());
        });
  }

  Widget showItemEmployee(EmployeeModel emp) {
    return GestureDetector(
      child: Container(
          padding: const EdgeInsets.fromLTRB(28, 20, 10, 14),
          child: DefaultTextStyle(
              style: TextStyles.blueJ20Bold,
              child: Text(
                emp.employee,
              ))),
      onTap: () {
        setState(() {
          employeeS = emp;
        });
        log("Employee: ${emp.employee}");
        Navigator.pop(context);
      },
    );
  }

  Widget buttonContinue() {
    return Container(
      height: 45,
      margin: const EdgeInsets.only(top: 24),
      child: ButtonJunghanns(
          fun: () {
            log("Button Continue");
            if (provider.connectionStatus < 4) {
              setState(() {
                if (checkValidField()) {
                  showConfirmR();
                } else {
                  Fluttertoast.showToast(
                    msg: "Error - revisa la información proporcinada",
                    timeInSecForIosWeb: 2,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    webShowClose: true,
                  );
                }
              });
            } else {
              Fluttertoast.showToast(
                msg: "Sin conexión a internet",
                backgroundColor: Colors.red,
                timeInSecForIosWeb: 2,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                webShowClose: true,
              );
            }
          },
          decoration: Decorations.greenJCardB30,
          style: TextStyles.white17_5,
          label: "REGISTRAR"),
    );
  }

  showConfirmR() {
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
                children: [textConfirm(), textPhoneConfirm(), buttomsConfirm()],
              ),
            ),
          );
        });
  }

  Widget textConfirm() {
    return Container(
        alignment: Alignment.center,
        child: DefaultTextStyle(
            style: TextStyles.blueJ20Bold, child: const Text("CONFIRMACIÓN")));
  }

  Widget textPhoneConfirm() {
    return Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          children: [
            DefaultTextStyle(
                style: TextStyles.blueJ218R,
                child: const Text(
                  "Registrar y enviar código de verificación a",
                  textAlign: TextAlign.center,
                )),
            DefaultTextStyle(
                style: TextStyles.greenJ20Bold,
                textAlign: TextAlign.center,
                child: Text(
                  typeCustomerS == "PARTICULAR"
                      ? "${nameC.text} ${lastNameC.text}"
                      : companyC.text,
                )),
            DefaultTextStyle(
                style: TextStyles.greenJ20Bold,
                child: Text(
                  phoneC.text,
                )),
          ],
        ));
  }

  Widget buttomsConfirm() {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buttomConfirm(
              "Si",
              () => () async {
                    Navigator.pop(context);
                    funButtonContinue();
                  },
              Decorations.blueBorder12),
          buttomConfirm(
              "No",
              () => () {
                    Navigator.pop(context);
                  },
              Decorations.redCard),
        ],
      ),
    );
  }

  Widget buttomConfirm(String op, Function fun, BoxDecoration deco) {
    return GestureDetector(
      onTap: fun(),
      child: Container(
          alignment: Alignment.center,
          width: size.width * 0.22,
          height: size.width * 0.11,
          decoration: deco,
          child: DefaultTextStyle(
              style: TextStyles.white18SemiBoldIt,
              child: Text(
                op,
              ))),
    );
  }

  bool checkValidField() {
    bool isValid = true;

    if (lat == 0 && lng == 0) {
      errLatLng = "*Coordenadas obligatorias";
      isValid = false;
    } else {
      errLatLng = "*Coordenadas actualizadas";
    }

    if (typeCustomerS == "PARTICULAR" && nameC.text.isEmpty) {
      errName = "*Campo obligatorio";
      isValid = false;
    } else {
      errName = "";
    }

    if (typeCustomerS == "PARTICULAR" && lastNameC.text.isEmpty) {
      errLastN = "*Campo obligatorio";
      isValid = false;
    } else {
      errLastN = "";
    }

    if (typeCustomerS == "PARTICULAR" && dateBirth.year == 1900) {
      errDateB = "*Campo obligatorio";
      isValid = false;
    } else {
      errDateB = "";
    }

    if (typeCustomerS == "EMPRESA" && companyC.text.isEmpty) {
      errCompany = "*Campo obligatorio";
      isValid = false;
    } else {
      errCompany = "";
    }

    if (typeCustomerS == "EMPRESA" && contactC.text.isEmpty) {
      errContact = "*Campo obligatorio";
      isValid = false;
    } else {
      errContact = "";
    }

    if (phoneC.text.isEmpty) {
      errPhone = "*Campo obligatorio";
      isValid = false;
    } else {
      if (phoneC.text.length < 14) {
        errPhone = "*Télefono incompleto";
        isValid = false;
      } else {
        errPhone = "";
      }
    }

    if (emailC.text.isEmpty) {
      errEmail = "*Campo obligatorio";
      isValid = false;
    } else {
      errEmail = "";
    }

    if (typeStreetS.id == -1) {
      errTypeStreet = "*Campo obligatorio";
      isValid = false;
    } else {
      errTypeStreet = "";
    }

    if (streetC.text.isEmpty) {
      errStreet = "*Campo obligatorio";
      isValid = false;
    } else {
      errStreet = "";
    }

    if (numEc.text.isEmpty) {
      errNumE = "*Campo obligatorio";
      isValid = false;
    } else {
      errNumE = "";
    }

    if (colonyC.text.isEmpty) {
      errColony = "*Campo obligatorio";
      isValid = false;
    } else {
      errColony = "";
    }

    if (townC.text.isEmpty) {
      errTown = "*Campo obligatorio";
      isValid = false;
    } else {
      errTown = "";
    }

    if (stateC.text.isEmpty) {
      errState = "*Campo obligatorio";
      isValid = false;
    } else {
      errState = "";
    }

    if (codeC.text.isEmpty) {
      errCode = "*Campo obligatorio";
      isValid = false;
    } else {
      errCode = "";
    }

    if (typeSaleCs.id == -1) {
      errTypeSaleC = "*Campo obligatorio";
      isValid = false;
    } else {
      errTypeSaleC = "";
    }

    if (employeeS.id == -1) {
      errEmployee = "*Campo obligatorio";
      isValid = false;
    } else {
      errEmployee = "";
    }

    return isValid;
  }

  funButtonContinue() async {
    log("FUN BUTTON CONTINUE");
    Map<String, dynamic> data = {};
    String tC = typeCustomerS.substring(0, 1);
    phoneEdit = phoneC.text.replaceAll(" ", "");
    log("Tipo usuario : $tC");

    if (tC == "P") {
      data = {
        "action": "create",
        "id_ruta": prefs.idRouteD,
        "envio_sms": true,
        "data": {
          "tipo": tC,
          "nombre": nameC.text,
          "apellidos": lastNameC.text,
          "fecha_nacimiento": DateFormat('yyyy-MM-dd').format(dateBirth),
          "tel_movil": phoneEdit,
          "email": emailC.text,
          "id_vialidad": typeStreetS.id,
          "calle": streetC.text,
          "no_ext": numEc.text,
          "no_int": numIc.text,
          "colonia": colonyC.text,
          "mun_alc": townC.text,
          "estado": stateC.text,
          "codigo_postal": codeC.text,
          "lat": lat.toString(),
          "lon": lng.toString(),
          "referencia_domicilio": referenceC.text,
          "id_empleado": employeeS.id,
          "tipo_venta": typeSaleCs.id
        }
      };
    } else {
      data = {
        "action": "create",
        "id_ruta": prefs.idRouteD,
        "envio_sms": true,
        "data": {
          "tipo": tC,
          "razon_social": companyC.text,
          "contacto": contactC.text,
          "tel_movil": phoneEdit,
          "email": emailC.text,
          "id_vialidad": typeStreetS.id,
          "calle": streetC.text,
          "no_ext": numEc.text,
          "no_int": numIc.text,
          "colonia": colonyC.text,
          "mun_alc": townC.text,
          "estado": stateC.text,
          "codigo_postal": codeC.text,
          "lat": lat.toString(),
          "lon": lng.toString(),
          "referencia_domicilio": referenceC.text,
          "id_empleado": employeeS.id,
          "tipo_venta": typeSaleCs.id
        }
      };
    }

    log("INFO NEW CUSTOMER: $data");

    await postNewCustomer(data).then((answer) {
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
          isOTP = true;
        });
        Fluttertoast.showToast(
          msg: "Se envió código de verificación",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
        idNewCustomer = int.parse((answer.body["id"] ?? -1).toString());
        log(idNewCustomer.toString());
      }
    });
  }

  Widget otpField() {
    return Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
            child: Container(
          padding: const EdgeInsets.all(12),
          width: size.width * .8,
          height: size.height * .36,
          decoration: Decorations.whiteS1Card,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //Info Phone
              Column(
                children: [
                  Container(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        "Ingresa el código de verificación enviado a",
                        style: TextStyles.blueJ215R,
                        textAlign: TextAlign.center,
                      )),
                  Text(
                    nameCustomerAPI == ""
                        ? typeCustomerS == "PARTICULAR"
                            ? "${nameC.text} ${lastNameC.text}"
                            : companyC.text
                        : nameCustomerAPI,
                    style: TextStyles.greenJ20Bold,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    phoneC.text.isEmpty ? phoneEdit : phoneC.text,
                    style: TextStyles.greenJ20Bold,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              //OTP Field
              PinCodeTextField(
                maxLength: 6,
                pinBoxRadius: 10,
                controller: pinC,
                pinBoxBorderWidth: 3,
                pinBoxWidth: size.width * 0.1,
                pinBoxHeight: size.width * 0.1,
                defaultBorderColor: ColorsJunghanns.blueJ3,
                hasTextBorderColor: ColorsJunghanns.blueJ,
                onDone: (value) {
                  log("Fun OTP");
                  funCheckOTP(value);
                },
              ),
              //Buttons Resend and Cancel
              Container(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 8),
                        width: size.width * 0.33,
                        height: 35,
                        child: ButtonJunghanns(
                            fun: () {
                              log("RESEND CODE");
                              funResendCode();
                            },
                            decoration: Decorations.blueJ2Card,
                            style: TextStyles.white15R,
                            label: "Reenviar código"),
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 8),
                        width: size.width * 0.33,
                        height: 35,
                        child: ButtonJunghanns(
                            fun: () {
                              log("CANCEL CODE");
                              funCancelCode();
                            },
                            decoration: Decorations.redCard,
                            style: TextStyles.white15R,
                            label: "Rechazar"),
                      ),
                    ],
                  ))
            ],
          ),
        )));
  }

  funCheckOTP(String code) async {
    Map<String, dynamic> data = {
      "id_lead": idNewCustomer,
      "id_ruta": prefs.idRouteD,
      "lat": lat.toString(),
      "lon": lng.toString(),
      "otp": code
    };

    await putValidateOTP(data).then((answer) {
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
          isOTP = false;
          pinC.text = "";
          errLatLng = "";
          lat = lng = 0;
          nameC.text = "";
          lastNameC.text = "";
          dateBirth = DateTime(1900);
          companyC.text = "";
          contactC.text = "";
          phoneC.text = "";
          emailC.text = "";
          typeStreetS = TypeOfStreetModel.fromState();
          streetC.text = "";
          numEc.text = "";
          numIc.text = "";
          colonyC.text = "";
          townC.text = "";
          stateC.text = "";
          codeC.text = "";
          referenceC.text = "";
          typeSaleCs = SaleCambaceoModel.fromState();
          employeeS = EmployeeModel.fromState();
        });
        showOTPsuccess();
      }
    });
  }

  showOTPsuccess() {
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
                children: [
                  Container(
                      alignment: Alignment.center,
                      child: DefaultTextStyle(
                          style: TextStyles.blueJ20Bold,
                          child: const Text("Código validado con exito"))),
                  Container(
                    padding: const EdgeInsets.only(top: 12, bottom: 18),
                    child: const Icon(
                      FontAwesomeIcons.checkCircle,
                      size: 50,
                      color: ColorsJunghanns.greenJ,
                    ),
                  ),
                  buttomConfirm(
                      "Aceptar",
                      () => () async {
                            Navigator.pop(context);
                          },
                      Decorations.greenJCard),
                ],
              ),
            ),
          );
        });
  }

  funResendCode() async {
    log("FUN RESEND CODE");

    Map<String, dynamic> data = {
      "id_lead": idNewCustomer,
      "id_ruta": prefs.idRouteD,
      "lat": lat.toString(),
      "lon": lng.toString(),
      "envio_sms": true
    };

    log("INFO RESEND: $data");

    await postResendCode(data).then((answer) {
      if (answer.error) {
        Fluttertoast.showToast(
          msg: answer.message,
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Se reenvió el código de verificación",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
        idNewCustomer = int.parse((answer.body["id"] ?? -1).toString());
        log(idNewCustomer.toString());
      }
    });
  }

  funCancelCode() async {
    log("FUN RESEND CODE");

    Map<String, dynamic> data = {
      "id": idNewCustomer,
    };

    log("INFO RESEND: $data");

    await putCancelOTP(data).then((answer) {
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
          isOTP = false;
          pinC.text = "";
        });
        Fluttertoast.showToast(
          msg: "Se canceló el registro",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
      }
    });
  }
}
