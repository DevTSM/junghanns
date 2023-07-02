class FolioModel{
  int id;
  int status;
  int number;
  String serie;
  String type;
  FolioModel({required this.id,required this.status,required this.number,required this.serie,required this.type});
  //status: 0 ocupado 1 disponible 
  factory FolioModel.fromService(Map<String,dynamic> data,String serie,String type){
    return FolioModel(id:0,status: 1,number: data["numero"], serie: serie, type: type);
  }
  factory FolioModel.fromDataBase(Map<String,dynamic> data,){
    return FolioModel(id:data["id"], status: data["status"],number: data["numero"], serie: data["serie"], type: data["tipo"]);
  }
  getMap(){
    return {
      "status":status,
      "serie":serie,
      "numero":number,
      "tipo":type
    };
  }
 bool getValid(String value){
    if(type.toUpperCase()=="REMISION"&&value.toUpperCase()=="CREDITO"){
      return true;
    }else{
      if(type.toUpperCase()==value.toUpperCase()){
        return true;
      }else{
        return false;
      }
    }
  }
}