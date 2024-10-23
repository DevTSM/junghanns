import 'package:flutter/material.dart';

import '../../styles/color.dart';

class CustomButtonProduct extends StatelessWidget {
  final VoidCallback onValidate;
  final VoidCallback onReject;
  final String validateText;
  final String rejectText;
  final Color validateColor;
  final Color rejectColor;
  final IconData? validateIcon; // Agregado para icono de validación
  final IconData? rejectIcon;   // Agregado para icono de rechazo

  const CustomButtonProduct({
    required this.onValidate,
    required this.onReject,
    this.validateText = '',
    this.rejectText = '',
    this.validateColor = ColorsJunghanns.blueJ,
    this.rejectColor = ColorsJunghanns.red,
    this.validateIcon,
    this.rejectIcon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onValidate,
            style: ElevatedButton.styleFrom(
              backgroundColor: validateColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  validateText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold, color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(validateIcon, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: onReject,
            style: ElevatedButton.styleFrom(
              backgroundColor: rejectColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  rejectText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold, color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(rejectIcon, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
