import 'package:freezed_annotation/freezed_annotation.dart';

part 'preset.freezed.dart';
part 'preset.g.dart';

@freezed
class Preset with _$Preset {
  const factory Preset({
    required String id,
    required String label,
    @Default('') String description,
    required String template,
    @Default({}) Map<String, String> blocks,
  }) = _Preset;

  factory Preset.fromJson(Map<String, dynamic> json) =>
      _$PresetFromJson(json);
}
