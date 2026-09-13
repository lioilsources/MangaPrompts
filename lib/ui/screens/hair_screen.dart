import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/hairstyles.dart';
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
class HairScreen extends ConsumerStatefulWidget {
  const HairScreen({super.key, this.catalog = kHairstyles});

  /// Injectable for tests; the app always shows [kHairstyles].
  final List<Hairstyle> catalog;

  @override
  ConsumerState<HairScreen> createState() => _HairScreenState();
}

class _HairScreenState extends ConsumerState<HairScreen> {
  Uint8List? _imageBytes;
  String _group = kHairGroupWomen;
  String? _styleId;
  bool _busy = false;
  String? _error;

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
    if (bytes == null || style == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await TelegramBackendService.hairImage(
        imageBytes: bytes,
        styleId: style.id,
        block: style.block,
        styleLabel: style.label,
        shape: style.shape.toJson(),
      );
      ref.invalidate(accountProvider);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            imageUrl: result.url,
            prompt: style.label,
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
    final canSubmit = _imageBytes != null && _style != null && !_busy;
    final groups = kHairGroups.where(
      (g) => widget.catalog.any((s) => s.group == g),
    );

    return Scaffold(
      appBar: const TsumikiAppBar(screen: TsumikiScreen.hair),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          account.maybeWhen(
            data: (a) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${a.freeRemaining} of ${a.freeLimit} free generations today · '
                'credits: ${a.credits}',
                style: theme.textTheme.bodySmall,
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          _photoCard(),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Keeps your face and hair colour. Works best with a front-facing '
              'portrait, hair fully visible, no hat.',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.catalog.isEmpty)
            Text(
              'No hairstyles yet — check back soon.',
              style: theme.textTheme.bodyMedium,
            )
          else ...[
            if (groups.length > 1)
              SegmentedButton<String>(
                segments: [
                  for (final g in groups)
                    ButtonSegment(value: g, label: Text(g)),
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
                  child: Text(section, style: theme.textTheme.labelLarge),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final s in hairstylesIn(
                      _group,
                      section,
                      widget.catalog,
                    ))
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
        label: Text(_busy ? 'Cutting…' : 'New haircut'),
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
            ? const SizedBox(
                height: 160,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 40),
                      SizedBox(height: 8),
                      Text('Pick a portrait'),
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
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text(
                            'Cutting… about a minute.\n'
                            'The photo also arrives in your chat.',
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
