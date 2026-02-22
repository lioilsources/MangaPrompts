// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PresetImpl _$$PresetImplFromJson(Map<String, dynamic> json) => _$PresetImpl(
  id: json['id'] as String,
  label: json['label'] as String,
  description: json['description'] as String? ?? '',
  template: json['template'] as String,
  blocks:
      (json['blocks'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
);

Map<String, dynamic> _$$PresetImplToJson(_$PresetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'description': instance.description,
      'template': instance.template,
      'blocks': instance.blocks,
    };
