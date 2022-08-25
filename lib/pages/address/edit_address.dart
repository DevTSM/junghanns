import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:junghanns/styles/color.dart';

class EditAddress extends StatefulWidget {
  EditAddress(
      {required this.lat,required this.lng});
      double lat,lng;
  _EditAddressState createState() => _EditAddressState();
}

class _EditAddressState extends State<EditAddress> {
  late GoogleMapController _mapController;
  late Position _currentLocation;
  late List<Marker> _lista;
  late Size size;
  @override
  void initState() {
    super.initState();
    _currentLocation=Position(altitude: 1,longitude: widget.lng, accuracy: 1, heading: 1, latitude: widget.lat, speed: 1, speedAccuracy: 1, timestamp: DateTime.now(),);
    _lista = [];
    setState(() {
      if(widget.lat!=0&&widget.lng!=0){
    _lista.add(Marker(
          markerId: const MarkerId('1'),
          infoWindow: const InfoWindow(
              title: 'Cliente',),
          position: LatLng(widget.lat, widget.lng),
          icon: BitmapDescriptor.defaultMarker));
      }
          });
    setCurrentLocation();
  }
  setCurrentLocation() async {
    _currentLocation = await Geolocator.getCurrentPosition();
    if (_currentLocation != null) {
      CameraPosition camara = CameraPosition(
        bearing: 0,
        target: LatLng(_currentLocation.latitude, _currentLocation.longitude),
        zoom: 13.0,
      );

      _mapController.moveCamera(CameraUpdate.newCameraPosition(camara));
      setState(() {
      _lista.add(Marker(
          markerId: const MarkerId('2'),
          infoWindow: const InfoWindow(
              title: 'Tu',),
          position: LatLng(_currentLocation.latitude, _currentLocation.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)));
          });
    }
  }
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setCurrentLocation();
  }
  @override
  Widget build(BuildContext context) {
    setState(() {
      size = MediaQuery.of(context).size;
    });
    return Scaffold(
    body:Stack(
      children: [
        mapa(),
        pin()
      ],
    ));
  }
  
  Widget pin() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 45, left: 2),
        child: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back,color: ColorsJunghanns.blue,size: 35,))
      ),
    );
  }

  Widget mapa() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentLocation.latitude, _currentLocation.longitude),
        zoom: 10,
      ),
      markers: {
        for (int i = 0; i < _lista.length; i++) _lista[i],
      },
      onMapCreated: _onMapCreated,
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
    );
  }
}
