import 'package:flutter/material.dart';

class ButtonJunghanns extends StatelessWidget{
  Widget? icon;
  BoxDecoration decoration;
  Function fun;
  TextStyle style;
  String label;
  bool isIcon;
  ButtonJunghanns({Key? key, this.icon,required this.fun, required this.decoration,required this.style,required this.label,this.isIcon=false}) : super(key: key);
  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: ()=>fun(),
    child:Container(
      decoration: decoration,
      padding: const EdgeInsets.only(top: 10,bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
            flex:1,
            child: SizedBox(width: 10,)),
          isIcon?icon!:Container(),
          const Expanded(
            flex: 2,
            child: SizedBox(width: 10,)),
            Text(label,style: style,),
            const Expanded(
              flex: 3,
              child: SizedBox(width: 10,)),
        ],
      ),
    ));
  }

}