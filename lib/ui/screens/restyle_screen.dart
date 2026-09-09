import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/restyle_styles.dart';
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
class RestyleScreen extends ConsumerStatefulWidget {
  const RestyleScreen({super.key});

  @override
  ConsumerState<RestyleScreen> createState() => _RestyleScreenState();
}

class _RestyleScreenState extends ConsumerState<RestyleScreen> {
  Uint8List? _imageBytes;
  RestyleMedium _medium = RestyleMedium.photo;
  String? _styleId;
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
            prompt: '${style.label} · ${medium.label}',
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

    return Scaffold(
      appBar: const TsumikiAppBar(screen: TsumikiScreen.restyle),
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
              'Keeps your face and pose. Works best with a clear, '
              'front-facing photo of one person.',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          Text('Medium', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<RestyleMedium>(
            segments: [
              for (final m in RestyleMedium.values)
                ButtonSegment(
                  value: m,
                  label: Text(m.label),
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
          Text('Style', style: theme.textTheme.titleMedium),
          for (final group in kRestyleGroups) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 6),
              child: Text(group, style: theme.textTheme.labelLarge),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final s in restyleStylesIn(group))
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
        label: Text(_busy ? 'Restyling…' : 'Restyle'),
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
                      Text('Pick a photo'),
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
                            'Restyling… about a minute.\n'
                            'The image also arrives in your chat.',
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
