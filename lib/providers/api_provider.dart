import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/backend_factory.dart';
import '../services/image_generation_service.dart';
import '../services/image_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

/// Which backend to use: 'xai', 'ol1n', or 'comfyui'. Ignored on web, where
/// generation always goes through the Telegram bot backend.
final providerTypeProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('provider_type') ?? 'xai';
});

/// ComfyUI workflow: 'flux' or 'pony'.
final comfyWorkflowProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('comfy_workflow') ?? 'flux';
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
