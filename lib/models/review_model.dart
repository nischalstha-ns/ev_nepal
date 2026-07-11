class Review {
  final String id;
  final String userId;
  final String stationId;
  final int rating;
  final String? comment;
  final String createdAt;
  final String? userName;

  Review({
    required this.id,
    required this.userId,
    required this.stationId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.userName,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] ?? '',
        userId: json['user_id'] ?? '',
        stationId: json['station_id'] ?? '',
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        comment: json['comment'] as String?,
        createdAt: json['created_at'] ?? '',
        userName: json['users'] != null ? json['users']['full_name'] as String? : null,
      );
}
