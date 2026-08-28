import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/video_scenes_provider.dart';
import 'animate_screen.dart';
import 'home_screen.dart';

/// Landing screen inside the Telegram Mini App.
///
/// Animation is the headline feature, so it is the front door. If the render
/// server is unreachable the app falls back to image generation instead of
/// landing everyone on an error — the same hide-on-failure rule the 🎬 button
/// used before animation became the default.
class WebEntry extends ConsumerWidget {
  const WebEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(videoScenesProvider).when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const HomeScreen(),
          data: (scenes) =>
              scenes.isEmpty ? const HomeScreen() : const AnimateScreen(),
        );
  }
}
