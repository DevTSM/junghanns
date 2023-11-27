import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/modal/picker.dart';
import 'package:junghanns/components/modal/select.dart';
import 'package:junghanns/components/modal/showlocation.dart';
import 'package:junghanns/components/modal/yes_not.dart';
import 'package:junghanns/components/select.dart';
import 'package:junghanns/components/textfield/text_field.text.dart';
import 'package:junghanns/models/customer.dart';
import 'package:junghanns/models/employee.dart';
import 'package:junghanns/models/saleCambaceo.dart';
import 'package:junghanns/models/type_street.dart';
import 'package:junghanns/preferences/global_variables.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/services/catalogue.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:provider/provider.dart';

class NewCustomer extends StatefulWidget {
  const NewCustomer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewCustomerState();
}

class _NewCustomerState extends State<NewCustomer> {
  late bool isLoading,isDate,isFracc,isOTP,isLoadingSchedule;
  late int idNewCustomer;
  late double lat, lng;
  late String errLatLng, errName, errLastN, errDateB, errCompany, errContact, 
    errPhone, errEmail, errTypeStreet, errStreet, errNumE, errColony, errTown,
    errState, errCode, errTypeSaleC, errEmployee, errAdults, 
    errChildren, errMaterno, errFracc, nameCustomerAPI;
  late DateTime dateBirth;
  late NewTypeUser typeLeed;
  late EmployeeModel employeeS;
  late TypeOfStreetModel typeStreetS;
  late SaleCambaceoModel typeSaleCs;
  late Map<String, dynamic> schedule,chanelValidation,gender,scheduleOther;
  late List<EmployeeModel> employeesList;
  late List<TypeOfStreetModel> typesStreetsList;
  late List<SaleCambaceoModel> typesSalesCList;
  late List<Map<String, dynamic>> chanels,schedules,genders,typesUser;
  late TextEditingController nameC, lastNameC, lastNameMC, companyC, contactC, phoneC,
    emailC, streetC, numEc, numIc, otherSchedule, colonyC, townC, codeC, stateC, 
    referenceC, streetR1, streetR2, observacion, emailCo, numberChildren, numberAdults,
    pinC, fraccionamiento;
  late ProviderJunghanns provider;
  late Size size;
  @override
  void initState() {
    super.initState();
    isLoadingSchedule=true;
    isLoading = false;
    isDate = false;
    isFracc=false;
    isOTP=false;
    idNewCustomer=0;
    lat = 0;
    lng = 0;
    errLatLng="";
    errName="";
    errLastN="";
    errDateB="";
    errCompany="";
    errContact="";
    errPhone="";
    errEmail="";
    errTypeStreet="";
    errStreet="";
    errNumE="";
    errColony="";
    errTown="";
    errState="";
    errCode="";
    errTypeSaleC="";
    errEmployee="";
    errAdults="";
    errChildren="";
    errMaterno="";
    errFracc="";
    nameCustomerAPI="";
    dateBirth = DateTime.now().subtract(const Duration(days:18250));
    typeLeed=NewTypeUser.particular;
    employeeS = EmployeeModel.fromState();
    typeStreetS = TypeOfStreetModel.fromState();
    typeSaleCs = SaleCambaceoModel.fromState();
    employeesList = [];
    typesStreetsList = [];
    typesSalesCList = [];
    schedules = [];
    chanels = [
      {"id": 0, "descripcion": "Selecciona una opción"},
      {"id": 1, "descripcion": "whatsapp"},
      {"id": 2, "descripcion": "sms"},
      {"id": 3, "descripcion": "email"},
      {"id": 4, "descripcion": "llamada"}
    ];
    genders = [
      {"id": 0, "descripcion": "Selecciona una opción"},
      {"id": 1, "descripcion": "Masculino"},
      {"id": 2, "descripcion": "Femenino"},
      {"id": 3, "descripcion": "Prefiere no decirlo"},
      {"id": 4, "descripcion": "Otro"},
    ];
    typesUser= [
      {"id":0,"descripcion": "Selecciona una opción"},
      {"id":1,"descripcion": getTypeUserCambaceo(NewTypeUser.particular)},
      {"id":2,"descripcion": getTypeUserCambaceo(NewTypeUser.empresa)},
      {"id":3,"descripcion": getTypeUserCambaceo(NewTypeUser.deposito)}
    ];
    schedule = {"id": 0, "descripcion": "Selecciona una opción"};
    scheduleOther = {"1": "Inicio", "2": "Fin","3":"Inicio","4":"Fin",
      "err1":"","err2":"","err3":"","err4":""};
    gender=genders.first;
    chanelValidation = chanels.first;
    nameC = TextEditingController();
    lastNameC = TextEditingController();
    lastNameMC = TextEditingController();
    companyC=TextEditingController();
    contactC=TextEditingController();
    phoneC=TextEditingController();
    emailC=TextEditingController();
    streetC = TextEditingController();
    numEc = TextEditingController();
    numIc = TextEditingController();
    otherSchedule = TextEditingController();
    colonyC = TextEditingController();
    townC = TextEditingController();
    codeC = TextEditingController();
    stateC = TextEditingController();
    referenceC = TextEditingController();
    streetR1 = TextEditingController();
    streetR2 = TextEditingController();
    observacion = TextEditingController();
    emailCo = TextEditingController();
    fraccionamiento=TextEditingController();
    numberChildren = TextEditingController();
    numberAdults = TextEditingController();
    pinC = TextEditingController();
    getPermission();
    getListTypesOfStreets();
    funButtonLocation();
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
        log("STATUS RECORD ====> ${answer.body}");
        if (answer.body["status"] == "awaiting_validation") {
          phoneC.text = answer.body["tel_movil"];
          idNewCustomer =
              int.parse((answer.body["id_cliente_cambaceo"] ?? -1).toString());
          nameCustomerAPI = answer.body["nombre_lead"];
          Position _currentLocation = await Geolocator.getCurrentPosition();
          lat = _currentLocation.latitude;
          lng = _currentLocation.longitude;
          isOTP = true;
        }else{
          prefs.channelValidation="";
          prefs.customerP=true;
        }
      }
    });
    getDataSchedules();
  }

  getDataSchedules() async {
    setState(()=>isLoadingSchedule=true);
    await getSchedules().then((answer) {
      setState(()=>isLoadingSchedule=false);
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
          schedules = List.from(answer.body.map((e) => e).toList());
          schedule=schedules.first;
        });
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  refreshLocation() {
    Navigator.pop(context);
    funButtonLocation();
    showLocation(context, refreshLocation, lat, lng);
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
    setState(() {
      isLoading = false;
    });
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

  funCancelCode() async {
    Map<String, dynamic> data = {
      "id": idNewCustomer,
    };
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
                    child: const Text("Código validado con exito")
                  )
                ),
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
                  () => () =>Navigator.pop(context),
                  Decorations.greenJCard
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  funResendCode(bool isW) async {
    log("FUN RESEND CODE");

    Map<String, dynamic> data = {
      "id_lead": idNewCustomer,
      "id_ruta": prefs.idRouteD,
      "lat": lat.toString(),
      "lon": lng.toString(),
      "envio_msg_otp": "S",
      "canal": prefs.channelValidation.toUpperCase()
    };

    log("INFO RESEND: $data");

    await postResendCode(data).then((answer) {
      log("${answer.body} ======> ${answer.status}");
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
        // idNewCustomer = int.parse((answer.body["id"] ?? -1).toString());
        log(idNewCustomer.toString());
      }
    });
  }

  funButtonContinue() async {
    //prefs.urlBase=ipStage;
    log("FUN BUTTON CONTINUE ${prefs.urlBase}");
    Map<String, dynamic> data = {};
    Fluttertoast.showToast(
        msg: prefs.nameUserD,
        timeInSecForIosWeb: 2,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        webShowClose: true,
      );
    if (typeLeed==NewTypeUser.particular) {
      data = {
        "action": "create",
        "id_ruta": prefs.idRouteD,
        "envio_msg_otp": "S",
        "usuario": prefs.nameUserD,
        "data": {
          "tipo": 'P',
          "nombre": nameC.text,
          "ap_materno": lastNameMC.text,
          "ap_paterno": lastNameC.text,
          "fecha_nacimiento": DateFormat('yyyy-MM-dd').format(dateBirth),
          "tel_movil": phoneC.text.replaceAll(" ", ""),
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
          "tipo_venta": typeSaleCs.id,
          "entre_calle_1": streetR1.text,
          "entre_calle_2": streetR2.text,
          "observaciones": observacion.text,
          "hora_inicio": scheduleOther["1"],
          "hora_fin": scheduleOther["2"],
          "no_infantes": int.tryParse(numberChildren.text) ?? 0,
          "no_adultos": int.tryParse(numberAdults.text) ?? 0,
          "id_horario": schedule["id"],
          "otros_horarios": "${scheduleOther["3"]} HRS - ${scheduleOther["4"]} HRS"
        }
      };
    } else {
      data = {
        "action": "create",
        "id_ruta": prefs.idRouteD,
        "envio_msg_otp": "S",
        "usuario": prefs.nameUserD,
        "data": {
          "tipo": 'E',
          "razon_social": companyC.text,
          "contacto": contactC.text,
          "tel_movil": phoneC.text.replaceAll(" ", ""),
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
          "tipo_venta": typeSaleCs.id,
          "entre_calle_1": streetR1.text,
          "entre_calle_2": streetR2.text,
          "observaciones": observacion.text,
          "hora_inicio": scheduleOther["1"],
          "id_horario": schedule["id"],
          "no_infantes": 0,
          "no_adultos": int.tryParse(numberAdults.text) ?? 0,
          "hora_fin": scheduleOther["2"],
          "otros_horarios": "${scheduleOther["3"]} HRS - ${scheduleOther["4"]} HRS"
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
          prefs.customerP = typeLeed==NewTypeUser.particular;
          prefs.channelValidation="";
        });
        Fluttertoast.showToast(
          msg: "Se envió código de verificación",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
        idNewCustomer = int.parse((answer.body["id"] ?? -1).toString());
      }
    });
  }

  selectEmployee() async {
    await showCupertinoModalPopup<int>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actionScrollController: ScrollController(
            initialScrollOffset: 1.0, keepScrollOffset: true),
          actions: employeesList.map((item)=>showItemEmployee(item)).toList());
      }
    );
  }
  
  selectTypeStreet() async {
    await showCupertinoModalPopup<int>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actionScrollController: ScrollController(
            initialScrollOffset: 1.0, keepScrollOffset: true),
          actions: typesStreetsList.map((item)=> showItemTypeStreet(item)).toList());
      }
    );
  }
  
  selectTypeSaleC() async {
    await showCupertinoModalPopup<int>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actionScrollController: ScrollController(
            initialScrollOffset: 1.0, keepScrollOffset: true),
          actions: typesSalesCList.map((item)=> showItemTypeSaleC(item)).toList());
      }
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
      }
    );
  }
  
  void selectHour(String id) async {
    List<String> items=["07:00","07:30","08:00","08:30","09:00","09:30","10:00","10:30",
      "11:00","11:30","12:00","12:30","13:00","13:30","14:00","14:30","15:00",
      "15:30","16:00","16:30","17:00","17:30","18:00","18:30","19:00","19:30",
      "20:00","20:30","21:00"];
    id=="3"||id=="4"?items.insert(0,id=="3"?"Inicio":"Fin"):null;
    await showCupertinoModalPopup<int>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actionScrollController: ScrollController(
            initialScrollOffset: 1.0, keepScrollOffset: true),
          actions: items.map((item)=> _showItemHour(item, id)).toList());
      }
    );
  }
  
  bool checkValidField() {
    bool isValid = true;
    setState(() {
      if (lat == 0 && lng == 0) {
        errLatLng = "Coordenadas obligatorias";
        isValid = false;
      } else {
        errLatLng = "Coordenadas actualizadas";
      }

      if (typeLeed==NewTypeUser.particular && nameC.text.isEmpty) {
        errName = "Campo obligatorio";
        isValid = false;
      } else {
        errName = "";
      }

      if (typeLeed==NewTypeUser.particular && lastNameC.text.isEmpty) {
        errLastN = "Campo obligatorio";
        isValid = false;
      } else {
        errLastN = "";
      }
      if (typeLeed==NewTypeUser.particular && lastNameMC.text.isEmpty) {
        errMaterno = "Campo obligatorio";
        isValid = false;
      } else {
        errMaterno = "";
      }
      if (typeLeed==NewTypeUser.particular && !isDate) {
        errDateB = "Campo obligatorio";
        isValid = false;
      } else {
        errDateB = "";
      }
      if (typeLeed==NewTypeUser.empresa && companyC.text.isEmpty) {
        errCompany = "Campo obligatorio";
        isValid = false;
      } else {
        errCompany = "";
      }

      if (typeLeed==NewTypeUser.empresa && contactC.text.isEmpty) {
        errContact = "Campo obligatorio";
        isValid = false;
      } else {
        errContact = "";
      }

      if (phoneC.text.isEmpty) {
        errPhone = "Campo obligatorio";
        isValid = false;
      } else {
        if (phoneC.text.length < 14) {
          errPhone = "Télefono incompleto";
          isValid = false;
        } else {
          errPhone = "";
        }
      }

      if (emailC.text.isEmpty) {
        errEmail = "Campo obligatorio";
        isValid = false;
      } else {
        if (emailCo.text != emailC.text) {
          errEmail = "el correo no coincide";
        } else {
          errEmail = "";
        }
      }

      if (typeStreetS.id == -1) {
        errTypeStreet = "Campo obligatorio";
        isValid = false;
      } else {
        errTypeStreet = "";
      }

      if (streetC.text.isEmpty) {
        errStreet = "Campo obligatorio";
        isValid = false;
      } else {
        errStreet = "";
      }

      if (numEc.text.isEmpty) {
        errNumE = "Campo obligatorio";
        isValid = false;
      } else {
        errNumE = "";
      }

      if (colonyC.text.isEmpty) {
        errColony = "Campo obligatorio";
        isValid = false;
      } else {
        errColony = "";
      }

      if (townC.text.isEmpty) {
        errTown = "Campo obligatorio";
        isValid = false;
      } else {
        errTown = "";
      }

      if (stateC.text.isEmpty) {
        errState = "Campo obligatorio";
        isValid = false;
      } else {
        errState = "";
      }

      if (codeC.text.isEmpty) {
        errCode = "Campo obligatorio";
        isValid = false;
      } else {
        errCode = "";
      }

      if (typeSaleCs.id == -1) {
        errTypeSaleC = "Campo obligatorio";
        isValid = false;
      } else {
        errTypeSaleC = "";
      }

      if (employeeS.id == -1) {
        errEmployee = "Campo obligatorio";
        isValid = false;
      } else {
        errEmployee = "";
      }
      if ((scheduleOther["3"] == "Inicio" && scheduleOther["4"] != "Fin")
        ||(scheduleOther["3"] != "Inicio" && scheduleOther["4"] == "Fin")) {
        scheduleOther["err3"] = "Debes ingresar ambos campos";
      }else{
         scheduleOther["err3"] = "";
      }
      if (schedule["descripcion"] == "Otro horario" &&
          (scheduleOther["1"]=="Inicio"||scheduleOther["2"]=="Fin")) {
        scheduleOther["err1"] = "Campo obligatorio";
        isValid = false;
      } else {
        scheduleOther["err1"] = "";
      }
      if (numberChildren.text.isEmpty && typeLeed==NewTypeUser.particular) {
        errChildren = "Campo obligatorio";
        isValid = false;
      } else {
        errChildren = "";
      }
      if (numberAdults.text.isEmpty) {
        errAdults = "Campo obligatorio";
       isValid = false;
      } else {
        errAdults = "";
      }
    });
    return isValid;
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
          child: formNewCustomer()
        ),
        Visibility(
          visible: isOTP, 
          child: otpField()
        ),
        Visibility(
          visible: provider.connectionStatus == 4,
          child: Container(
            color: ColorsJunghanns.whiteJ,
            child: Center(
              child: Text(
                "Sin conexión a internet",
                style: TextStyles.redJ24Bold,
                textAlign: TextAlign.center,
              )
            )
          )
        ),
        Visibility(
          visible: isLoading, 
          child: const LoadingJunghanns()
        )
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
              )
            )
          ),
          Text(
            "Nuevo cliente",
            style: TextStyles.blueJ22Bold,
          ),
          buttonLocation(),
          SheetSelect(
            isRequired: true,
            update: (value){
              setState(()=> typeLeed = getNewTypeUserCambaceo(value['descripcion']));
              Navigator.pop(context);
            },
            items:typesUser,
            current: (typesUser.where((element) => 
              element['descripcion']==getTypeUserCambaceo(typeLeed))
                .first)??typesUser.first,
            title:  "Tipo Cliente"
          ),
          Visibility(
            visible: typeLeed == NewTypeUser.particular,
            child:SheetSelect(
              isRequired: true,
              update: (value){
                setState(() => gender = value);
                Navigator.pop(context);
              },
              items:genders,
              current:gender,
              title: "Genero"
            )
          ),
          Visibility(
            visible: typeLeed == NewTypeUser.particular,
            child: textFieldLabel(nameC,"Nombre(s)","Nombre(s)",errName,
              isRequired: true)
          ),
          Visibility(
            visible: typeLeed == NewTypeUser.particular,
            child: textFieldLabel(lastNameC,"Apellidos paterno","Apellido paterno",
              errLastN,isRequired: true)
          ),
          Visibility(
            visible: typeLeed == NewTypeUser.particular,
            child: textFieldLabel(lastNameMC,"Apellidos materno","Apellido materno",
              errMaterno,isRequired: true)
          ),
          Visibility(
            visible: typeLeed == NewTypeUser.particular,
            child: Picker(
              isRequired: true,
              isDay: true,
              error: errDateB,
              update: (value)=> setState(() {
                if(value!=null){
                  dateBirth = value;
                  isDate = true;
                }
              }), 
              current: DateFormat('dd/MM/yyyy').format(dateBirth), 
              title: "Fecha Nacimiento")
          ),
          Visibility(
            visible: [NewTypeUser.empresa,NewTypeUser.deposito].contains(typeLeed),
            child: textFieldLabel(companyC, 
              "Nombre ${getTypeUserCambaceo(typeLeed).toLowerCase()}", 
              "Razón Social", errCompany,isRequired: true
            )
          ),
          Visibility(
            visible: typeLeed == NewTypeUser.empresa,
            child: textFieldLabel(contactC, "Contacto", "Contacto", errContact,
              isRequired: true
            )
          ),
          textFieldLabel(phoneC, "Télefono Móvil", "555 555 5555", errPhone,
            isRequired: true,isPhone: true
          ),
          textFieldLabel(emailC,  "E-mail", "ejemplo@midominio.com", errEmail,
            isRequired: true
          ),
          textFieldLabel(emailCo, "Confirmacion de E-mail", "ejemplo@midominio.com",
            errEmail,isRequired: true
          ),
          _select("Tipo Vialidad",
            typeStreetS.id == -1
              ? "Tipo Vialidad"
              : typeStreetS.description,
            errTypeStreet != ""
              ? Decorations.whiteBorder10Red
              : Decorations.whiteSblackCard,
            typeStreetS.id == -1
              ? TextStyles.grey15Itw
              : TextStyles.blueJ15SemiBold,
            selectTypeStreet,errTypeStreet,isRequired: true
          ),
          textFieldLabel(streetC, "Calle", "Calle", errStreet,isRequired: true),
          textFieldLabel(numEc, "No. Exterior", "No. Exterior", errNumE,
            isRequired: true
          ),
          textFieldLabel(numIc, "No. Interior", "No. Interior", ""),
          textFieldLabel(colonyC,  "Colonia",  "Colonia", errColony,isRequired: true),
          textFieldLabel(townC, "Municipio o Alcaldía", "Municipio o Alcaldía", 
            errTown,isRequired: true),
          textFieldLabel(stateC, "Estado", "Estado", errState,isRequired: true),
          textFieldLabel(codeC, "Código Postal", "Código Postal", errCode,
            isRequired: true,isNumber: true),
          Visibility(
            visible: typeLeed == NewTypeUser.particular,
            child: textFieldLabel(fraccionamiento, "Fraccionamiento", 
              "Fraccionamiento", errFracc,numLines: 3
            )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 10),
            child: Text(
              "Entre calles",
              style: JunnyText.semiBoldBlueA1(15),
            ),
          ),
          textFieldLabel(streetR1, "Calle y", "calle y calle", "",numLines: 2),
          textFieldLabel(streetR2, "Calle ", "calle y calle", "",numLines: 2),
          textFieldLabel(referenceC, "Referencias adicionales del domicilio",
            "Referencias adicionales del domicilio", "",numLines: 5),
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 10, bottom: 10),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Horario prefente de visita",
                    style: JunnyText.semiBoldBlueA1(15)),
                  TextSpan(text: "*",style: JunnyText.red5c(18))
                ]
              )
            )
          ),
          !isLoadingSchedule
            ? selectMap(context,(value)=> setState(() => schedule = value),schedules,
                schedule["descripcion"] == "Selecciona una opción"
                  ? schedules.first
                  : schedule,
                decoration: Decorations.whiteSblackCard,
                style: TextStyles.blueJ15SemiBold)
            : const SpinKitCircle(color: ColorsJunghanns.blue,size: 30),
          const SizedBox(height: 15),
          Visibility(
            visible: schedule["descripcion"] == "Otro horario",
            child: Text(
              "1er Horario:",
              style: JunnyText.semiBoldBlueA1(15)
            )
          ),
          Visibility(
            visible: schedule["descripcion"] == "Otro horario",
            child: const Divider(
              thickness: 1,
              color: JunnyColor.blueCE
            ),
          ),
          Visibility(
            visible: schedule["descripcion"] == "Otro horario",
            child:Row(
              children: [
                Expanded(
                  child: _select(
                    "Desde",
                    scheduleOther["1"],
                    scheduleOther["err1"] != ""
                      ? Decorations.whiteBorder10Red
                      : Decorations.whiteSblackCard,
                    scheduleOther["1"] == "Inicio"
                      ? TextStyles.grey15Itw
                      : TextStyles.blueJ15SemiBold,
                    () => selectHour("1"),
                    "",
                    isRequired: true
                  )
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: _select(
                    "Hasta",
                    scheduleOther["2"],
                    scheduleOther["err1"] != ""
                      ? Decorations.whiteBorder10Red
                      : Decorations.whiteSblackCard,
                    scheduleOther["2"] == "Fin"
                      ? TextStyles.grey15Itw
                      : TextStyles.blueJ15SemiBold,
                    () => selectHour("2"),
                    "",
                    isRequired: true
                  )
                ),
              ],
            ),
          ),
          Visibility(
            visible: schedule["descripcion"] == "Otro horario" && 
              scheduleOther["err1"]!="",
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child:Text(
                scheduleOther["err1"],
                style: JunnyText.red5c(13)
              )
            )
          ),
          const SizedBox(height: 10),
          Visibility(
            visible: schedule["descripcion"] == "Otro horario",
            child: Text(
              "2do Horario (opcional):",
              style: JunnyText.semiBoldBlueA1(15)
            )
          ),
          Visibility(
            visible: schedule["descripcion"] == "Otro horario",
            child: const Divider(
              thickness: 1,
              color: JunnyColor.blueCE
            ),
          ),
          Visibility(
            visible: schedule["descripcion"] == "Otro horario",
            child: Row(
              children: [
                Expanded(
                  child: _select(
                    "Desde",
                    scheduleOther["3"],
                    scheduleOther["err3"] != ""
                      ? Decorations.whiteBorder10Red
                      : Decorations.whiteSblackCard,
                    scheduleOther["3"] == "Inicio"
                      ? TextStyles.grey15Itw
                      : TextStyles.blueJ15SemiBold,
                    () => selectHour("3"),
                    "",
                  )
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: _select(
                    "Hasta",
                    scheduleOther["4"],
                    scheduleOther["err3"] != ""
                      ? Decorations.whiteBorder10Red
                      : Decorations.whiteSblackCard,
                    scheduleOther["4"] == "Fin"
                      ? TextStyles.grey15Itw
                      : TextStyles.blueJ15SemiBold,
                    () => selectHour("4"),
                    "",
                  )
                ),
              ],
            ),
          ),
          Visibility(
            visible: schedule["descripcion"] == "Otro horario" && 
              scheduleOther["err3"]!="",
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child:Text(
                scheduleOther["err3"],
                style: JunnyText.red5c(13)
              )
            )
          ),
          Visibility(
            visible: typeLeed == NewTypeUser.particular,
            child: textFieldLabel(numberChildren, "# de niños en casa (<12)", "1", 
              errChildren,isRequired: true,isNumber: true
            )
          ),
          textFieldLabel(numberAdults, "# ${typeLeed == NewTypeUser.particular
              ? "de adultos en casa (12+)"
              : "de personas"}", "1", errAdults,isRequired: true,isNumber: true),
          textFieldLabel(observacion, "Observación", "Observación", "",numLines: 3),
          _select("Tipo de Venta",typeSaleCs.id == -1 
              ? "Tipo de Venta" : typeSaleCs.description, 
            errTypeSaleC != ""
              ? Decorations.whiteBorder10Red : Decorations.whiteSblackCard,
            typeSaleCs.id == -1
              ? TextStyles.grey15Itw: TextStyles.blueJ15SemiBold,selectTypeSaleC,
            errTypeSaleC,
            isRequired: true),
          _select("Personal de Alta",employeeS.id == -1 
              ? "Personal de Alta": employeeS.employee,
            errEmployee != ""
              ? Decorations.whiteBorder10Red: Decorations.whiteSblackCard,
            employeeS.id == -1? TextStyles.grey15Itw: TextStyles.blueJ15SemiBold,
            selectEmployee,errEmployee,isRequired: true),
          buttonContinue()
        ],
      )
    );
  }
  
  Widget _showItemHour(String item, String id) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 20, 10, 14),
        child: DefaultTextStyle(
          style: TextStyles.blueJ20Bold,
          child: Text(
            item,
          )
        )
      ),
      onTap: () {
        bool condition = false;
        if(id=="1"||id=="2"){
          condition=int.parse(id=="1"
            ? item.toString().replaceAll(":", "")
            : (scheduleOther["1"]!="Inicio"
              ? scheduleOther["1"].toString().replaceAll(":", "")
              : "0"))
            < int.parse(id=="2"
            ? item.toString().replaceAll(":", "")
            : (scheduleOther["2"]!="Fin"
              ? scheduleOther["2"].toString().replaceAll(":", "")
              : "2200"));
        }else if(item!="Inicio" && item!="Fin"){
          condition=int.parse(id=="3"
            ? item.toString().replaceAll(":", "")
            : (scheduleOther["3"]!="Inicio"
              ? scheduleOther["3"].toString().replaceAll(":", "")
              : "0"))
            < int.parse(id=="4"
            ? item.toString().replaceAll(":", "")
            : (scheduleOther["4"]!="Fin"
              ? scheduleOther["4"].toString().replaceAll(":", "")
              : "2200"));
        }else{
          condition=true;
        }
        if(condition){
        setState(() {
          scheduleOther[id]=item;
        });
        Navigator.pop(context);
        }else{
          Fluttertoast.showToast(
          msg: "La hora de inicio debe ser menor a la hora fin",
          timeInSecForIosWeb: 2,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          webShowClose: true,
        );
        }
      },
    );
  }

  Widget buttonLocation() {
    return lat != 0 && lng != 0
      ? Row(
          children: [
            Expanded(
              child: ButtonJunghanns(
                fun: ()=> funButtonLocation(),
                decoration: Decorations.blueBorder12,
                style: TextStyles.white14SemiBold,
                label: "Actualizar ubicación"
              )
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: ButtonJunghanns(
                fun: () =>showLocation(context, refreshLocation, lat, lng),
                decoration: Decorations.greenBorder12,
                style: TextStyles.white14SemiBold,
                label: "Ver ubicación"
              )
            )
          ],
        )
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 15),
              height: 35,
              child: ButtonJunghanns(
                fun: () =>funButtonLocation(),
                decoration: Decorations.blueBorder12,
                style: TextStyles.white14SemiBold,
                label: "*ACTUALIZAR UBICACIÓN"
              )
            ),
            errLatLng.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.only(top: 5, left: 15),
                  child: Text(
                    errLatLng,
                    style: errLatLng == "*Coordenadas actualizadas"
                      ? TextStyles.greenJ13N
                      : TextStyles.redJ13N,
                  )
                )
            : Container()
          ],
        );
  }

  Widget textField(
      String titleT,
      String hintT,
      String errT,
      TextEditingController controller,
      bool isNumber,
      bool isPhone,
      int numLines,{
        bool isRequired=false
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 15, bottom: 2, left: 10),
          child: isRequired
            ? RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: titleT,style: TextStyles.blue15SemiBold),
                  TextSpan(text: "*",style: JunnyText.red5c(16))
                ]
              )
            )
            : Text(
            titleT,
            style: TextStyles.blue15SemiBold,
          ),
        ),
        //Field
        TextFormField(
          controller: controller,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyles.blueJ15SemiBold,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: numLines,
          maxLength: numLines == 5 ? 60 : null,
          inputFormatters: isPhone ? [MaskedInputFormatter("###  ###  ####")] : [],
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
                : const BorderSide(width: 1, color: ColorsJunghanns.lighGrey),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 1, color: ColorsJunghanns.blueJ),
              borderRadius: BorderRadius.circular(10),
            ),
          )
        ),
        errT.isNotEmpty
          ? Container(
              padding: const EdgeInsets.only(top: 4, left: 15),
              child: Text(
                errT,
                style: TextStyles.redJ13N,
              )
            )
          : Container()
      ],
    );
  }

  Widget showItemTypeStreet(TypeOfStreetModel ts) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 20, 10, 14),
        child: DefaultTextStyle(
          style: TextStyles.blueJ20Bold,
          child: Text(
            ts.description,
          )
        )
      ),
      onTap: () {
        setState(() {
          typeStreetS = ts;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget showItemTypeSaleC(SaleCambaceoModel tsc) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 20, 10, 14),
        child: DefaultTextStyle(
          style: TextStyles.blueJ20Bold,
          child: Text(
            tsc.description,
          )
        )
      ),
      onTap: () {
        setState(() {
          typeSaleCs = tsc;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _select(String titleB, String textB, BoxDecoration decoB,
      TextStyle textSB, Function funB, String errB,{bool isRequired=false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 10, bottom: 2, left: 10),
          child: isRequired
            ? RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: titleB,style: JunnyText.semiBoldBlueA1(15)),
                  TextSpan(text: "*",style: JunnyText.red5c(18))
                ]
              )
            )
            : Text(
            titleB,
            style: JunnyText.semiBoldBlueA1(15),
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
          onTap: ()=>funB(),
        ),
        errB.isNotEmpty
          ? Container(
              padding: const EdgeInsets.only(top: 4, left: 15),
              child: Text(
                errB,
                style: TextStyles.redJ13N,
              )
            )
          : Container()
      ],
    );
  }

  Widget showItemEmployee(EmployeeModel emp) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 20, 10, 14),
        child: DefaultTextStyle(
          style: TextStyles.blueJ20Bold,
          child: Text(
            emp.employee,
          )
        )
      ),
      onTap: () {
        setState(() {
          employeeS = emp;
        });
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
        label: "REGISTRAR"
      ),
    );
  }

  Widget textConfirm() {
    return Container(
      alignment: Alignment.center,
      child: DefaultTextStyle(
        style: TextStyles.blueJ20Bold, 
        child: const Text("CONFIRMACIÓN")
      )
    );
  }

  Widget textPhoneConfirm() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        children: [
          DefaultTextStyle(
            style: TextStyles.blueJ218R,
            child: Text(
              "Registrar y enviar código de verificación a ",
              style: TextStyles.blueJ218R,
              textAlign: TextAlign.center,
            ),
          ),
          DefaultTextStyle(
            style: TextStyles.greenJ20Bold,
            textAlign: TextAlign.center,
            child: Text(
              typeLeed == NewTypeUser.particular
                ? "${nameC.text} ${lastNameC.text}"
                : companyC.text,
            )
          ),
          DefaultTextStyle(
            style: TextStyles.greenJ20Bold,
            child: Text(
              phoneC.text,
            )
          ),
        ],
      )
    );
  }

  Widget buttomsConfirm() {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buttomConfirm("Si", () => () async {
            Navigator.pop(context);funButtonContinue();},Decorations.blueBorder12),
          buttomConfirm("No",() => () {
            Navigator.pop(context);},Decorations.redCard),
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
          )
        )
      ),
    );
  }

  Widget otpField() {
    return Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
            child: Container(
          padding: const EdgeInsets.all(12),
          width: size.width * .8,
          //height: size.height * .36,
          decoration: Decorations.whiteS1Card,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                        ? typeLeed==NewTypeUser.particular
                            ? "${nameC.text} ${lastNameC.text}"
                            : companyC.text
                        : nameCustomerAPI,
                    style: TextStyles.greenJ20Bold,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    phoneC.text,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                          visible: prefs.channelValidation != "llamada" &&
                              prefs.channelValidation != "email",
                          child: Container(
                            padding: const EdgeInsets.only(
                                top: 15, left: 10, bottom: 10),
                            child: Text(
                              "Selecciona el canal de reenvío",
                              style: TextStyles.blue15SemiBold,
                            ),
                          )),
                      prefs.channelValidation == "llamada" ||
                              prefs.channelValidation == "email"
                          ? SizedBox(
                              height: 35,
                              child: prefs.channelValidation == "email"
                                  ? ButtonJunghanns(
                                      fun: () {
                                        showYesNot(
                                            context,
                                            () => funResendCode(false),
                                            "¿Estas seguro de volver a enviar y generar un código de validación? Esto invalidará el código enviado anteriormente",
                                            true);
                                      },
                                      decoration: Decorations.blueJ2Card,
                                      style: TextStyles.white15R,
                                      label: "Reenviar email")
                                  : null)
                          : chanels.isNotEmpty
                              ? selectMap(context, (value) {
                                  showYesNot(context, () {
                                    setState(() {
                                      prefs.channelValidation =
                                        value["descripcion"];
                                    });
                                    funResendCode(false);
                                  }, "¿Estas seguro de volver a enviar y generar un código de validación? Esto invalidará el código enviado anteriormente",
                                      true);
                                },
                                  !prefs.customerP
                                      ? chanels
                                          .where(
                                              (element) => element["id"] != 4)
                                          .toList()
                                      : prefs.channelValidation == "whastapp" ||
                                              prefs.channelValidation == "sms"
                                          ? chanels
                                              .where((element) =>
                                                  element["id"] != 3 &&
                                                  element["id"] != 4)
                                              .toList()
                                          : chanels,
                                  chanelValidation,
                                  decoration: Decorations.whiteSblackCard,
                                  style: TextStyles.blueJ15SemiBold)
                              : Container(
                                  color: ColorsJunghanns.blue,
                                  width: 10,
                                  height: 10,
                                ),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 35,
                        child: ButtonJunghanns(
                            fun: () {
                              showYesNot(
                                  context,
                                  () => funCancelCode(),
                                  "¿Estas seguro de cancelar la validación?",
                                  true);
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
 
}
