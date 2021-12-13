import 'package:json_annotation/json_annotation.dart';

part 'node_list_model.g.dart';

@JsonSerializable()
class NodeListModel extends Object {
  @JsonKey(name: 'marginCount')
  int marginCount;

  @JsonKey(name: 'allowAdd')
  bool allowAdd;

  @JsonKey(name: 'allCount')
  int allCount;

  @JsonKey(name: 'client_url')
  String clientUrl;

  @JsonKey(name: 'client_name')
  String clientName;

  @JsonKey(name: 'activite')
  bool activite;

  NodeListModel(
    this.marginCount,
    this.allowAdd,
    this.allCount,
    this.clientUrl,
    this.clientName,
    this.activite,
  );

  factory NodeListModel.fromJson(Map<String, dynamic> srcJson) => _$NodeListModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$NodeListModelToJson(this);
}
