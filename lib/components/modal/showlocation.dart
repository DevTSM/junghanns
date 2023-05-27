import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:junghanns/components/button.dart';
import 'package:junghanns/models/transfer.dart';
import 'package:junghanns/styles/color.dart';
import 'package:junghanns/styles/decoration.dart';
import 'package:junghanns/styles/text.dart';

class ShowLocation extends StatelessWidget {
  final Function update;
  final double lat, lng;
  ShowLocation(
      {Key? key, required this.update, required this.lat, required this.lng})
      : super(key: key);
  late CameraPosition _initialPosition =
      CameraPosition(target: LatLng(lat, lng), zoom: 20);
  late GoogleMapController _controller;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: Decorations.whiteBorder12,
        width: MediaQuery.of(context).size.width * .95,
        height: MediaQuery.of(context).size.height * .5,
        child: Stack(children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialPosition,
            zoomControlsEnabled: false,
            markers: {
              Marker(

                markerId: const MarkerId("marker1"),
                position: LatLng(lat, lng),
                onDragEnd: (value) {},
              ),
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 40,
              child:ButtonJunghanns(
                fun: () {
                  log("Fun update location =====> $lat $lng");
                  update();
                },
                decoration: Decorations.blueBorder12,
                style: TextStyles.white14SemiBold,
                label: "Actualizar ubicación")),
          )
        ]));
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }
}

showLocation(BuildContext context, Function update, double lat, double lng) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      content: ShowLocation(update: update, lat: lat, lng: lng),
    ),
  );
}
