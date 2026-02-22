// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Preset _$PresetFromJson(Map<String, dynamic> json) {
  return _Preset.fromJson(json);
}

/// @nodoc
mixin _$Preset {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get template => throw _privateConstructorUsedError;
  Map<String, String> get blocks => throw _privateConstructorUsedError;

  /// Serializes this Preset to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Preset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PresetCopyWith<Preset> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PresetCopyWith<$Res> {
  factory $PresetCopyWith(Preset value, $Res Function(Preset) then) =
      _$PresetCopyWithImpl<$Res, Preset>;
  @useResult
  $Res call({
    String id,
    String label,
    String description,
    String template,
    Map<String, String> blocks,
  });
}

/// @nodoc
class _$PresetCopyWithImpl<$Res, $Val extends Preset>
    implements $PresetCopyWith<$Res> {
  _$PresetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Preset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? description = null,
    Object? template = null,
    Object? blocks = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            template: null == template
                ? _value.template
                : template // ignore: cast_nullable_to_non_nullable
                      as String,
            blocks: null == blocks
                ? _value.blocks
                : blocks // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PresetImplCopyWith<$Res> implements $PresetCopyWith<$Res> {
  factory _$$PresetImplCopyWith(
    _$PresetImpl value,
    $Res Function(_$PresetImpl) then,
  ) = __$$PresetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String label,
    String description,
    String template,
    Map<String, String> blocks,
  });
}

/// @nodoc
class __$$PresetImplCopyWithImpl<$Res>
    extends _$PresetCopyWithImpl<$Res, _$PresetImpl>
    implements _$$PresetImplCopyWith<$Res> {
  __$$PresetImplCopyWithImpl(
    _$PresetImpl _value,
    $Res Function(_$PresetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Preset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? description = null,
    Object? template = null,
    Object? blocks = null,
  }) {
    return _then(
      _$PresetImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        template: null == template
            ? _value.template
            : template // ignore: cast_nullable_to_non_nullable
                  as String,
        blocks: null == blocks
            ? _value._blocks
            : blocks // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PresetImpl implements _Preset {
  const _$PresetImpl({
    required this.id,
    required this.label,
    this.description = '',
    required this.template,
    final Map<String, String> blocks = const {},
  }) : _blocks = blocks;

  factory _$PresetImpl.fromJson(Map<String, dynamic> json) =>
      _$$PresetImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  @JsonKey()
  final String description;
  @override
  final String template;
  final Map<String, String> _blocks;
  @override
  @JsonKey()
  Map<String, String> get blocks {
    if (_blocks is EqualUnmodifiableMapView) return _blocks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_blocks);
  }

  @override
  String toString() {
    return 'Preset(id: $id, label: $label, description: $description, template: $template, blocks: $blocks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PresetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.template, template) ||
                other.template == template) &&
            const DeepCollectionEquality().equals(other._blocks, _blocks));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    label,
    description,
    template,
    const DeepCollectionEquality().hash(_blocks),
  );

  /// Create a copy of Preset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PresetImplCopyWith<_$PresetImpl> get copyWith =>
      __$$PresetImplCopyWithImpl<_$PresetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PresetImplToJson(this);
  }
}

abstract class _Preset implements Preset {
  const factory _Preset({
    required final String id,
    required final String label,
    final String description,
    required final String template,
    final Map<String, String> blocks,
  }) = _$PresetImpl;

  factory _Preset.fromJson(Map<String, dynamic> json) = _$PresetImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  String get description;
  @override
  String get template;
  @override
  Map<String, String> get blocks;

  /// Create a copy of Preset
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PresetImplCopyWith<_$PresetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
