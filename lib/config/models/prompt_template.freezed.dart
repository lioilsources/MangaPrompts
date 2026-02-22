// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prompt_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PromptTemplate _$PromptTemplateFromJson(Map<String, dynamic> json) {
  return _PromptTemplate.fromJson(json);
}

/// @nodoc
mixin _$PromptTemplate {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'slot_order')
  List<String> get slotOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'negative_slot')
  String get negativeSlot => throw _privateConstructorUsedError;
  String get separator => throw _privateConstructorUsedError;
  @JsonKey(name: 'required_slots')
  List<String> get requiredSlots => throw _privateConstructorUsedError;
  @JsonKey(name: 'optional_slots')
  List<String> get optionalSlots => throw _privateConstructorUsedError;

  /// Serializes this PromptTemplate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PromptTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PromptTemplateCopyWith<PromptTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PromptTemplateCopyWith<$Res> {
  factory $PromptTemplateCopyWith(
    PromptTemplate value,
    $Res Function(PromptTemplate) then,
  ) = _$PromptTemplateCopyWithImpl<$Res, PromptTemplate>;
  @useResult
  $Res call({
    String id,
    String label,
    String description,
    @JsonKey(name: 'slot_order') List<String> slotOrder,
    @JsonKey(name: 'negative_slot') String negativeSlot,
    String separator,
    @JsonKey(name: 'required_slots') List<String> requiredSlots,
    @JsonKey(name: 'optional_slots') List<String> optionalSlots,
  });
}

/// @nodoc
class _$PromptTemplateCopyWithImpl<$Res, $Val extends PromptTemplate>
    implements $PromptTemplateCopyWith<$Res> {
  _$PromptTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PromptTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? description = null,
    Object? slotOrder = null,
    Object? negativeSlot = null,
    Object? separator = null,
    Object? requiredSlots = null,
    Object? optionalSlots = null,
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
            slotOrder: null == slotOrder
                ? _value.slotOrder
                : slotOrder // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            negativeSlot: null == negativeSlot
                ? _value.negativeSlot
                : negativeSlot // ignore: cast_nullable_to_non_nullable
                      as String,
            separator: null == separator
                ? _value.separator
                : separator // ignore: cast_nullable_to_non_nullable
                      as String,
            requiredSlots: null == requiredSlots
                ? _value.requiredSlots
                : requiredSlots // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            optionalSlots: null == optionalSlots
                ? _value.optionalSlots
                : optionalSlots // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PromptTemplateImplCopyWith<$Res>
    implements $PromptTemplateCopyWith<$Res> {
  factory _$$PromptTemplateImplCopyWith(
    _$PromptTemplateImpl value,
    $Res Function(_$PromptTemplateImpl) then,
  ) = __$$PromptTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String label,
    String description,
    @JsonKey(name: 'slot_order') List<String> slotOrder,
    @JsonKey(name: 'negative_slot') String negativeSlot,
    String separator,
    @JsonKey(name: 'required_slots') List<String> requiredSlots,
    @JsonKey(name: 'optional_slots') List<String> optionalSlots,
  });
}

/// @nodoc
class __$$PromptTemplateImplCopyWithImpl<$Res>
    extends _$PromptTemplateCopyWithImpl<$Res, _$PromptTemplateImpl>
    implements _$$PromptTemplateImplCopyWith<$Res> {
  __$$PromptTemplateImplCopyWithImpl(
    _$PromptTemplateImpl _value,
    $Res Function(_$PromptTemplateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PromptTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? description = null,
    Object? slotOrder = null,
    Object? negativeSlot = null,
    Object? separator = null,
    Object? requiredSlots = null,
    Object? optionalSlots = null,
  }) {
    return _then(
      _$PromptTemplateImpl(
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
        slotOrder: null == slotOrder
            ? _value._slotOrder
            : slotOrder // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        negativeSlot: null == negativeSlot
            ? _value.negativeSlot
            : negativeSlot // ignore: cast_nullable_to_non_nullable
                  as String,
        separator: null == separator
            ? _value.separator
            : separator // ignore: cast_nullable_to_non_nullable
                  as String,
        requiredSlots: null == requiredSlots
            ? _value._requiredSlots
            : requiredSlots // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        optionalSlots: null == optionalSlots
            ? _value._optionalSlots
            : optionalSlots // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PromptTemplateImpl implements _PromptTemplate {
  const _$PromptTemplateImpl({
    required this.id,
    required this.label,
    this.description = '',
    @JsonKey(name: 'slot_order') required final List<String> slotOrder,
    @JsonKey(name: 'negative_slot') this.negativeSlot = 'negative',
    this.separator = ', ',
    @JsonKey(name: 'required_slots')
    final List<String> requiredSlots = const [],
    @JsonKey(name: 'optional_slots')
    final List<String> optionalSlots = const [],
  }) : _slotOrder = slotOrder,
       _requiredSlots = requiredSlots,
       _optionalSlots = optionalSlots;

  factory _$PromptTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PromptTemplateImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  @JsonKey()
  final String description;
  final List<String> _slotOrder;
  @override
  @JsonKey(name: 'slot_order')
  List<String> get slotOrder {
    if (_slotOrder is EqualUnmodifiableListView) return _slotOrder;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_slotOrder);
  }

  @override
  @JsonKey(name: 'negative_slot')
  final String negativeSlot;
  @override
  @JsonKey()
  final String separator;
  final List<String> _requiredSlots;
  @override
  @JsonKey(name: 'required_slots')
  List<String> get requiredSlots {
    if (_requiredSlots is EqualUnmodifiableListView) return _requiredSlots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requiredSlots);
  }

  final List<String> _optionalSlots;
  @override
  @JsonKey(name: 'optional_slots')
  List<String> get optionalSlots {
    if (_optionalSlots is EqualUnmodifiableListView) return _optionalSlots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_optionalSlots);
  }

  @override
  String toString() {
    return 'PromptTemplate(id: $id, label: $label, description: $description, slotOrder: $slotOrder, negativeSlot: $negativeSlot, separator: $separator, requiredSlots: $requiredSlots, optionalSlots: $optionalSlots)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PromptTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._slotOrder,
              _slotOrder,
            ) &&
            (identical(other.negativeSlot, negativeSlot) ||
                other.negativeSlot == negativeSlot) &&
            (identical(other.separator, separator) ||
                other.separator == separator) &&
            const DeepCollectionEquality().equals(
              other._requiredSlots,
              _requiredSlots,
            ) &&
            const DeepCollectionEquality().equals(
              other._optionalSlots,
              _optionalSlots,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    label,
    description,
    const DeepCollectionEquality().hash(_slotOrder),
    negativeSlot,
    separator,
    const DeepCollectionEquality().hash(_requiredSlots),
    const DeepCollectionEquality().hash(_optionalSlots),
  );

  /// Create a copy of PromptTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PromptTemplateImplCopyWith<_$PromptTemplateImpl> get copyWith =>
      __$$PromptTemplateImplCopyWithImpl<_$PromptTemplateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PromptTemplateImplToJson(this);
  }
}

abstract class _PromptTemplate implements PromptTemplate {
  const factory _PromptTemplate({
    required final String id,
    required final String label,
    final String description,
    @JsonKey(name: 'slot_order') required final List<String> slotOrder,
    @JsonKey(name: 'negative_slot') final String negativeSlot,
    final String separator,
    @JsonKey(name: 'required_slots') final List<String> requiredSlots,
    @JsonKey(name: 'optional_slots') final List<String> optionalSlots,
  }) = _$PromptTemplateImpl;

  factory _PromptTemplate.fromJson(Map<String, dynamic> json) =
      _$PromptTemplateImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  String get description;
  @override
  @JsonKey(name: 'slot_order')
  List<String> get slotOrder;
  @override
  @JsonKey(name: 'negative_slot')
  String get negativeSlot;
  @override
  String get separator;
  @override
  @JsonKey(name: 'required_slots')
  List<String> get requiredSlots;
  @override
  @JsonKey(name: 'optional_slots')
  List<String> get optionalSlots;

  /// Create a copy of PromptTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PromptTemplateImplCopyWith<_$PromptTemplateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
