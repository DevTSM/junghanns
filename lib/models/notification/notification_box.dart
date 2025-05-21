class NotificationBox {
  final int id;
  final DateTime createdAt;
  final String title;
  final String body;
  final String status;
  final String serial;
  final String model;
  final bool read;

  NotificationBox({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.body,
    required this.status,
    required this.serial,
    required this.model,
    required this.read,
  });

  factory NotificationBox.fromJson(Map<String, dynamic> json) {
    return NotificationBox(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      title: json['title'],
      body: json['body'],
      status: json['estatus'],
      serial: json['serial'],
      model: json['model'],
      read: json['leido'].toString().toUpperCase() == 'SI',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'title': title,
      'body': body,
      'estatus': status,
      'serial': serial,
      'model': model,
      'leido': read ? 'YES' : 'NO',
    };
  }

  @override
  String toString() {
    return 'NotificationBox(id: $id, createdAt: $createdAt, title: $title, read: $read)';
  }

}

// Para parsear una lista de notificaciones desde JSON:
List<NotificationBox> parseNotifications(List<dynamic> jsonList) {
  return jsonList.map((json) => NotificationBox.fromJson(json)).toList();
}

