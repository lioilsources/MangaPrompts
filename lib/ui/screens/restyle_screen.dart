import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/restyle_styles.dart';
import '../../l10n/l10n.dart';
import '../../providers/account_provider.dart';
import '../../services/telegram_backend_service.dart';
import '../widgets/paywall_sheet.dart';
import '../widgets/tsumiki_app_bar.dart';
import 'result_screen.dart';

/// Photo → the same person in the same pose, rendered in a chosen style.
///
/// The bot backend runs one SDXL job with a depth ControlNet (pose) and
/// InstantID (face) on the uploaded photo; the app only composes the prompt
/// from the medium toggle + style and shows the result. Priced like a
/// generation from the prompt builder — same free quota, same credits.
/// Localized button text of a [RestyleMedium].
String restyleMediumLabel(AppLocalizations l, RestyleMedium m) => switch (m) {
  RestyleMedium.photo => l.mediumPhoto,
  RestyleMedium.illustration => l.mediumIllustration,
};

/// Localized heading of a restyle section; unknown sections keep their id.
String restyleGroupLabel(AppLocalizations l, String group) => switch (group) {
  kRestyleGroupPopular => l.groupPopular,
  kRestyleGroupPainters => l.groupPainters,
  kRestyleGroupAsia => l.groupAsia,
  kRestyleGroupEurope => l.groupEurope,
  kRestyleGroupAmericasOceania => l.groupAmericasOceania,
  kRestyleGroupAfricaNearEast => l.groupAfricaNearEast,
  _ => group,
};

class RestyleScreen extends ConsumerStatefulWidget {
  const RestyleScreen({super.key});

  @override
  ConsumerState<RestyleScreen> createState() => _RestyleScreenState();
}

class _RestyleScreenState extends ConsumerState<RestyleScreen> {
  Uint8List? _imageBytes;
  RestyleMedium _medium = RestyleMedium.photo;
  String? _styleId;
  String _query = '';
  bool _busy = false;
  String? _error;

  Future<void> _pickPhoto() async {
    // InstantID and the depth map both work at ≤1 MP; 1536 px keeps the
    // base64 upload small without costing the face any detail.
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
    final style = restyleStyleById(_styleId);
    if (bytes == null || style == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final medium = _medium;
    final mediumLabel = restyleMediumLabel(context.l10n, medium);
    try {
      final result = await TelegramBackendService.restyleImage(
        imageBytes: bytes,
        prompt: restylePrompt(style, medium),
        negativePrompt: restyleNegative(medium),
        medium: medium.wire,
        styleLabel: style.label,
      );
      ref.invalidate(accountProvider);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            imageUrl: result.url,
            prompt: '${style.label} · $mediumLabel',
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
    final canSubmit = _imageBytes != null && _styleId != null && !_busy;
    final l = context.l10n;
    final q = _query.trim().toLowerCase();
    // The filter also matches the localized section name.
    bool matches(RestyleStyle s) =>
        restyleStyleMatchesQuery(s, _query) ||
        restyleGroupLabel(l, s.group).toLowerCase().contains(q);

    return Scaffold(
      appBar: const TsumikiAppBar(screen: TsumikiScreen.restyle),
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
              l.restyleHint,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          Text(l.medium, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<RestyleMedium>(
            segments: [
              for (final m in RestyleMedium.values)
                ButtonSegment(
                  value: m,
                  label: Text(restyleMediumLabel(l, m)),
                  icon: Icon(m == RestyleMedium.photo
                      ? Icons.photo_camera_outlined
                      : Icons.brush_outlined),
                ),
            ],
            selected: {_medium},
            onSelectionChanged: _busy
                ? null
                : (s) => setState(() => _medium = s.first),
          ),
          const SizedBox(height: 16),
          Text(l.style, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          // 90 styles in six sections is a long scroll on a phone; the filter
          // matches labels and section names ("painters" lists that section).
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l.filterStyles,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          for (final group in kRestyleGroups)
            if (restyleStylesIn(group).any(matches)) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: Text(
                  restyleGroupLabel(l, group),
                  style: theme.textTheme.labelLarge,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final s in restyleStylesIn(group))
                    if (matches(s))
                      ChoiceChip(
                        label: Text(s.label),
                        selected: s.id == _styleId,
                        onSelected: _busy
                            ? null
                            : (_) => setState(() => _styleId = s.id),
                      ),
                ],
              ),
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
            : const Icon(Icons.face_retouching_natural),
        label: Text(_busy ? l.restyling : l.restyle),
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
                      Text(context.l10n.pickPhoto),
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
                            context.l10n.restyleBusy,
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
