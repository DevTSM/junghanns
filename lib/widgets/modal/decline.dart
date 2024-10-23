import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../styles/color.dart';
import '../../util/location.dart';
import '../button/button_attencion.dart';

class DeclineProduct extends StatefulWidget {
  final Function(String) onReject;

  DeclineProduct({required this.onReject, super.key});

  @override
  State<StatefulWidget> createState() => _DeclineProductState();
}

class _DeclineProductState extends State<DeclineProduct> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController description = TextEditingController();
  String error = '';
  bool _isSubmitting = false;

  Future<void> _cancel() async {
    setState(() {
      if (description.text.isEmpty) {
        error = "Campo obligatorio";
      } else if (description.text.length < 20) {
        error = "La descripción debe tener al menos 20 caracteres";
      } else {
        error = "";
      }
    });
    if (error.isEmpty) {
      Position? position = (await LocationJunny().getCurrentLocation())! /*await LocationService().getCurrentLocation()*/;
      if (position != null) {
        setState(() {
          _isSubmitting = true;
        });
        widget.onReject(description.text);
        setState(() {
          _isSubmitting = false;
        });
        Navigator.pop(context);
      }
    }
  }

  Widget _sufixLabel(String? label, {bool sufix = false}) {
    return label != null
        ? Container(
        margin: EdgeInsets.only(
            top: sufix ? 10 : 0,
            bottom: sufix ? 0 : 10,
            left: 10,
            right: 10),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ))
        : const SizedBox.shrink();
  }

  Widget _buttons(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity,
              child: CustomButtonAttention(
                onTap: _cancel,
                color: ColorsJunghanns.blueJ,
                label: _isSubmitting ? "SI, ADELANTE" : "SI, ADELANTE",
                colorDotted: ColorsJunghanns.white,
                radius: BorderRadius.circular(10),
                width: double.infinity,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: CustomButtonAttention(
              onTap: () => Navigator.pop(context),
              color: ColorsJunghanns.red,
              label: "NO, CANCELAR",
              width: double.infinity,
              colorDotted: ColorsJunghanns.white,
              radius: const BorderRadius.all(Radius.circular(10)),
              icon: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: ColorsJunghanns.grey.withOpacity(0.10)),
      child: TextFormField(
        controller: description,
        keyboardType: TextInputType.text,
        maxLines: 5,
        decoration: InputDecoration(
          filled: true,
          fillColor: ColorsJunghanns.grey.withOpacity(0.10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          hintText: "Rechazado por ...",
          hintStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          labelStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: Colors.grey[700],
            fontWeight: FontWeight.normal,
          ),
        ),
        style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: ColorsJunghanns.blueJ, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width * .9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Icon(Icons.cancel_outlined, size: 40, color: ColorsJunghanns.red),
            const SizedBox(height: 5),
            Text(
              "Rechazo",
              style: Theme.of(context).textTheme.headlineSmall!
                  .copyWith(color: ColorsJunghanns.blueJ, fontWeight: FontWeight.bold,),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            _sufixLabel("Ingresa un motivo o describe brevemente la razón por la cual realiza el rechazo"),
            _textField(),
            Visibility(
                visible: error != '',
                child: Text(
                    error,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: ColorsJunghanns.red, fontSize: 16)
                )
            ),
            const SizedBox(height: 15),
            _buttons(context),
          ],
        ),
      ),
    );
  }
}

void showDeclineProduct({required BuildContext context, required Function(String) onReject}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.only(top: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: DeclineProduct(onReject: onReject)),
  );
}
