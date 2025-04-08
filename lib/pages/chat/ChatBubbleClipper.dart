import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../styles/color.dart';

class ChatBubbleTail extends CustomPainter {
  final bool isMe;

  ChatBubbleTail({required this.isMe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = isMe ? Colors.lightBlue : ColorsJunghanns.blueT;
    final path = Path();

    if (isMe) {
      // Colita más larga a la derecha
      path.moveTo(size.width, 0);
      path.lineTo(size.width * 0.3, size.height); // Hacemos la base más larga
      path.lineTo(25, size.height); // Asegura que el pico sea más largo
    } else {
      // Colita más larga a la izquierda
      path.moveTo(0, 0);
      path.lineTo(size.width * 0.7, size.height); // Hacemos la base más larga
      path.lineTo(-8, size.height); // Ajuste para que la punta sea más pronunciada
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
