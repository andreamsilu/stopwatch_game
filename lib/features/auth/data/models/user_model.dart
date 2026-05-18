class UserModel {
  const UserModel({
    required this.id,
    required this.msisdn,
    required this.username,
    required this.channelSource,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      msisdn: json['msisdn'] as String,
      username: json['username'] as String,
      channelSource: json['channelSource'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      lastLoginAt: json['lastLoginAt'] as String?,
    );
  }

  final int id;
  final String msisdn;
  final String username;
  final String channelSource;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? lastLoginAt;
}
