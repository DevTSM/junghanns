
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FullScreenMap extends StatelessWidget {
  final double latitude;
  final double longitude;

  const FullScreenMap({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación Completa'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 14,
        ),
        markers: {
          Marker(
            markerId: MarkerId("Ubicación"),
            position: LatLng(latitude, longitude),
          ),
        },
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        scrollGesturesEnabled: true,
        rotateGesturesEnabled: true,
        tiltGesturesEnabled: true,
      ),
    );
  }
}
