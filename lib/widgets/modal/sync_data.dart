import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:junghanns/pages/drawer/reception_of_products.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:provider/provider.dart';

import '../../styles/color.dart';
import '../../util/navigator.dart';
import '../button/button_attencion.dart';

void showSyncDataModal(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding: const EdgeInsets.all(18),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Icon(
                FontAwesomeIcons.sync,
                size: 40.0,
                color: ColorsJunghanns.blueJ,
              ),
              const SizedBox(height: 15),
              Text(
                "SINCRONIZAR",
                style: Theme.of(context).textTheme.headlineSmall!
                    .copyWith(fontSize: 19, color: JunnyColor.black, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                'Con el fin de garantizar un proceso sin contratiempos, se sugiere sincronizar los datos antes de la entrega.',
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: CustomButtonAttention(
                  /*onTap: () => Navigator.pushAndRemoveUntil(
                    navigatorKey.currentContext!,
                    MaterialPageRoute(builder: (context) => const ReceptionOfProducts()),
                        (route) => false,
                  ),*/
                  /*onTap: () => Navigator.pop(context),*/
                  onTap: () async {
                    // Obtén el provider y llama a la función
                    final provider = Provider.of<ProviderJunghanns>(context, listen: false);
                    await provider.synchronizeListDelivery();
                    Navigator.pop(context); // Cierra el diálogo después de sincronizar
                  },
                  color: ColorsJunghanns.blueJ,
                  label: "SI, ADELANTE",
                  width: double.infinity,
                  colorDotted: ColorsJunghanns.white,
                  radius: const BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
