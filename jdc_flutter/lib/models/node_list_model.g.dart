// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeListModel _$NodeListModelFromJson(Map<String, dynamic> json) {
  return NodeListModel(
    json['marginCount'] as int,
    json['allowAdd'] as bool,
    json['allCount'] as int,
    json['client_url'] as String,
    json['client_name'] as String,
    json['activite'] as bool,
  );
}

Map<String, dynamic> _$NodeListModelToJson(NodeListModel instance) => <String, dynamic>{
      'marginCount': instance.marginCount,
      'allowAdd': instance.allowAdd,
      'allCount': instance.allCount,
      'client_url': instance.clientUrl,
      'client_name': instance.clientName,
      'activite': instance.activite,
    };
