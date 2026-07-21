import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/comfy_image_service.dart';
import 'api_provider.dart';

/// State for the standalone "Repose" mode (face + pose depth template → image).

/// Local file path of the uploaded face image (null = none picked yet).
final faceImagePathProvider = StateProvider<String?>((ref) => null);

/// Asset path of the selected pose depth template, e.g.
/// `assets/poses/pose_depth/1.png` (null = none selected yet).
final reposePoseAssetProvider = StateProvider<String?>((ref) => null);

/// Free-text positive prompt.
final reposePromptProvider = StateProvider<String>((ref) => '');

/// Free-text negative prompt. Seeded with a sensible default the user can edit.
final reposeNegativeProvider = StateProvider<String>(
  (ref) => 'blurry, soft focus, low detail, smooth plastic skin, '
      'close-up, portrait, face closeup, cropped head, '
      'text, watermark, worst quality, bad anatomy, deformed, extra limbs',
);

/// Selected SDXL checkpoint (must be an SDXL model present on the server).
final reposeCheckpointProvider = StateProvider<String>(
  (ref) => 'Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors',
);

/// Checkpoints available on the ComfyUI server, for the model dropdown.
final availableCheckpointsProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(reposeServiceProvider);
  if (service == null) return const [];
  return service.availableCheckpoints();
});

/// ComfyUI service for repose. Independent of `providerTypeProvider` — this mode
/// always talks to ComfyUI. Returns null when CF Access creds are not configured.
final reposeServiceProvider = Provider<ComfyImageService?>((ref) {
  final cfId = ref.watch(ol1nCfIdProvider);
  final cfSecret = ref.watch(ol1nCfSecretProvider);
  const envId = String.fromEnvironment('CF_ACCESS_CLIENT_ID');
  const envSecret = String.fromEnvironment('CF_ACCESS_CLIENT_SECRET');
  final effectiveId = cfId.isNotEmpty ? cfId : envId;
  final effectiveSecret = cfSecret.isNotEmpty ? cfSecret : envSecret;
  if (effectiveId.isEmpty || effectiveSecret.isEmpty) return null;
  return ComfyImageService(cfId: effectiveId, cfSecret: effectiveSecret);
});
