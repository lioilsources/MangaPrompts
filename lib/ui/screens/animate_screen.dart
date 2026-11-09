import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/l10n.dart';
import '../../providers/account_provider.dart';
import '../../providers/video_scenes_provider.dart';
import '../../services/telegram_backend_service.dart';
import '../widgets/paywall_sheet.dart';
import '../widgets/tsumiki_app_bar.dart';

/// Photo → short video animation (Wan 2.2 on SPARK, via the bot backend).
/// The finished mp4 is delivered by the bot into the user's chat — this screen
/// only picks the photo + scene and shows render progress, so closing the app
/// mid-render is harmless.
class AnimateScreen extends ConsumerStatefulWidget {
  const AnimateScreen({super.key});

  @override
  ConsumerState<AnimateScreen> createState() => _AnimateScreenState();
}

class _AnimateScreenState extends ConsumerState<AnimateScreen> {
  Uint8List? _imageBytes;
  String? _sceneId;
  bool _submitting = false;
  TgVideoJob? _job;
  TgVideoStatus? _status;
  Timer? _pollTimer;
  int _pollFailures = 0;
  String? _error;

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    // maxWidth keeps the base64 upload small; the render resolution is chosen
    // server-side from the aspect ratio anyway.
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 90,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _job = null;
      _status = null;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final bytes = _imageBytes;
    final sceneId = _sceneId;
    if (bytes == null || sceneId == null) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final job = await TelegramBackendService.startAnimation(
        sceneId: sceneId,
        imageBytes: bytes,
      );
      if (!mounted) return;
      setState(() {
        _job = job;
        _status = const TgVideoStatus(status: 'queued');
        _pollFailures = 0;
      });
      _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
      ref.invalidate(accountProvider);
    } on PaymentRequiredException {
      if (!mounted) return;
      ref.invalidate(accountProvider);
      await PaywallSheet.show(context, video: true);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _poll() async {
    final job = _job;
    if (job == null) return;
    try {
      final status = await TelegramBackendService.videoJobStatus(job.jobId);
      if (!mounted) return;
      setState(() {
        _status = status;
        _pollFailures = 0;
      });
      if (status.status == 'done' || status.status == 'error') {
        _pollTimer?.cancel();
        ref.invalidate(accountProvider);
      }
    } catch (_) {
      // The render runs server-side and delivers to the chat, so a flaky app
      // connection is not fatal — tolerate a few misses before saying so.
      _pollFailures++;
      if (_pollFailures >= 6 && mounted) {
        _pollTimer?.cancel();
        setState(() => _error = context.l10n.connectionLostVideo);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenesAsync = ref.watch(videoScenesProvider);
    final account = ref.watch(accountProvider);
    final l = context.l10n;

    return Scaffold(
      appBar: const TsumikiAppBar(screen: TsumikiScreen.animate),
      body: scenesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l.videoServerDown('$e'),
                textAlign: TextAlign.center),
          ),
        ),
        data: (scenes) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            account.maybeWhen(
              data: (a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  l.videoQuota(
                    a.videoFreeRemaining,
                    a.videoFreeLimit,
                    a.videoCredits,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            _photoCard(),
            const SizedBox(height: 16),
            Text(l.scene, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final scene in scenes) _sceneTile(scene),
            const SizedBox(height: 16),
            if (_job == null) ...[
              FilledButton.icon(
                icon: const Icon(Icons.movie_creation_outlined),
                label: Text(_submitting ? l.uploading : l.animate),
                onPressed: _imageBytes != null &&
                        _sceneId != null &&
                        !_submitting
                    ? _submit
                    : null,
              ),
            ] else
              _progressCard(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _photoCard() {
    final bytes = _imageBytes;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _job == null ? _pickPhoto : null,
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
            : ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: Image.memory(bytes, fit: BoxFit.contain),
              ),
      ),
    );
  }

  Widget _sceneTile(TgVideoScene scene) {
    final selected = scene.id == _sceneId;
    return Card(
      color: selected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: ListTile(
        title: Text(scene.label),
        subtitle: Text(
          '${scene.desc}\n'
          '${context.l10n.sceneInfo(scene.seconds.round(), scene.minutesEst)}',
        ),
        isThreeLine: scene.desc.isNotEmpty,
        selected: selected,
        onTap: _job == null
            ? () => setState(() => _sceneId = scene.id)
            : null,
      ),
    );
  }

  Widget _progressCard() {
    final status = _status;
    final l = context.l10n;
    final (String label, bool busy) = switch (status?.status) {
      'queued' => (
          status?.position != null
              ? l.queuePosition(status!.position! + 1)
              : l.queueWaiting,
          true
        ),
      'running' => (
          status!.phase != null && status.beat >= status.beats
              ? l.finishing
              : l.beatProgress(
                  status.beat + 1,
                  status.beats,
                  ((status.beats - status.beat) * 2.5).ceil(),
                ),
          true
        ),
      'done' => (l.videoDone, false),
      'error' => (l.failedDetail(status?.error ?? l.unknownError), false),
      _ => (l.starting, true),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (busy)
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      status?.status == 'done'
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                    ),
                  ),
                Expanded(child: Text(label)),
              ],
            ),
            if (busy)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l.canCloseApp,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (status?.status == 'error' &&
                (status?.error ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l.notCharged,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (status?.status == 'done' || status?.status == 'error')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _job = null;
                    _status = null;
                    _error = null;
                  }),
                  child: Text(l.animateAnother),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
