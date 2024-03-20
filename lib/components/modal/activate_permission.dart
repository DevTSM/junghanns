import 'package:flutter/material.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';
import 'package:permission_handler/permission_handler.dart';

class ActivatePermissionDialog extends StatelessWidget {
  final List<Permission> permission;
  const ActivatePermissionDialog({super.key,required this.permission});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Servicio de ubicación no disponible',
            style: JunnyText.bluea4(FontWeight.normal, 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Para continuar es necesario proporcionar los permisos de:',
            style: JunnyText.bluea4(FontWeight.w400, 16).copyWith(
               fontFamily: 'MyriadPro-SemiBold'
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          const SizedBox(height: 5),
          Text(
            'Ve a Configuración > Apps > Junny > Permisos',
            style: JunnyText.bluea4(FontWeight.w400, 16).copyWith(
               fontFamily: 'MyriadPro-it'
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          ButtonJunghanns(
            fun: ()=> Navigator.pop(context), 
            decoration: JunnyDecoration.orange255(50).copyWith(
              color: JunnyColor.blueA1
            ), 
            style: JunnyText.bluea4(FontWeight.normal, 16).copyWith(
              color: JunnyColor.white
            ), 
            label: 'Aceptar'
          )
        ]
        ..insertAll(4, 
          permission.map((e) => 
            Text(
              '* ${getLabelPermission(permission: e)
              }',
              style: JunnyText.bluea4(FontWeight.w400, 16).copyWith(
                fontFamily: 'MyriadPro-SemiBold'
              ),
            )
          )
        )
      ),
    );
  }
  String getLabelPermission({required Permission permission}){
    switch (permission.toString()){
      case 'Permission.location': 
        return "Ubicación";
      case 'Permission.notification':
        return "Notificaciones";
      default:
        return "Ubicación al usar la app";
    }
  }
}

showActivatePermission(
  {
    required BuildContext context,
    required List<Permission> permission
  }
) {
  showDialog(
    context: context,
    builder: (BuildContext context)=> 
      AlertDialog(
        backgroundColor: JunnyColor.white,
        content: ActivatePermissionDialog(permission: permission)
      ),
      //const Center(child: Material(child:ActivatePermissionDialog()))
  );
}
