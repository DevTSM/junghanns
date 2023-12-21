import 'package:flutter/material.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
  class YesNot extends StatelessWidget{
    final Function fun;
    final String label;
    final String? subLabel;
    final String? sufixLabel;
    final bool isGeneric;
  const YesNot(
    {
      Key? key,
      required this.fun,
      required this.label,
      this.subLabel,
      this.sufixLabel,
      required this.isGeneric
    }
  ) : super(key: key);

  Widget _sufixLabel(String? label,{bool sufix = false}){
    return label != null
      ? Container(
          margin: EdgeInsets.only(
            top: sufix ? 10 : 0,
            bottom: sufix ? 0 : 10,
            left: 10,
            right: 10
          ),
          child: Text(
            label,
            style: sufix 
              ? JunnyText.bluea4(FontWeight.w300, 10)
              : JunnyText.bluea4(FontWeight.w500, 14),
          textAlign: TextAlign.center,
          )
        ) 
      : const SizedBox.shrink();
  }
  Widget _buttons(BuildContext context){
    return IntrinsicHeight(
      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 2,
            child: ButtonJunghannsLabel(
              width: double.infinity,
              fun: (){
                Navigator.pop(context);
                fun();
                },
              decoration: JunnyDecoration.bottomLeft(8)
                .copyWith(border: const Border.symmetric(
                    horizontal: BorderSide(color: JunnyColor.blueCE),
                  )
                ),
              style: JunnyText.bluea4(FontWeight.w500, 18),
              label: "Si"
            )
          ),
          const VerticalDivider(
            color: JunnyColor.blueCE,
            thickness: 1,
            width: 1,
          ),
          Expanded(
            flex: 2,
            child: ButtonJunghannsLabel(
              width: double.infinity,
              fun: ()=> Navigator.pop(context),
              decoration: JunnyDecoration.bottomRight(8)
                .copyWith(border: const Border.symmetric(
                    horizontal: BorderSide(color: JunnyColor.blueCE)
                  )
                ),
              style: JunnyText.semiBoldBlueA1(18)
                .copyWith(color: JunnyColor.red5c),
              label: "No"
            )
          ),
        ],
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //padding: const EdgeInsets.all(12),
      width: MediaQuery.of(context).size.width * .85,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              isGeneric
                ? label 
                : "¿Seguro que quieres ${label == "fin"
                  ? "finalizar la ruta?"
                  : label == "inicio_comida" 
                    ? "iniciar el horario de comida?"
                    : "realizar esta acción?"}",
              style: TextStyles.blueJ22Bold,
            textAlign: TextAlign.center,
            ),
          ),
          const SizedBox( height: 15),
          _sufixLabel(subLabel),
          _sufixLabel(sufixLabel,sufix: true),
          _buttons(context)
        ],
      ),
    );
  }
}

showYesNot(
  BuildContext context,
  Function fun,
  String label,
  bool isGeneric,
  {
    String? subLabel,
    String? sufixLabel
  }){
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      contentPadding: const EdgeInsets.only(top: 10),
      content: YesNot(
        fun:fun,
        label: label,
        isGeneric: isGeneric,
        subLabel: subLabel,
        sufixLabel: sufixLabel,
      )
    ),
  );
}