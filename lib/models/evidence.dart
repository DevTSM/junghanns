class Evidence {
  final String idRuta;
  final String idCliente;
  final String tipo;
  final String cantidad;
  final double lat;
  final double lon;
  final int idAutorization;
  final String filePath;
  final bool isUploaded;

  Evidence({
    required this.idRuta,
    required this.idCliente,
    required this.tipo,
    required this.cantidad,
    required this.lat,
    required this.lon,
    required this.idAutorization,
    required this.filePath,
    required this.isUploaded,
  });
}
