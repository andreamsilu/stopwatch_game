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
    final msisdn = json['msisdn'] as String;
    final username = json['username'];

    return UserModel(
      id: (json['id'] as num).toInt(),
      msisdn: msisdn,
      username: username is String && username.isNotEmpty ? username : msisdn,
      channelSource: json['channelSource'] as String? ?? 'APP',
      status: json['status'] as String? ?? 'active',
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'msisdn': msisdn,
    'username': username,
    'channelSource': channelSource,
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    if (lastLoginAt != null) 'lastLoginAt': lastLoginAt,
  };
}
