import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapaUbicacionActual extends StatefulWidget {
  final double? destinoLat;
  final double? destinoLon;

  const MapaUbicacionActual({
    super.key,
    this.destinoLat,
    this.destinoLon,
  });

  @override
  State<MapaUbicacionActual> createState() => _MapaUbicacionActualState();
}

class _MapaUbicacionActualState extends State<MapaUbicacionActual> {
  LatLng? _currentPosition;
  GoogleMapController? _controller;
  double? _distanciaEnKm;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      if (widget.destinoLat != null && widget.destinoLon != null) {
        double distanceMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          widget.destinoLat!,
          widget.destinoLon!,
        );

        setState(() {
          _distanciaEnKm = distanceMeters / 1000;
        });

        await Future.delayed(const Duration(milliseconds: 400));
        final bounds = LatLngBounds(
          southwest: LatLng(
            min(position.latitude, widget.destinoLat!),
            min(position.longitude, widget.destinoLon!),
          ),
          northeast: LatLng(
            max(position.latitude, widget.destinoLat!),
            max(position.longitude, widget.destinoLon!),
          ),
        );
        _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Marker> markers = [];
    final List<LatLng> polylinePoints = [];

    markers.add(
      Marker(
        markerId: const MarkerId('origen'),
        position: _currentPosition!,
        infoWindow: const InfoWindow(title: 'Tu ubicación'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    if (widget.destinoLat != null && widget.destinoLon != null) {
      final destino = LatLng(widget.destinoLat!, widget.destinoLon!);

      markers.add(
        Marker(
          markerId: const MarkerId('destino'),
          position: destino,
          infoWindow: const InfoWindow(title: 'Validación pendiente'),
          icon:
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );

      polylinePoints.add(_currentPosition!);
      polylinePoints.add(destino);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 250,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: 15,
            ),
            markers: Set<Marker>.from(markers),
            polylines: polylinePoints.length == 2
                ? {
              Polyline(
                polylineId: const PolylineId("trayectoria"),
                color: Colors.blue,
                width: 4,
                points: polylinePoints,
              ),
            }
                : {},
            onMapCreated: (controller) => _controller = controller,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
          ),
        ),
        if (_distanciaEnKm != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              "Distancia: ${_distanciaEnKm!.toStringAsFixed(2)} km",
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
