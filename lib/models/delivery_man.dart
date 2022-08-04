import 'dart:developer';

class DeliveryManModel {
  int idUser;
  int idProfile;
  String nameUser;
  String name;
  int idRoute;
  String nameRoute;
  String dayWork;
  String dayWorkText;
  String code;

  DeliveryManModel(
      {required this.idUser,
      required this.idProfile,
      required this.nameUser,
      required this.name,
      required this.idRoute,
      required this.nameRoute,
      required this.dayWork,
      required this.dayWorkText,
      required this.code});

  factory DeliveryManModel.fromState() {
    return DeliveryManModel(
        idUser: 1,
        idProfile: 1,
        nameUser: "R11T",
        name: "REPARTO NAME TEST",
        idRoute: 1,
        nameRoute: "RUTA11 TEST",
        dayWork: "L",
        dayWorkText: "LUNES",
        code: "TEST");
  }

  factory DeliveryManModel.fromService(Map<String, dynamic> data) {
    return DeliveryManModel(
        idUser: data["id_usurio"] ?? 2,
        idProfile: data["id_perfil"] ?? 2,
        nameUser: data["nombre_usuario"] ?? "R12T",
        name: data["nombre"] ?? "REPARTO RUTA TEST2",
        idRoute: data["id_ruta"] ?? 2,
        nameRoute: data["nombre_ruta"] ?? "RUTA 12 TEST",
        dayWork: data["dia_trabajo"] ?? "L",
        dayWorkText: data["dia_trabajo_texto"] ?? "LUNES",
        code: data["codigo_empresa"] ?? "TEST");
  }
}
