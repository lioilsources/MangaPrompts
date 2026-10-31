import 'package:flutter/material.dart';

import '../backend/account.dart';

/// Bottom sheet with the day's quota and what a planned render will spend.
/// There is nothing to buy here: payments belong to Tsumiki.
class QuotaSheet extends StatelessWidget {
  const QuotaSheet({super.key, required this.account, this.cost});

  final Account account;

  /// Generations the render on screen will spend, when there is one.
  final int? cost;

  static Future<void> show(
    BuildContext context,
    Account account, {
    int? cost,
  }) => showModalBottomSheet(
    context: context,
    builder: (_) => QuotaSheet(account: account, cost: cost),
  );

  bool get _enough => cost == null || cost! <= account.totalRemaining;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kvóta', style: text.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Dnes zbývá ${account.freeRemaining} z ${account.freeLimit} '
              'obrázků zdarma · kredity: ${account.credits}',
              style: text.bodySmall,
            ),
            if (cost != null) ...[
              const SizedBox(height: 12),
              Text(
                _enough
                    ? 'Tenhle render stojí $cost.'
                    : 'Tenhle render stojí $cost, kvóta nestačí.',
                style: text.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
