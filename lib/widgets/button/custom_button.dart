import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../../styles/color.dart';


class CustomButton extends StatelessWidget{

  final Color color;
  final Color colorDotted;
  final EdgeInsets padding;
  final String label;
  final double width;
  final Function ()? onTap;
  final BorderRadius? radius;
  final TextStyle? styleLabel;
  final double? height;
  const CustomButton(
      {
        super.key,
        required this.color,
        this.colorDotted = ColorsJunghanns.blueJ,
        this.padding = const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
        required this.label,
        required this.width,
        this.onTap,
        this.radius,
        this.styleLabel,
        this.height
      }
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
          dashPattern: const <double>[3, 6],
          strokeWidth: 1.5,
          strokeCap: StrokeCap.round,
          radius: const Radius.circular(20),
          color: colorDotted,
          child: Container(
            decoration: BoxDecoration(
                color: color,
                borderRadius: radius
            ),
            width: width,
            alignment: Alignment.center,
            padding: padding,
            child: Text(
                label,
                style: styleLabel ?? Theme.of(context).textTheme.bodyLarge
                !.copyWith(color: ColorsJunghanns.white, fontWeight: FontWeight.bold)
            ),
          )
      ),
    );
  }
}