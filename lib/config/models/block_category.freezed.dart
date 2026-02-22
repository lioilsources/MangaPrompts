// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'block_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BlockCategory _$BlockCategoryFromJson(Map<String, dynamic> json) {
  return _BlockCategory.fromJson(json);
}

/// @nodoc
mixin _$BlockCategory {
  String get category => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  @JsonKey(name: 'required')
  bool get isRequired => throw _privateConstructorUsedError;
  List<Block> get blocks => throw _privateConstructorUsedError;

  /// Serializes this BlockCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BlockCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BlockCategoryCopyWith<BlockCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlockCategoryCopyWith<$Res> {
  factory $BlockCategoryCopyWith(
    BlockCategory value,
    $Res Function(BlockCategory) then,
  ) = _$BlockCategoryCopyWithImpl<$Res, BlockCategory>;
  @useResult
  $Res call({
    String category,
    String label,
    String icon,
    @JsonKey(name: 'required') bool isRequired,
    List<Block> blocks,
  });
}

/// @nodoc
class _$BlockCategoryCopyWithImpl<$Res, $Val extends BlockCategory>
    implements $BlockCategoryCopyWith<$Res> {
  _$BlockCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BlockCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? label = null,
    Object? icon = null,
    Object? isRequired = null,
    Object? blocks = null,
  }) {
    return _then(
      _value.copyWith(
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            isRequired: null == isRequired
                ? _value.isRequired
                : isRequired // ignore: cast_nullable_to_non_nullable
                      as bool,
            blocks: null == blocks
                ? _value.blocks
                : blocks // ignore: cast_nullable_to_non_nullable
                      as List<Block>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BlockCategoryImplCopyWith<$Res>
    implements $BlockCategoryCopyWith<$Res> {
  factory _$$BlockCategoryImplCopyWith(
    _$BlockCategoryImpl value,
    $Res Function(_$BlockCategoryImpl) then,
  ) = __$$BlockCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String category,
    String label,
    String icon,
    @JsonKey(name: 'required') bool isRequired,
    List<Block> blocks,
  });
}

/// @nodoc
class __$$BlockCategoryImplCopyWithImpl<$Res>
    extends _$BlockCategoryCopyWithImpl<$Res, _$BlockCategoryImpl>
    implements _$$BlockCategoryImplCopyWith<$Res> {
  __$$BlockCategoryImplCopyWithImpl(
    _$BlockCategoryImpl _value,
    $Res Function(_$BlockCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BlockCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? label = null,
    Object? icon = null,
    Object? isRequired = null,
    Object? blocks = null,
  }) {
    return _then(
      _$BlockCategoryImpl(
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        isRequired: null == isRequired
            ? _value.isRequired
            : isRequired // ignore: cast_nullable_to_non_nullable
                  as bool,
        blocks: null == blocks
            ? _value._blocks
            : blocks // ignore: cast_nullable_to_non_nullable
                  as List<Block>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BlockCategoryImpl implements _BlockCategory {
  const _$BlockCategoryImpl({
    required this.category,
    required this.label,
    this.icon = 'category',
    @JsonKey(name: 'required') this.isRequired = false,
    final List<Block> blocks = const [],
  }) : _blocks = blocks;

  factory _$BlockCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$BlockCategoryImplFromJson(json);

  @override
  final String category;
  @override
  final String label;
  @override
  @JsonKey()
  final String icon;
  @override
  @JsonKey(name: 'required')
  final bool isRequired;
  final List<Block> _blocks;
  @override
  @JsonKey()
  List<Block> get blocks {
    if (_blocks is EqualUnmodifiableListView) return _blocks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blocks);
  }

  @override
  String toString() {
    return 'BlockCategory(category: $category, label: $label, icon: $icon, isRequired: $isRequired, blocks: $blocks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlockCategoryImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.isRequired, isRequired) ||
                other.isRequired == isRequired) &&
            const DeepCollectionEquality().equals(other._blocks, _blocks));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    category,
    label,
    icon,
    isRequired,
    const DeepCollectionEquality().hash(_blocks),
  );

  /// Create a copy of BlockCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BlockCategoryImplCopyWith<_$BlockCategoryImpl> get copyWith =>
      __$$BlockCategoryImplCopyWithImpl<_$BlockCategoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BlockCategoryImplToJson(this);
  }
}

abstract class _BlockCategory implements BlockCategory {
  const factory _BlockCategory({
    required final String category,
    required final String label,
    final String icon,
    @JsonKey(name: 'required') final bool isRequired,
    final List<Block> blocks,
  }) = _$BlockCategoryImpl;

  factory _BlockCategory.fromJson(Map<String, dynamic> json) =
      _$BlockCategoryImpl.fromJson;

  @override
  String get category;
  @override
  String get label;
  @override
  String get icon;
  @override
  @JsonKey(name: 'required')
  bool get isRequired;
  @override
  List<Block> get blocks;

  /// Create a copy of BlockCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BlockCategoryImplCopyWith<_$BlockCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
