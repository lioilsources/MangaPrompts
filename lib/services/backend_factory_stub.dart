import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'image_generation_service.dart';

ImageGenerationService? createActiveImageService(Ref ref) {
  throw UnsupportedError('No image backend for this platform');
}
