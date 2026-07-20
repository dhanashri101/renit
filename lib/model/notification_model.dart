class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.createdAt,
  });

  final int id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    return NotificationModel(
      id: toInt(json['id'] ?? json['msgId']),
      title: (json['title'] ?? '').toString().trim(),
      body: (json['body'] ?? json['message'] ?? '').toString().trim(),
      isRead: json['is_read'] == true || json['isRead'] == true,
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()),
    );
  }
}
