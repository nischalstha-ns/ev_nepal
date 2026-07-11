class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] ?? '',
        userId: json['user_id'] ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        type: json['type'] ?? 'info',
        isRead: json['is_read'] == true,
        createdAt: json['created_at'] ?? '',
      );
}
