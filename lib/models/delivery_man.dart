class DeliveryManModel{
  int id;
  String name;
  DeliveryManModel({required this.id,required this.name});
  factory DeliveryManModel.fromState(){
    return DeliveryManModel(id: 0, name: "Alejandro, Martínez");
  }
}