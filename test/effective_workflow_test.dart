import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsumiki/config/block_loader.dart';
import 'package:tsumiki/config/models/prompt_template.dart';
import 'package:tsumiki/providers/api_provider.dart';
import 'package:tsumiki/providers/blocks_provider.dart';
import 'package:tsumiki/providers/selection_provider.dart';

PromptTemplate _template(String id, String workflow) => PromptTemplate(
      id: id,
      label: id,
      slotOrder: const ['medium'],
      workflow: workflow,
    );

final _templates = [
  _template('template_portrait', 'flux'),
  _template('template_pony_portrait', 'pony'),
  _template('template_undeclared', ''),
];

ProviderContainer _containerFor({
  required String preference,
  required String templateId,
}) {
  final container = ProviderContainer(
    overrides: [
      templatesProvider.overrideWith((ref) async => _templates),
      comfyWorkflowProvider.overrideWith((ref) => preference),
      activeTemplateIdProvider.overrideWith((ref) => templateId),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('effectiveWorkflowProvider', () {
    test('auto follows the template that declares flux', () async {
      final c = _containerFor(preference: 'auto', templateId: 'template_portrait');
      await c.read(templatesProvider.future);
      expect(c.read(effectiveWorkflowProvider), 'flux');
    });

    test('auto follows the template that declares pony', () async {
      final c = _containerFor(preference: 'auto', templateId: 'template_pony_portrait');
      await c.read(templatesProvider.future);
      expect(c.read(effectiveWorkflowProvider), 'pony');
    });

    test('an explicit preference overrides the template', () async {
      // The whole point of keeping the manual setting: a pony template must
      // still be forceable onto another model.
      final c = _containerFor(preference: 'wai', templateId: 'template_pony_portrait');
      await c.read(templatesProvider.future);
      expect(c.read(effectiveWorkflowProvider), 'wai');
    });

    test('a template with no declaration falls back to flux', () async {
      final c = _containerFor(preference: 'auto', templateId: 'template_undeclared');
      await c.read(templatesProvider.future);
      expect(c.read(effectiveWorkflowProvider), 'flux');
    });

    test('flux is used while the templates are still loading', () {
      // activeTemplateProvider has no value yet — generation must not break.
      final c = _containerFor(preference: 'auto', templateId: 'template_portrait');
      expect(c.read(effectiveWorkflowProvider), 'flux');
    });
  });

  group('shipped config', () {
    setUp(() => TestWidgetsFlutterBinding.ensureInitialized());

    test('every template declares a workflow, and the right one', () async {
      // Loads the real assets/config/templates.yaml, not a fixture: a template
      // added later without a declaration would silently fall back to flux.
      final templates = await BlockLoader.loadTemplates();
      expect(templates, isNotEmpty);
      for (final t in templates) {
        expect(t.workflow, isNotEmpty, reason: '${t.id} declares no workflow');
      }
      // A template's prompt language and its model must not drift apart.
      const expected = {
        'template_pony': 'pony',
        'template_wai': 'wai',
        'template_jugg': 'juggernaut',
      };
      for (final t in templates) {
        for (final e in expected.entries) {
          if (t.id.startsWith(e.key)) {
            expect(t.workflow, e.value, reason: '${t.id} must run on ${e.value}');
          }
        }
      }
    });

    test('every slot a template names actually exists', () async {
      // A typo in slot_order is invisible at runtime — the category just never
      // shows up in the picker — so catch it here instead.
      final templates = await BlockLoader.loadTemplates();
      final categories = await BlockLoader.loadAllCategories();
      final known = categories.map((c) => c.category).toSet();
      expect(known, isNotEmpty);

      for (final t in templates) {
        for (final slot in t.slotOrder) {
          expect(known, contains(slot), reason: '${t.id}: unknown slot "$slot"');
        }
        for (final slot in [...t.requiredSlots, ...t.optionalSlots]) {
          expect(known, contains(slot),
              reason: '${t.id}: unknown slot "$slot" in required/optional');
        }
        expect(known, contains(t.negativeSlot),
            reason: '${t.id}: unknown negative_slot "${t.negativeSlot}"');
      }
    });

    test('no pose axis carries framing', () async {
      // pose.yaml states the rule in its own header: poses describe body and
      // contact only, framing lives in its own axis. Breaking it produces
      // prompts that contradict themselves — "full body" inside a pose while
      // the framing slot asks for a close-up.
      const framingWords = ['full body', 'full-body', 'close-up', 'closeup',
                            'cowboy shot', 'upper body', 'upper-body',
                            'portrait,', 'framed from'];
      final categories = await BlockLoader.loadAllCategories();
      final poseAxes = categories.where((c) => c.category.contains('pose'));
      expect(poseAxes, isNotEmpty);

      for (final axis in poseAxes) {
        for (final block in axis.blocks) {
          final value = block.value.toLowerCase();
          for (final word in framingWords) {
            expect(value.contains(word), isFalse,
                reason: '${axis.category}/${block.id} carries framing "$word"');
          }
        }
      }
    });

    test('the tag templates never mix in prose axes', () async {
      // pony_* and wai_* templates speak Danbooru tags; the prose axes would
      // pollute the prompt with sentences.
      const prose = {'medium', 'style', 'pose', 'pose_duo', 'art_tradition',
                     'subject', 'framing', 'background', 'camera', 'quality'};
      final templates = await BlockLoader.loadTemplates();
      final tagTemplates = templates.where(
          (t) => t.workflow == 'pony' || t.workflow == 'wai');
      expect(tagTemplates, isNotEmpty);
      for (final t in tagTemplates) {
        for (final slot in t.slotOrder) {
          expect(prose, isNot(contains(slot)),
              reason: '${t.id} mixes prose axis "$slot" into a tag prompt');
        }
      }
    });
  });
}
