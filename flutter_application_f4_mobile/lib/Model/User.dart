class User {
  final int id;
  final String password;
  final String? fullname;
  final String? email;
  final String? phone_number;
  final String? address;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  User({
    required this.id,
    required this.password,
    this.fullname,
    this.email,
    this.phone_number,
    this.address,
    required this.isAdmin,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      password: json['password'] as String,
      fullname: json['fullname'] as String?,
      email: json['email'] as String?,
      phone_number: json['phone_number'] as String?,
      address: json['address'] as String?,
      isAdmin: (json['is_admin'] as int) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }
}