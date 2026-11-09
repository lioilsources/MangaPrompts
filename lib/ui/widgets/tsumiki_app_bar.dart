import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/account_provider.dart';
import '../../providers/video_scenes_provider.dart';
import '../../config/hairstyles.dart';
import '../../l10n/l10n.dart';
import '../screens/animate_screen.dart';
import '../screens/hair_screen.dart';
import '../screens/home_screen.dart';
import '../screens/restyle_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/web_entry.dart';
import 'paywall_sheet.dart';

/// The Mini App's cards. Each is a full screen behind the shared title bar.
enum TsumikiScreen {
  builder(Icons.auto_awesome),
  restyle(Icons.face_retouching_natural),
  hair(Icons.content_cut),
  animate(Icons.movie_creation_outlined);

  const TsumikiScreen(this.icon);

  final IconData icon;

  String label(AppLocalizations l) => switch (this) {
    TsumikiScreen.builder => l.screenBuilder,
    TsumikiScreen.restyle => l.screenRestyle,
    TsumikiScreen.hair => l.screenHair,
    TsumikiScreen.animate => l.screenAnimate,
  };

  /// Which ledger the card spends: animations have their own credits,
  /// everything else is an image generation.
  bool get video => this == TsumikiScreen.animate;

  Widget build() => switch (this) {
    TsumikiScreen.builder => const HomeScreen(),
    TsumikiScreen.restyle => const RestyleScreen(),
    TsumikiScreen.hair => const HairScreen(),
    TsumikiScreen.animate => const AnimateScreen(),
  };
}

/// The Mini App's title bar, shared by every card so the chrome never shifts
/// under the user: same brand, same Stars shop, same way across.
///
/// [screen] says which card is showing — it decides which balance the shop
/// chip reports and which paywall it opens, and it is the one the switcher
/// greys out.
class TsumikiAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const TsumikiAppBar({
    super.key,
    required this.screen,
    this.extraActions = const [],
  });

  /// The card this bar sits on.
  final TsumikiScreen screen;

  /// Screen-specific actions, inserted before Settings.
  final List<Widget> extraActions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text('Tsumiki'),
      actions: [
        if (kIsWeb) _ShopChip(video: screen.video),
        if (kIsWeb) _ScreenMenu(current: screen),
        ...extraActions,
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: context.l10n.settings,
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
/// actually spends — image credits next to the prompt builder and the
/// restyle card, animation credits next to the animator — and opens the
/// matching paywall.
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
          tooltip: video
              ? context.l10n.shopTooltipVideo
              : context.l10n.shopTooltip,
          onPressed: () => PaywallSheet.show(context, video: video),
        ),
      ),
    );
  }
}

/// How to get from the current card to [target] without stacking cards on
/// each other: the Mini App keeps at most the root card plus one more.
enum ScreenNav { popToRoot, pushReplacement, push }

/// Pure navigation policy, kept out of the widget so it can be tested.
/// [root] is the card the Mini App opened on (see [webRootScreen]),
/// [canPop] whether we are currently on a pushed card.
ScreenNav screenNavFor({
  required TsumikiScreen root,
  required bool canPop,
  required TsumikiScreen target,
}) {
  if (target == root) return ScreenNav.popToRoot;
  return canPop ? ScreenNav.pushReplacement : ScreenNav.push;
}

/// Whether the switcher lists [screen]. Animation needs a scene catalog from
/// the render server; the hairdresser needs at least one hairstyle that passed
/// the bench gate (docs/hair-matrix.md) — until then the card stays hidden
/// rather than empty.
bool screenOffered(
  TsumikiScreen screen, {
  required bool animateAvailable,
  required bool hairstylesAvailable,
}) => switch (screen) {
  TsumikiScreen.animate => animateAvailable,
  TsumikiScreen.hair => hairstylesAvailable,
  _ => true,
};

/// Jump to another card. Animation is only offered when there is a catalog
/// to animate with; the other two always work.
class _ScreenMenu extends ConsumerWidget {
  const _ScreenMenu({required this.current});

  final TsumikiScreen current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(videoScenesProvider);
    final animateAvailable = scenes.maybeWhen(
      data: (s) => s.isNotEmpty,
      orElse: () => false,
    );
    final root = scenes.maybeWhen(
      data: webRootScreen,
      orElse: () => TsumikiScreen.builder,
    );
    return PopupMenuButton<TsumikiScreen>(
      icon: const Icon(Icons.apps),
      tooltip: context.l10n.switchCard,
      onSelected: (target) => _goTo(context, root, target),
      itemBuilder: (_) => [
        for (final s in TsumikiScreen.values)
          if (screenOffered(
            s,
            animateAvailable: animateAvailable,
            hairstylesAvailable: kHairstyles.isNotEmpty || kHairColours.isNotEmpty,
          ))
            PopupMenuItem(
              value: s,
              enabled: s != current,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(s.icon),
                title: Text(s.label(context.l10n)),
                trailing: s == current ? const Icon(Icons.check) : null,
              ),
            ),
      ],
    );
  }

  void _goTo(BuildContext context, TsumikiScreen root, TsumikiScreen target) {
    final nav = Navigator.of(context);
    switch (screenNavFor(root: root, canPop: nav.canPop(), target: target)) {
      case ScreenNav.popToRoot:
        nav.popUntil((r) => r.isFirst);
      case ScreenNav.pushReplacement:
        nav.pushReplacement(MaterialPageRoute(builder: (_) => target.build()));
      case ScreenNav.push:
        nav.push(MaterialPageRoute(builder: (_) => target.build()));
    }
  }
}
