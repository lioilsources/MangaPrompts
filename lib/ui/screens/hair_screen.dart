import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/hairstyles.dart';
import '../../l10n/l10n.dart';
import '../../providers/account_provider.dart';
import '../../services/telegram_backend_service.dart';
import '../widgets/paywall_sheet.dart';
import '../widgets/tsumiki_app_bar.dart';
import 'result_screen.dart';

/// Portrait → the same photo with a new haircut.
///
/// The bot reads the face and hair off the photo first (free), builds an
/// inpaint mask from the chosen style's shape and keeps the hair colour; only
/// then is the generation billed — same free quota and credits as the prompt
/// builder. The face pixels sit outside the mask, so identity is kept by
/// construction rather than by an adapter.
/// Localized name of a hairstyle group or section; unknown ids stay as-is.
String hairHeadingLabel(AppLocalizations l, String id) => switch (id) {
  kHairGroupWomen => l.hairWomen,
  kHairGroupMen => l.hairMen,
  'Cuts' => l.hairCuts,
  'Bangs' => l.hairBangs,
  'Texture' => l.hairTexture,
  'Short' => l.hairShort,
  'Medium' => l.hairMedium,
  'Long' => l.hairLong,
  'Braids' => l.hairBraids,
  'Updos' => l.hairUpdos,
  _ => id,
};

class HairScreen extends ConsumerStatefulWidget {
  const HairScreen({
    super.key,
    this.catalog = kHairstyles,
    this.colours = kHairColours,
  });

  /// Injectable for tests; the app always shows [kHairstyles].
  final List<Hairstyle> catalog;

  /// Injectable for tests; the app always shows [kHairColours].
  final List<HairColour> colours;

  @override
  ConsumerState<HairScreen> createState() => _HairScreenState();
}

class _HairScreenState extends ConsumerState<HairScreen> {
  Uint8List? _imageBytes;
  String _group = kHairGroupWomen;
  String? _styleId;

  /// Null keeps the colour the bot reads off the photo.
  String? _colourId;
  bool _busy = false;
  String? _error;

  HairColour? get _colour {
    for (final c in widget.colours) {
      if (c.id == _colourId) return c;
    }
    return null;
  }

  Hairstyle? get _style {
    for (final s in widget.catalog) {
      if (s.id == _styleId) return s;
    }
    return null;
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1536,
      imageQuality: 88,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final bytes = _imageBytes;
    final style = _style;
    final colour = _colour;
    // A colour alone is a whole request: same cut, new colour.
    if (bytes == null || (style == null && colour == null)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await TelegramBackendService.hairImage(
        imageBytes: bytes,
        styleId: style?.id ?? kKeepCutId,
        block: style?.block ?? kKeepCutBlock,
        styleLabel: style?.label ?? '',
        shape: (style?.shape ?? const HairShape(length: HairLength.keep))
            .toJson(),
        colour: colour?.id,
      );
      ref.invalidate(accountProvider);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            imageUrl: result.url,
            prompt: [
              style?.label,
              colour?.label,
            ].whereType<String>().join(' · '),
            imageBytes: result.bytes,
          ),
        ),
      );
    } on PaymentRequiredException {
      if (!mounted) return;
      ref.invalidate(accountProvider);
      await PaywallSheet.show(context);
    } catch (e) {
      ref.invalidate(accountProvider);
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountProvider);
    final theme = Theme.of(context);
    final canSubmit =
        _imageBytes != null && (_style != null || _colour != null) && !_busy;
    final groups = kHairGroups.where(
      (g) => widget.catalog.any((s) => s.group == g),
    );
    final l = context.l10n;

    return Scaffold(
      appBar: const TsumikiAppBar(screen: TsumikiScreen.hair),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          account.maybeWhen(
            data: (a) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                l.imageQuota(a.freeRemaining, a.freeLimit, a.credits),
                style: theme.textTheme.bodySmall,
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          _photoCard(),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l.hairHint,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.catalog.isEmpty && widget.colours.isEmpty)
            Text(
              l.noHairstyles,
              style: theme.textTheme.bodyMedium,
            ),
          if (widget.colours.isNotEmpty) ...[
            Text(l.colour, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: Text(l.keepMine),
                  selected: _colourId == null,
                  onSelected: _busy
                      ? null
                      : (_) => setState(() => _colourId = null),
                ),
                for (final g in kHairColourGroups)
                  for (final c in widget.colours.where((c) => c.group == g))
                    ChoiceChip(
                      avatar: c.swatch == null
                          ? null
                          : CircleAvatar(backgroundColor: Color(c.swatch!)),
                      label: Text(c.label),
                      selected: c.id == _colourId,
                      onSelected: _busy
                          ? null
                          : (_) => setState(() => _colourId = c.id),
                    ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (widget.catalog.isNotEmpty) ...[
            Text(l.haircut, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (widget.colours.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: ChoiceChip(
                  label: Text(l.keepMyCut),
                  selected: _styleId == null,
                  onSelected: _busy
                      ? null
                      : (_) => setState(() => _styleId = null),
                ),
              ),
            if (groups.length > 1)
              SegmentedButton<String>(
                segments: [
                  for (final g in groups)
                    ButtonSegment(
                      value: g,
                      label: Text(hairHeadingLabel(l, g)),
                    ),
                ],
                selected: {_group},
                onSelectionChanged: _busy
                    ? null
                    : (s) => setState(() => _group = s.first),
              ),
            for (final section in kHairSections)
              if (hairstylesIn(_group, section, widget.catalog).isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 6),
                  child: Text(
                    hairHeadingLabel(l, section),
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in hairstylesIn(
                      _group,
                      section,
                      widget.catalog,
                    ))
                      _StyleCard(
                        style: s,
                        selected: s.id == _styleId,
                        onTap: _busy
                            ? null
                            : () => setState(() => _styleId = s.id),
                      ),
                  ],
                ),
              ],
          ],
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: canSubmit ? _submit : null,
        icon: _busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.content_cut),
        label: Text(
          _busy
              ? l.working
              : (_style == null && _colour != null
                    ? l.newColour
                    : l.newHaircut),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _photoCard() {
    final bytes = _imageBytes;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _busy ? null : _pickPhoto,
        child: bytes == null
            ? SizedBox(
                height: 160,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_photo_alternate_outlined, size: 40),
                      const SizedBox(height: 8),
                      Text(context.l10n.pickPortrait),
                    ],
                  ),
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: Image.memory(bytes, fit: BoxFit.contain),
                  ),
                  if (_busy)
                    Container(
                      color: Colors.black45,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.hairBusy,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

/// One hairstyle to pick: the bench's own output for it on the same synthetic
/// face as every other card, so the row compares hair and nothing else. A
/// card whose picture was not exported keeps the name over a plain tile.
class _StyleCard extends StatelessWidget {
  const _StyleCard({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final Hairstyle style;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 96,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Image.asset(
                  style.preview,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: scheme.surfaceContainerHighest,
                    child: Icon(Icons.content_cut, color: scheme.primary),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 4, 2, 2),
              child: Text(
                style.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? scheme.primary : null,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
