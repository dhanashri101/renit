import 'package:rentit24/config/api_config.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.isVerified,
    required this.about,
    required this.profileUrl,
    required this.followersCount,
    required this.followingCount,
    this.joinedAt,
  });

  final int id;
  final String username;
  final String email;
  final String phoneNumber;
  final bool isVerified;
  final String about;
  final String profileUrl;
  final int followersCount;
  final int followingCount;
  final DateTime? joinedAt;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    int integer(dynamic value) => value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '') ?? 0;
    bool boolean(dynamic value) => value == true ||
        value == 1 ||
        value?.toString().toLowerCase() == 'true';

    return UserProfileModel(
      id: integer(json['id']),
      username: (json['username'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      phoneNumber: (json['phone_number'] ?? json['phoneNumber'] ?? '')
          .toString()
          .trim(),
      isVerified: boolean(json['is_verified'] ?? json['isVerified']),
      about: (json['aboutme'] ?? json['about'] ?? '').toString().trim(),
      profileUrl: ApiConfig.resolveMediaUrl(
        (json['profile_url'] ?? json['profileUrl'])?.toString(),
      ),
      followersCount: integer(json['followers_count'] ?? json['followersCount']),
      followingCount: integer(json['following_count'] ?? json['followingCount']),
      joinedAt: DateTime.tryParse((json['joined_at'] ?? '').toString()),
    );
  }
}
