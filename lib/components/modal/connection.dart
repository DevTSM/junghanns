import 'package:flutter/material.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';

class ConnectionModal extends StatefulWidget {
  const ConnectionModal({Key? key, required this.setLocalSale})
      : super(key: key);
  final Function setLocalSale;

  @override
  State<StatefulWidget> createState() => _ConnectionModalState();
}

class _ConnectionModalState extends State<ConnectionModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: Decorations.whiteS1Card,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          DefaultTextStyle(
              style: TextStyles.blueJ22Bold,
              child: const Text("Conexión inestable")),
          DefaultTextStyle(
              style: TextStyles.blueJ215R,
              child: const Text(
                "Tu conexión es inestable la venta se guardara de manera local",
                textAlign: TextAlign.center,
              )),
              const SizedBox(height: 10,),
          DefaultTextStyle(
              style: TextStyles.blueJ215R,
              child: const Text(
                "¿Deseas continuar?",
              )),
              const SizedBox(height: 15,),
          Material(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child: ButtonJunghanns(
                      fun: () async {
                        widget.setLocalSale();
                        Navigator.pop(context);
                      },
                      decoration: Decorations.blueBorder12,
                      style: TextStyles.white18SemiBoldIt,
                      label: "Si")),
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
                label: "No",
              )),
            ],
          ))
        ],
      ),
    );
  }
}

showConnection(BuildContext context, Function setLocalSale) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(child: ConnectionModal(setLocalSale: setLocalSale));
      });
}
