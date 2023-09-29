import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/components/modal/yes_not.dart';
import 'package:junghanns/components/textfield/text_field.text.dart';
import 'package:junghanns/models/operation_customer.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';

class ShowCount extends StatefulWidget{
  Function setComodato;
  OperationCustomerModel current;
  ShowCount({super.key,required this.setComodato,required this.current});
  @override
  State<StatefulWidget> createState()=>_ShowCount();
  
}
class _ShowCount extends State<ShowCount>{
  late TextEditingController countController;
  late Size size;
  late bool isLoading;
  @override
  void initState() {
    super.initState();
    countController=TextEditingController();
    isLoading=false;
  }
  @override
  Widget build(BuildContext context) {
    size=MediaQuery.of(context).size;
    return Container(
                    padding: const EdgeInsets.all(12),
                    width: size.width * .75,
                    decoration: Decorations.whiteS1Card,
                    child: isLoading?Container(
                      height: size.height*.3,
                      alignment: Alignment.center,
                      child: const SpinKitCircle(color: ColorsJunghanns.blue,size: 100,)):Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //PRODUCTO
                        Container(
                            margin: const EdgeInsets.only(top: 8),
                            alignment: Alignment.center,
                            child: DefaultTextStyle(
                                style: TextStyles.blueJ18Bold,
                                child:
                                    Text(widget.current.description))),
                        //BOTONES
                        Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //BOTON DE MENOS
                                GestureDetector(
                                    onTap: 1 !=int.tryParse(countController.text)
                                        ? () {
                                          int total=0;
                                            setState((){
                                              total =(int.tryParse(countController.text)??0)-1;
                                            });
                                                countController.text= total.toString();
                                          }
                                        : () {},
                                    child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            22, 12, 22, 12),
                                        child: const Icon(
                                          FontAwesomeIcons.minus,
                                          size: 35,
                                          color: ColorsJunghanns.red,
                                        ))),
                                    const SizedBox(width: 10,),
                                //CANTIDAD
                                Expanded(child:textField2(
                                  ontap: (){
                                    // count.text= widget.productCurrent.number.toString();
                                  },
                                  (String value){
                                  if(value!=""){
                                     int number=int.tryParse(value)??0;
                                     if(number<widget.current.amount&&number>0){
                                      log("operacion correcta");
                                  }else{
                                    countController.text=widget.current.amount.toString();
                                  }
                                  }
                                },countController, "",type: TextInputType.number)),
                                const SizedBox(width: 10,),

                                //BOTON DE MAS
                                GestureDetector(
                                    onTap: widget.current.amount !=int.tryParse(countController.text)
                                        ? () {
                                          int total=0;
                                            setState((){
                                              total =(int.tryParse(countController.text)??0)+1;
                                            });
                                                countController.text= total.toString();
                                          }
                                        : () {},
                                    child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            22, 12, 22, 12),
                                        child: const Icon(
                                          FontAwesomeIcons.plus,
                                          size: 35,
                                          color: ColorsJunghanns.greenJ,
                                        )))
                              ],
                            )),

                        GestureDetector(
                          child: Container(
                            decoration: Decorations.blueBorder12,
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            alignment: Alignment.center,
                            child: const Text(
                              "CONFIRMAR",
                              style: TextStyles.white17_5,
                            ),
                          ),
                          onTap: () =>
                            showYesNot(context, (){
                              setState(() {
                                isLoading=true;
                              });
                              widget.setComodato(context,(int.tryParse(countController.text)??0));}, "¿Estás seguro de continuar con la operación?", true)
                          ,
                        )
                      ],
                    ),
                  );
  }

}
showCount(BuildContext context,Function setComodato,OperationCustomerModel current) {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  content: ShowCount(setComodato: setComodato, current: current)
                )));
  }