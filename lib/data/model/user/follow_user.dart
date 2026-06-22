import 'package:eClassify/utils/json_helper.dart';

class FollowUser {
  FollowUser.fromJson(Json json)
    : id = json['id'] as int,
      name = json['name'] as String,
      email = json['email'] as String?,
      mobile = json['mobile'] as String?,
      profile = json['profile'] as String?,
      isFollowing = json['is_following'] as int == 1;

  final int id;
  final String name;
  final String? email;
  final String? mobile;
  final String? profile;
  final bool isFollowing;
}
