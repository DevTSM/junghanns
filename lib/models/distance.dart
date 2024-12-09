class DistanceModel {
  int allowedDistance;
  double lat;
  double long;

  DistanceModel({
    required this.allowedDistance,
    required this.lat,
    required this.long,
  });

  factory DistanceModel.empty() {
    return DistanceModel(
      allowedDistance: 0,
      lat: 0,
      long: 0,
    );
  }

  factory DistanceModel.from(Map<String, dynamic> data) {
    return DistanceModel(
      allowedDistance: int.parse((data["distancia_permitida"] ?? 0).toString()),
      lat: double.parse((data["latitud"] ?? 0).toString()),
      long: double.parse((data["longitud"] ?? 0).toString()),
    );
  }

  @override
  String toString() {
    return 'DistanceModel(distancia_permitida: $allowedDistance, latitud: $lat, longitud: $long)';
  }
}