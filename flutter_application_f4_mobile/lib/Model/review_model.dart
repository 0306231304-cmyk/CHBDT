class Review {
  final int id;
  final String userName;
  final String content;
  final double rating;
  final String createdAt;
  final String? avatarUrl;

  Review({
    required this.id,
    required this.userName,
    required this.content,
    required this.rating,
    required this.createdAt,
    this.avatarUrl,
  });

    factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      // Lấy tên từ object 'user' nếu Backend trả về lồng nhau
      userName: json['user']?['name'] ?? json['user_name'] ?? 'Người dùng', 
      content: json['content'] ?? '',
      rating: double.tryParse(json['rating'].toString()) ?? 5.0,
      createdAt: json['created_at'] ?? '',
      avatarUrl: json['user']?['avatar_url'],
    );
  }
}