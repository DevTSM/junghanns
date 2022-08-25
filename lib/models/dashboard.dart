class DashboardModel {
  int customersR;
  int customersA;
  int specialServiceP;
  int specialServiceA;
  int liquidStock;
  int liquidSales;

  DashboardModel(
      {required this.customersR,
      required this.customersA,
      required this.specialServiceP,
      required this.specialServiceA,
      required this.liquidStock,
      required this.liquidSales});

  factory DashboardModel.fromState() {
    return DashboardModel(
        customersR: 0,
        customersA: 0,
        specialServiceP: 0,
        specialServiceA: 0,
        liquidStock: 0,
        liquidSales: 0);
  }

  factory DashboardModel.fromService(Map<String, dynamic> data) {
    return DashboardModel(
        customersR: data["clientes_ruta"] ?? 0,
        customersA: data["clientes_atendidos"] ?? 0,
        specialServiceP: data["serv_especiales_programados"] ?? 0,
        specialServiceA: data["serv_especiales_atendidos"] ?? 0,
        liquidStock: data["liquidos_stock"] ?? 0,
        liquidSales: data["liquidos_vendidos"] ?? 0);
  }
}
