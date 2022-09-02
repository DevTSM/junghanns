class EmployeeModel {
  int id;
  String employee;

  EmployeeModel({required this.id, required this.employee});

  factory EmployeeModel.fromState() {
    return EmployeeModel(id: -1, employee: "test");
  }

  factory EmployeeModel.fromService(Map<String, dynamic> data) {
    return EmployeeModel(
        id: data["id"] ?? -1, employee: data["empleado"] ?? "No");
  }
}
