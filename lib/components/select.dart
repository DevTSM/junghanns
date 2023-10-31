import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';

class ShowBrand extends StatefulWidget {
  Function onTap;
  Function cancel;
  List<Map<String, dynamic>> items;
  Map<String, dynamic> current;
  ShowBrand(
      {super.key,
      required this.onTap,
      required this.cancel,
      required this.items,
      required this.current});

  @override
  State<StatefulWidget> createState() => _ShowBrandState();
}

class _ShowBrandState extends State<ShowBrand> {
  late Size size;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        width: size.width * .75,
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
                padding: const EdgeInsets.only(left: 10, right: 10),
                width: double.infinity,
                child: widget.items.length > 1
                    ? DropdownButton<Map<String, dynamic>>(
                        value: widget.current,
                        isExpanded: true,
                        underline: Container(),
                        icon: const Icon(Icons.arrow_drop_down_sharp),
                        elevation: 5,
                        onChanged: (Map<String, dynamic>? value) {
                          setState(() {
                            widget.current = value!;
                          });
                        },
                        items: widget.items
                            .map<DropdownMenuItem<Map<String, dynamic>>>(
                                (Map<String, dynamic> value) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: value,
                            child: Text(
                              value["descripcion"],
                              style: TextStyles.blue18SemiBoldIt,
                              textAlign: TextAlign.center,
                            ),
                          );
                        }).toList(),
                      )
                    : widget.items.isNotEmpty
                        ? Text(
                            widget.items.first["descripcion"],
                            style: TextStyles.blue18SemiBoldIt,
                            textAlign: TextAlign.center,
                          )
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
                        },
                        decoration: Decorations.blueBorder12,
                        style: TextStyles.white18SemiBoldIt,
                        label: "Aceptar")),
                const SizedBox(
                  width: 25,
                ),
                Expanded(
                    child: ButtonJunghanns(
                  fun: widget.cancel,
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

selectMap(BuildContext context, Function onChange,
    List<Map<String, dynamic>> items, Map<String, dynamic> current,
    {Function? cancel,BoxDecoration? decoration,TextStyle? style}) {
  return Container(
    decoration: decoration??Decorations.blueOpacity(.1, 16) ,
    padding: const EdgeInsets.only(left: 10, right: 10),
    width: double.infinity,
    child: items.length > 1
      ? DropdownButton<Map<String, dynamic>>(
        value: current,
        isExpanded: true,
        underline: Container(),
        icon: const Icon(
          FontAwesomeIcons.caretDown,
          color: ColorsJunghanns.blue,
        ),
        elevation: 30,
        onChanged: (Map<String, dynamic>? value) => onChange(value),
        items: items.map<DropdownMenuItem<Map<String, dynamic>>>(
          (Map<String, dynamic> value) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: value,
              child: Text(
                value["descripcion"],
                style: style??TextStyles.blue18SemiBoldIt,
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
      )
      : items.isNotEmpty
        ? Text(
          items.first["descripcion"],
          style: style??TextStyles.blue18SemiBoldIt,
          textAlign: TextAlign.center,
        )
        : const Text("No se encontraron datos")
  );
}

