// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PromptTemplateImpl _$$PromptTemplateImplFromJson(Map<String, dynamic> json) =>
    _$PromptTemplateImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      description: json['description'] as String? ?? '',
      slotOrder: (json['slot_order'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      negativeSlot: json['negative_slot'] as String? ?? 'negative',
      separator: json['separator'] as String? ?? ', ',
      requiredSlots:
          (json['required_slots'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      optionalSlots:
          (json['optional_slots'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PromptTemplateImplToJson(
  _$PromptTemplateImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'description': instance.description,
  'slot_order': instance.slotOrder,
  'negative_slot': instance.negativeSlot,
  'separator': instance.separator,
  'required_slots': instance.requiredSlots,
  'optional_slots': instance.optionalSlots,
};
