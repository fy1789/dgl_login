// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) {
  return UserInfo(
    json['nickName'] as String,
    json['eid'] as String,
    json['timestamp'] as String,
    json['status'] as int,
  );
}

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) =>
    <String, dynamic>{'nickName': instance.nickName, 'eid': instance.eid, 'timestamp': instance.timestamp, 'status': instance.status};
