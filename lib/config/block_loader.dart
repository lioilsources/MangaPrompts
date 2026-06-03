import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import 'models/block.dart';
import 'models/block_category.dart';
import 'models/prompt_template.dart';
import 'models/preset.dart';

class BlockLoader {
  static const _blockFiles = [
    'subject',
    'nationality',
    'body_type',
    'style',
    'face',
    'eyes',
    'eyebrows',
    'hair',
    'expression',
    'pose',
    'clothing',
    'lighting',
    'effects',
    'background',
    'camera',
    'palette',
    'quality',
    'negative',
  ];

  static Map<String, dynamic> _yamlToMap(YamlMap yaml) {
    return yaml.map((key, value) {
      if (value is YamlMap) {
        return MapEntry(key.toString(), _yamlToMap(value));
      } else if (value is YamlList) {
        return MapEntry(key.toString(), _yamlToList(value));
      } else {
        return MapEntry(key.toString(), value);
      }
    });
  }

  static dynamic _yamlToList(YamlList yaml) {
    return yaml.map((item) {
      if (item is YamlMap) {
        return _yamlToMap(item);
      } else if (item is YamlList) {
        return _yamlToList(item);
      } else {
        return item;
      }
    }).toList();
  }

  static Future<List<BlockCategory>> loadAllCategories() async {
    final categories = <BlockCategory>[];

    for (final fileName in _blockFiles) {
      try {
        final yamlStr = await rootBundle.loadString(
          'assets/config/blocks/$fileName.yaml',
        );
        final yamlData = loadYaml(yamlStr) as YamlMap;
        final map = _yamlToMap(yamlData);

        final blocks = (map['blocks'] as List?)?.map((blockMap) {
          return Block.fromJson(Map<String, dynamic>.from(blockMap));
        }).toList() ?? [];

        categories.add(BlockCategory(
          category: map['category'] as String,
          label: map['label'] as String,
          icon: map['icon'] as String? ?? 'category',
          isRequired: map['required'] as bool? ?? false,
          blocks: blocks,
        ));
      } catch (e) {
        // Skip files that fail to load
        print('Warning: Failed to load $fileName.yaml: $e');
      }
    }

    return categories;
  }

  static Future<List<PromptTemplate>> loadTemplates() async {
    final yamlStr = await rootBundle.loadString('assets/config/templates.yaml');
    final yamlData = loadYaml(yamlStr) as YamlMap;
    final map = _yamlToMap(yamlData);

    final templates = (map['templates'] as List).map((tMap) {
      return PromptTemplate.fromJson(Map<String, dynamic>.from(tMap));
    }).toList();

    return templates;
  }

  static Future<List<Preset>> loadPresets() async {
    final yamlStr = await rootBundle.loadString('assets/config/presets.yaml');
    final yamlData = loadYaml(yamlStr) as YamlMap;
    final map = _yamlToMap(yamlData);

    final presets = (map['presets'] as List).map((pMap) {
      return Preset.fromJson(Map<String, dynamic>.from(pMap));
    }).toList();

    return presets;
  }
}
