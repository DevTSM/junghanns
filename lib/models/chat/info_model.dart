class InfoModel {
  final bool received;  // Equivalent to 'recibido'
  final bool read;      // Equivalent to 'leido'

  InfoModel({
    required this.received,
    required this.read,
  });

  factory InfoModel.fromJson(Map<String, dynamic> json) {
    return InfoModel(
      received: json['recibido'] ?? false,  // Manejo de valores nulos
      read: json['leido'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recibido': received,
      'leido': read,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
