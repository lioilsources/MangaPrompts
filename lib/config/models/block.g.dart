// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BlockImpl _$$BlockImplFromJson(Map<String, dynamic> json) => _$BlockImpl(
  id: json['id'] as String,
  label: json['label'] as String,
  value: json['value'] as String,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  mood:
      (json['mood'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  incompatible:
      (json['incompatible'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$BlockImplToJson(_$BlockImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'value': instance.value,
      'tags': instance.tags,
      'mood': instance.mood,
      'incompatible': instance.incompatible,
    };
