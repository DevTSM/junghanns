class MethodPayment{
  String name;
  String type;
  String description;
  MethodPayment({required this.name,required this.type,required this.description});
  factory MethodPayment.fromState(){
    return MethodPayment(name: "", type: "E", description: "");
  }
}