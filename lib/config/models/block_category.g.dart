// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BlockCategoryImpl _$$BlockCategoryImplFromJson(Map<String, dynamic> json) =>
    _$BlockCategoryImpl(
      category: json['category'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String? ?? 'category',
      isRequired: json['required'] as bool? ?? false,
      blocks:
          (json['blocks'] as List<dynamic>?)
              ?.map((e) => Block.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$BlockCategoryImplToJson(_$BlockCategoryImpl instance) =>
    <String, dynamic>{
      'category': instance.category,
      'label': instance.label,
      'icon': instance.icon,
      'required': instance.isRequired,
      'blocks': instance.blocks,
    };
