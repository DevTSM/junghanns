class NotificationData {
  final String title;
  final String message;
  final String? timestamp;      // Timestamp opcional

  NotificationData({
    required this.title,
    required this.message,
    this.timestamp,
  });

  // Método para mapear el JSON recibido al modelo de datos.
  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      title: json['title'] ?? 'Sin título',
      message: json['message'] ?? 'Sin mensaje',
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'timestamp': timestamp,
    };
  }
}