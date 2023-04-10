import 'package:flutter/material.dart';
import 'package:junghanns/styles/text.dart';

class QRSeller extends StatefulWidget{
  const QRSeller({super.key});
  
  @override
  State<StatefulWidget> createState()=>_QRSellerState();
}
class _QRSellerState extends State<QRSeller>{
  @override
  Widget build(BuildContext context) {
    return const Center(
      child:Padding(
        padding: EdgeInsets.all(15),
        child:Text("Estamos trabajando en ello",style: TextStyles.blue40_7,textAlign: TextAlign.center,)),
    );
  }

}