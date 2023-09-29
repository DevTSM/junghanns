import 'package:flutter/material.dart';
import 'package:junghanns/components/loading.dart';
import 'package:junghanns/models/authorization.dart';
import 'package:junghanns/services/store.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';

class ShowCodeAuth extends StatefulWidget {
  Function getValid;
  AuthorizationModel current;
  ShowCodeAuth({super.key,required this.getValid,required this.current});
  @override
  State<StatefulWidget> createState() => _ShowCodeAuth();
}

class _ShowCodeAuth extends State<ShowCodeAuth> {
  late TextEditingController code;
  late String errorCode;
  @override
  void initState() {
    super.initState();
    code = TextEditingController();
    errorCode = "";
  }
  

  @override
  Widget build(BuildContext context) {
    return 
      Container(
        decoration: Decorations.whiteBorder12,
        width: MediaQuery.of(context).size.width * .95,
        height: MediaQuery.of(context).size.height * .28,
        child: 
        Stack(
      children:[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Text("Ingresa el codigo que te proporciono operaciones",style: JunnyText.bluea4(FontWeight.w700, 18),textAlign: TextAlign.center,),
          Container(
            margin: const EdgeInsets.only(top: 18),
            child: TextFormField(
                controller: code,
                keyboardType: TextInputType.number,
                style: TextStyles.blueJ20Bold,
                decoration: InputDecoration(
                  hintText: "Folio",
                  hintStyle: TextStyles.grey20Itw,
                  filled: true,
                  fillColor: JunnyColor.white,
                  contentPadding: const EdgeInsets.only(left: 24),
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderSide: errorCode == ""
                        ? const BorderSide(
                            width: 1, color: ColorsJunghanns.blueJ3)
                        : const BorderSide(width: 1, color: Colors.red),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        width: 2, color: ColorsJunghanns.blueJ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                )),
          ),
          Container(
              padding: const EdgeInsets.only(top: 4, left: 10, bottom: 8),
              child: Text(
                errorCode,
                style: TextStyles.redJ13N,
              )),
          GestureDetector(
      onTap: ()=>widget.getValid(widget.current,code.text),
      child: Container(
        padding: const EdgeInsets.all(6),
          alignment: Alignment.center,
          decoration: Decorations.blueBorder12,
          child: DefaultTextStyle(
              style: TextStyles.white18SemiBold, child: const Text("Validar"))),
    )
        ]),
      ])
        );
  }
}

showCodeAuth(BuildContext context,Function getValid,AuthorizationModel current) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      content: ShowCodeAuth(getValid:getValid,current:current),
    ),
  );
}
