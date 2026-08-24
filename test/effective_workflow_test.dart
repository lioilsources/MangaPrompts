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

  test('every shipped template declares a workflow', () async {
    // Loads the real assets/config/templates.yaml, not a fixture: a template
    // added later without a declaration would silently fall back to flux,
    // which is wrong for any tag-based one.
    TestWidgetsFlutterBinding.ensureInitialized();
    final templates = await BlockLoader.loadTemplates();
    expect(templates, isNotEmpty);
    for (final t in templates) {
      expect(t.workflow, isNotEmpty, reason: '${t.id} declares no workflow');
    }
    // The pony templates speak Danbooru tags — they must never resolve to flux.
    for (final t in templates.where((t) => t.id.startsWith('template_pony'))) {
      expect(t.workflow, 'pony', reason: '${t.id} must run on pony');
    }
  });
}
