import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/account_provider.dart';
import '../../providers/video_scenes_provider.dart';
import '../screens/animate_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import 'paywall_sheet.dart';

/// The Mini App's title bar, shared by both screens so the chrome never
/// shifts under the user: same brand, same Stars shop, same way across.
///
/// [video] says which screen is showing — it decides which balance the shop
/// chip reports and which paywall it opens, and it points the toggle at the
/// other screen.
class TsumikiAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const TsumikiAppBar({
    super.key,
    required this.video,
    this.extraActions = const [],
  });

  /// True on the animation screen, false on the prompt builder.
  final bool video;

  /// Screen-specific actions, inserted before Settings.
  final List<Widget> extraActions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text('Tsumiki'),
      actions: [
        if (kIsWeb) _ShopChip(video: video),
        if (kIsWeb) _ScreenToggle(video: video),
        ...extraActions,
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }
}

/// Balance + Telegram Stars shop. Reports the balance that the current screen
/// actually spends — image credits next to the prompt builder, animation
/// credits next to the animator — and opens the matching paywall.
class _ShopChip extends ConsumerWidget {
  const _ShopChip({required this.video});

  final bool video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider);
    final glyph = video ? '🎬' : '⚡';
    final label = account.when(
      data: (a) => '$glyph ${video ? a.videoTotalRemaining : a.totalRemaining}',
      loading: () => '$glyph …',
      error: (_, _) => '$glyph ?',
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: ActionChip(
          label: Text(label),
          visualDensity: VisualDensity.compact,
          tooltip: video ? 'Animation credits and packages' : 'Credits and packages',
          onPressed: () => PaywallSheet.show(context, video: video),
        ),
      ),
    );
  }
}

/// Jump to the other screen. Pops when we got here by pushing, so the two
/// screens never stack up on each other.
class _ScreenToggle extends ConsumerWidget {
  const _ScreenToggle({required this.video});

  final bool video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Going *to* the animator is only offered when there is a catalog to
    // animate with; going back to image generation always works.
    if (!video) {
      final scenes = ref.watch(videoScenesProvider);
      final available = scenes.maybeWhen(
        data: (s) => s.isNotEmpty,
        orElse: () => false,
      );
      if (!available) return const SizedBox.shrink();
    }
    return IconButton(
      icon: Icon(video ? Icons.auto_awesome : Icons.movie_creation_outlined),
      tooltip: video ? 'Generate images' : 'Animate a photo',
      onPressed: () => Navigator.canPop(context)
          ? Navigator.pop(context)
          : Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => video ? const HomeScreen() : const AnimateScreen(),
              ),
            ),
    );
  }
}
