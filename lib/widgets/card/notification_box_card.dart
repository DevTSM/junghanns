import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/models/notification/notification_box.dart';
import 'package:junghanns/styles/color.dart';

import '../../components/modal/shownotificationbox.dart';

class NotificationBoxCard extends StatelessWidget {
  final NotificationBox current;
  const NotificationBoxCard({required this.current});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showNotificationBox(context, current),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: current.read ? Colors.grey.shade300 : ColorsJunghanns.blueJ,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.notifications,
                  color: current.read ? Colors.white : Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 15),

            // Contenido del mensaje
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Opacity(
                          opacity: current.read ? 0.5 : 1.0,
                          child: Text(
                            current.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm:ss').format(current.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    current.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: current.read
                          ? Colors.grey.shade600
                          : ColorsJunghanns.blueJ,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}