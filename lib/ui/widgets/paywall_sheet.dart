import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../platform/telegram_webapp.dart';
import '../../providers/account_provider.dart';
import '../../services/telegram_backend_service.dart';

/// Bottom sheet with Telegram Stars credit packages. Opened from the balance
/// chip and automatically when generation answers "payment required".
/// With [video] it sells animation credits instead of image credits.
class PaywallSheet extends ConsumerStatefulWidget {
  const PaywallSheet({super.key, this.video = false});

  final bool video;

  static Future<void> show(BuildContext context, {bool video = false}) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => PaywallSheet(video: video),
    );
  }

  @override
  ConsumerState<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends ConsumerState<PaywallSheet> {
  String? _buyingId;

  Future<void> _buy(TgPackage package) async {
    setState(() => _buyingId = package.id);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final link = await TelegramBackendService.createInvoiceLink(package.id);
      final status = await TelegramWebApp.openInvoice(link);
      if (!mounted) return;
      if (status == 'paid') {
        ref.invalidate(accountProvider);
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(widget.video
                ? '${package.credits} animation credit added 🎉'
                : '${package.credits} credits added 🎉'),
          ),
        );
      } else if (status == 'failed') {
        messenger.showSnackBar(
          const SnackBar(content: Text('Payment failed, please try again')),
        );
      }
      // 'cancelled' / 'pending' → keep the sheet open without noise
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _buyingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: account.when(
          loading: () => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Could not load credits: $e'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(accountProvider),
                child: const Text('Try again'),
              ),
            ],
          ),
          data: (a) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.video ? 'Animations' : 'Credits',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                widget.video
                    ? '${a.videoFreeRemaining} of ${a.videoFreeLimit} free '
                        'animation today · animation credits: '
                        '${a.videoCredits}. 1 credit = 1 video, paid '
                        'in Telegram Stars.'
                    : '${a.freeRemaining} of ${a.freeLimit} free generations today · '
                        'credits: ${a.credits}. 1 credit = 1 image, paid '
                        'in Telegram Stars.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              for (final p in widget.video ? a.videoPackages : a.packages)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(p.label),
                  trailing: FilledButton(
                    onPressed: _buyingId == null ? () => _buy(p) : null,
                    child: _buyingId == p.id
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('${p.stars} ⭐'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
