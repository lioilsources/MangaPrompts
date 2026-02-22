import 'package:freezed_annotation/freezed_annotation.dart';

part 'prompt_template.freezed.dart';
part 'prompt_template.g.dart';

@freezed
class PromptTemplate with _$PromptTemplate {
  // ignore: invalid_annotation_target
  const factory PromptTemplate({
    required String id,
    required String label,
    @Default('') String description,
    @JsonKey(name: 'slot_order') required List<String> slotOrder,
    @JsonKey(name: 'negative_slot') @Default('negative') String negativeSlot,
    @Default(', ') String separator,
    @JsonKey(name: 'required_slots') @Default([]) List<String> requiredSlots,
    @JsonKey(name: 'optional_slots') @Default([]) List<String> optionalSlots,
  }) = _PromptTemplate;

  factory PromptTemplate.fromJson(Map<String, dynamic> json) =>
      _$PromptTemplateFromJson(json);
}
