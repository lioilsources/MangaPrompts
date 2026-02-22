import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/xai_api_service.dart';
import '../services/image_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final apiKeyProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('xai_api_key') ?? '';
});

final xaiApiServiceProvider = Provider<XaiApiService?>((ref) {
  final apiKey = ref.watch(apiKeyProvider);
  if (apiKey.isEmpty) return null;
  return XaiApiService(apiKey: apiKey);
});

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});
