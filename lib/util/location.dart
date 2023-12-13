import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationJunny{
  Position _currentLocation = Position(
    altitudeAccuracy: 1,
    headingAccuracy: 1,
    altitude: 1,
    longitude: 0, 
    accuracy: 1, 
    heading: 1, 
    latitude: 0, 
    speed: 1, 
    speedAccuracy: 1, 
    timestamp: DateTime.now()
  );
Future<Position?>getCurrentLocation() async {
  await Geolocator.requestPermission();
  LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _currentLocation = await Geolocator.getCurrentPosition();
    if (_currentLocation != null) {
      CameraPosition camara = CameraPosition(
        bearing: 0,
        target: LatLng(_currentLocation.latitude, _currentLocation.longitude),
        zoom: 13.0,
      );
      return _currentLocation;
    }else{
      return _currentLocation;
    }
    }else{
      return null;
      }
    
  }
  
}