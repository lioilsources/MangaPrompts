import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/backend_factory.dart';
import '../services/image_generation_service.dart';
import '../services/image_service.dart';
import 'prompt_provider.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

/// Which backend to use: 'xai', 'ol1n', or 'comfyui'. Ignored on web, where
/// generation always goes through the Telegram bot backend.
final providerTypeProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('provider_type') ?? 'xai';
});

/// What the user picked in Settings: 'auto' (default) or an explicit workflow
/// id. Read [effectiveWorkflowProvider] to get the workflow actually used —
/// this one only carries the preference.
final comfyWorkflowProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('comfy_workflow') ?? 'auto';
});

/// The workflow generation actually runs on.
///
/// On 'auto' it comes from the active template, because the template is what
/// decides the prompt *language*: the pony templates emit Danbooru tags, the
/// rest emit prose, and feeding one to the other's model degrades the result
/// silently. Anything other than 'auto' is an explicit user override.
final effectiveWorkflowProvider = Provider<String>((ref) {
  final preference = ref.watch(comfyWorkflowProvider);
  if (preference != 'auto') return preference;
  final template = ref.watch(activeTemplateProvider).valueOrNull;
  final declared = template?.workflow ?? '';
  return declared.isEmpty ? 'flux' : declared;
});

const _xaiKeyEnv = String.fromEnvironment('XAI_API_KEY');

final apiKeyProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('xai_api_key') ?? _xaiKeyEnv;
});

/// CF Access creds as saved in Settings. The baked `Secrets` / --dart-define
/// fallbacks are applied in backend_factory_io so they never reach the web
/// bundle (and never prefill the Settings fields).
final ol1nCfIdProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('ol1n_cf_id') ?? '';
});

final ol1nCfSecretProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('ol1n_cf_secret') ?? '';
});

/// Returns the active image generation service, or null if not configured.
final activeImageServiceProvider = Provider<ImageGenerationService?>((ref) {
  return createActiveImageService(ref);
});

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});
