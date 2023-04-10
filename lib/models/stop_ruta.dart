class StopRuta{
  int id;
  int update;
  double lat;
  double lng;
  String status;
  StopRuta({required this.id,required this.update,required this.lat,required this.lng,required this.status});
  factory StopRuta.fromState(){
    return StopRuta(id: 0,update:0, lat: 0, lng: 0, status: "INRT");
  }
  factory StopRuta.fromDataBase(Map<String,dynamic> data){
    return StopRuta(id: data["id"], update: data["isUpdate"],lat: data["lat"], lng: data["lng"], status: data["status"]);
  }
  Map<String,dynamic> get getMap=>{
    "status":status,
    "lat":lat,
    "lng":lng,
    "isUpdate":update,
  };
}