import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/image_generation_service.dart';
import '../services/xai_api_service.dart';
import '../services/ol1n_image_service.dart';
import '../services/comfy_image_service.dart';
import '../services/image_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

/// Which backend to use: 'xai', 'ol1n', or 'comfyui'.
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
  final type = ref.watch(providerTypeProvider);

  if (type == 'ol1n') {
    final cfId = ref.watch(ol1nCfIdProvider);
    final cfSecret = ref.watch(ol1nCfSecretProvider);
    const envId = String.fromEnvironment('CF_ACCESS_CLIENT_ID');
    const envSecret = String.fromEnvironment('CF_ACCESS_CLIENT_SECRET');
    final effectiveId = cfId.isNotEmpty ? cfId : envId;
    final effectiveSecret = cfSecret.isNotEmpty ? cfSecret : envSecret;
    if (effectiveId.isEmpty || effectiveSecret.isEmpty) return null;
    return OlinkImageService(cfId: cfId, cfSecret: cfSecret);
  }

  if (type == 'comfyui') {
    final cfId = ref.watch(ol1nCfIdProvider);
    final cfSecret = ref.watch(ol1nCfSecretProvider);
    const envId = String.fromEnvironment('CF_ACCESS_CLIENT_ID');
    const envSecret = String.fromEnvironment('CF_ACCESS_CLIENT_SECRET');
    final effectiveId = cfId.isNotEmpty ? cfId : envId;
    final effectiveSecret = cfSecret.isNotEmpty ? cfSecret : envSecret;
    if (effectiveId.isEmpty || effectiveSecret.isEmpty) return null;
    final wfStr = ref.watch(comfyWorkflowProvider);
    final wf = wfStr == 'pony' ? ComfyWorkflow.pony : ComfyWorkflow.flux;
    return ComfyImageService(
      cfId: effectiveId,
      cfSecret: effectiveSecret,
      workflow: wf,
    );
  }

  // xAI (default)
  final apiKey = ref.watch(apiKeyProvider);
  if (apiKey.isEmpty) return null;
  return XaiApiService(apiKey: apiKey);
});

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});
