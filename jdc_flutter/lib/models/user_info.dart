import 'package:json_annotation/json_annotation.dart';

part 'user_info.g.dart';

@JsonSerializable()
class UserInfo extends Object {
  @JsonKey(name: 'nickName')
  String nickName;

  @JsonKey(name: 'eid')
  String eid;

  @JsonKey(name: 'timestamp')
  String timestamp;

  @JsonKey(name: 'status')
  int status;

  UserInfo(
    this.nickName,
    this.eid,
    this.timestamp,
    this.status,
  );

  factory UserInfo.fromJson(Map<String, dynamic> srcJson) => _$UserInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}
