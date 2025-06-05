import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junghanns/models/notification/notification_box.dart';
import 'package:junghanns/provider/provider.dart';
import 'package:junghanns/styles/color.dart';
import 'package:provider/provider.dart';

class ShowNotificationBox extends StatefulWidget {
  final NotificationBox current;
  const ShowNotificationBox({Key? key, required this.current}) : super(key: key);

  @override
  State<ShowNotificationBox> createState() => _ShowNotificationBoxState();
}

class _ShowNotificationBoxState extends State<ShowNotificationBox> {
  late bool _read;

  @override
  void initState() {
    super.initState();
    _read = widget.current.read;
  }

  Future<void> _handleButtonPress() async {
    if (!_read) {
      final provider = Provider.of<ProviderJunghanns>(context, listen: false);
      await provider.readAndReceived(
        id: widget.current.id.toString(),
        delivered: 'E',
        readed: 'S',
      );
      await provider.getNotificationBox();

      setState(() {
        _read = true;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: JunnyColor.green24,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(3),
                bottomRight: Radius.circular(3)
              ),
            ),
            child: const Text(
              'Detalle de Notificación',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.current.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.current.body,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  //textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 7),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DateFormat('yyyy-MM-dd | HH:mm:ss').format(widget.current.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 45),

                // Botón
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleButtonPress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _read ? Colors.grey : JunnyColor.bluea4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                    ),
                    child: Text(
                      _read ? 'CERRAR' : 'MARCAR COMO LEÍDO',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
showNotificationBox(BuildContext context, NotificationBox current) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      content: ShowNotificationBox(current: current),
    ),
  );
}
