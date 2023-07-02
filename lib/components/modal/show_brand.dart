

import 'package:flutter/material.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';

class ShowBrand extends StatefulWidget{
  final Function funConfirm;
  final ProviderJunghanns provider;
  final List<Map<String,dynamic>> brands;
  const ShowBrand({super.key,required this.funConfirm,required this.provider,required this.brands});
  
  @override
  State<StatefulWidget> createState()=>_ShowBrandState();
}
class _ShowBrandState extends State<ShowBrand>{
  @override
  Widget build(BuildContext context) {
    return Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              width: MediaQuery.of(context).size.width * .75,
              decoration: Decorations.whiteS1Card,
              child: Material(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DefaultTextStyle(
                      style: TextStyles.blueJ20Bold,
                      textAlign: TextAlign.center,
                      child: const Text("Selecciona la marca del garrafon")),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: Decorations.whiteJCard,
                    padding: const EdgeInsets.only(left: 10,right: 10),
                    width: double.infinity,
                  child:widget.brands.length > 1
                      ? DropdownButton<Map<String,dynamic>>(
                          value: widget.provider.brand,
                          isExpanded: true,
                          underline: Container(),
                          icon: const Icon(Icons.arrow_drop_down_sharp),
                          elevation: 5,
                          onChanged: (Map<String,dynamic>? value) {
                            setState(() {
                              widget.provider.brand = value!;
                            });
                          },
                          items: widget.brands
                              .map<DropdownMenuItem<Map<String,dynamic>>>((Map<String, dynamic> value) {
                            return DropdownMenuItem<Map<String,dynamic>>(
                              value: value,
                              child: Text(value["descripcion"],style: TextStyles.blue18SemiBoldIt,textAlign: TextAlign.center,),
                            );
                          }).toList(),
                        )
                      : widget.brands.isNotEmpty
                          ? Text(widget.brands.first["descripcion"],style: TextStyles.blue18SemiBoldIt,textAlign: TextAlign.center,)
                          : const Text("No se encontraron datos")),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: ButtonJunghanns(
                              fun: () async {
                                Navigator.pop(context);
                                widget.funConfirm();
                              },
                              decoration: Decorations.blueBorder12,
                              style: TextStyles.white18SemiBoldIt,
                              label: "Aceptar")),
                      const SizedBox(
                        width: 25,
                      ),
                      Expanded(
                          child: ButtonJunghanns(
                        fun: () {
                          Navigator.pop(context);
                        },
                        decoration: Decorations.redCard,
                        style: TextStyles.white18SemiBoldIt,
                        label: "Cancelar",
                      )),
                    ],
                  )
                ],
              )),
            ),
          );
  }
  
}
showBrand(BuildContext context,Function funConfirm,ProviderJunghanns provider,List<Map<String,dynamic>> brands) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ShowBrand(funConfirm: funConfirm, provider: provider, brands: brands);
        });
  }