import 'package:flutter/material.dart';
import '../styles/color.dart';

class CustomButtonDelivery extends StatelessWidget {
  final Function()? onValidate;
  final String validateText;
  final Color validateColor;
  final Widget icon;

  const CustomButtonDelivery({
    required this.onValidate,
    this.validateText = '',
    this.validateColor = ColorsJunghanns.blueJ,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onValidate,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled)) {
                    return ColorsJunghanns.grey;
                  }
                  return validateColor;
                },
              ),
              foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled)) {
                    return Colors.white;
                  }
                  return Colors.white;
                },
              ),
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(vertical: 15),
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  validateText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                icon,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
