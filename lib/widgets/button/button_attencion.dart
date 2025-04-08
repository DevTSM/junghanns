import 'package:flutter/material.dart';

import '../../styles/color.dart';

class CustomButtonAttention extends StatelessWidget {
  final Color color;
  final Color colorDotted;
  final EdgeInsets padding;
  final String label;
  final double width;
  final Function()? onTap;
  final BorderRadius? radius;
  final TextStyle? styleLabel;
  final double? height;
  final IconData? icon;

  const CustomButtonAttention({
    super.key,
    required this.color,
    this.colorDotted = ColorsJunghanns.blueJ,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    required this.label,
    required this.width,
    this.onTap,
    this.radius,
    this.styleLabel,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 50.0,
        decoration: BoxDecoration(
          color: color,
          borderRadius: radius ?? BorderRadius.circular(20),
        ),
        width: width,
        alignment: Alignment.center,
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: styleLabel ??
                  Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: ColorsJunghanns.white,
                    fontSize: 16, fontWeight: FontWeight.bold
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
