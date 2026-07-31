import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/secrets.dart';
import '../providers/api_provider.dart';
import 'comfy_image_service.dart';
import 'image_generation_service.dart';
import 'ol1n_image_service.dart';
import 'xai_api_service.dart';

// Resolution order: Settings (SharedPreferences) → baked Secrets → --dart-define.
String _effectiveCfId(Ref ref) {
  final saved = ref.watch(ol1nCfIdProvider);
  if (saved.isNotEmpty) return saved;
  if (Secrets.cfAccessClientId.isNotEmpty) return Secrets.cfAccessClientId;
  const envId = String.fromEnvironment('CF_ACCESS_CLIENT_ID');
  return envId;
}

String _effectiveCfSecret(Ref ref) {
  final saved = ref.watch(ol1nCfSecretProvider);
  if (saved.isNotEmpty) return saved;
  if (Secrets.cfAccessClientSecret.isNotEmpty) {
    return Secrets.cfAccessClientSecret;
  }
  const envSecret = String.fromEnvironment('CF_ACCESS_CLIENT_SECRET');
  return envSecret;
}

ImageGenerationService? createActiveImageService(Ref ref) {
  final type = ref.watch(providerTypeProvider);

  if (type == 'ol1n') {
    final cfId = _effectiveCfId(ref);
    final cfSecret = _effectiveCfSecret(ref);
    if (cfId.isEmpty || cfSecret.isEmpty) return null;
    return OlinkImageService(cfId: cfId, cfSecret: cfSecret);
  }

  if (type == 'comfyui') {
    final cfId = _effectiveCfId(ref);
    final cfSecret = _effectiveCfSecret(ref);
    if (cfId.isEmpty || cfSecret.isEmpty) return null;
    final wfStr = ref.watch(comfyWorkflowProvider);
    final wf = wfStr == 'pony' ? ComfyWorkflow.pony : ComfyWorkflow.flux;
    return ComfyImageService(cfId: cfId, cfSecret: cfSecret, workflow: wf);
  }

  // xAI (default)
  final apiKey = ref.watch(apiKeyProvider);
  if (apiKey.isEmpty) return null;
  return XaiApiService(apiKey: apiKey);
}
