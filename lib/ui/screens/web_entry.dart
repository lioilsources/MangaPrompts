import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/video_scenes_provider.dart';
import '../../services/telegram_backend_service.dart';
import '../widgets/tsumiki_app_bar.dart';
import 'home_screen.dart';

/// The card the Mini App opens on, given the animation catalog: animation
/// when there is something to animate with, otherwise the prompt builder.
/// The card switcher uses the same rule to know which card is the root.
TsumikiScreen webRootScreen(List<TgVideoScene> scenes) =>
    scenes.isEmpty ? TsumikiScreen.builder : TsumikiScreen.animate;

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
          data: (scenes) => webRootScreen(scenes).build(),
        );
  }
}
