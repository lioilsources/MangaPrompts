import 'package:freezed_annotation/freezed_annotation.dart';

part 'block.freezed.dart';
part 'block.g.dart';

@freezed
class Block with _$Block {
  const factory Block({
    required String id,
    required String label,
    required String value,
    @Default([]) List<String> tags,
    @Default([]) List<String> mood,
    @Default([]) List<String> incompatible,
  }) = _Block;

  factory Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);
}
