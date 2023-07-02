class BillingModel {
  String rfc;
  String razonSocial;
  String address;
  String email;
  String typeCFDI;
  String regimen;
  BillingModel(
      {required this.rfc,
      required this.razonSocial,
      required this.address,
      required this.email,
      required this.typeCFDI,
      required this.regimen});
  factory BillingModel.fromState() {
    return BillingModel(
        rfc: "",
        razonSocial: "",
        address: "",
        email: "",
        typeCFDI: "",
        regimen: "");
  }
  factory BillingModel.fromService(Map<String, dynamic> data) {
    return BillingModel(
        rfc: data["rfc"] ?? "",
        razonSocial: data["razon_social"] ?? "",
        address: data["direccion"] ?? "",
        email: data["email"],
        typeCFDI: data["uso_cfdi"] ?? "",
        regimen: data["regimen_fiscal"] ?? "");
  }
  Map<String,dynamic> get getMap=>{
    "rfc":rfc,
    "razon_social":razonSocial,
    "dirreccion":address,
    "email":email,
    "uso_cfdi":typeCFDI,
    "regimen_fiscal":regimen
  };
}
