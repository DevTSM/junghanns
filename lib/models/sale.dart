class SaleModel {
  DateTime date;
  String type;
  String description;
  double amount;
  int count;
  SaleModel(
      {required this.date,
      required this.type,
      required this.description,
      required this.amount,
      required this.count});
  factory SaleModel.fromState() {
    return SaleModel(
        date: DateTime.now(), type: "", description: "", amount: 0.0, count: 0);
  }
}
