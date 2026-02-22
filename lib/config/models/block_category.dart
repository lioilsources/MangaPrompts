import 'package:freezed_annotation/freezed_annotation.dart';
import 'block.dart';

part 'block_category.freezed.dart';
part 'block_category.g.dart';

@freezed
class BlockCategory with _$BlockCategory {
  // ignore: invalid_annotation_target
  const factory BlockCategory({
    required String category,
    required String label,
    @Default('category') String icon,
    @Default(false) @JsonKey(name: 'required') bool isRequired,
    @Default([]) List<Block> blocks,
  }) = _BlockCategory;

  factory BlockCategory.fromJson(Map<String, dynamic> json) =>
      _$BlockCategoryFromJson(json);
}
