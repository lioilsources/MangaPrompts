import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/l10n.dart';
import '../../providers/api_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late TextEditingController _cfIdController;
  late TextEditingController _cfSecretController;
  bool _obscureKey = true;
  bool _obscureCfSecret = true;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _cfIdController = TextEditingController();
    _cfSecretController = TextEditingController();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _cfIdController.dispose();
    _cfSecretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(providerTypeProvider);
    final apiKey = ref.watch(apiKeyProvider);
    final cfId = ref.watch(ol1nCfIdProvider);
    final cfSecret = ref.watch(ol1nCfSecretProvider);
    final comfyWorkflow = ref.watch(comfyWorkflowProvider);
    final l = context.l10n;

    if (_apiKeyController.text.isEmpty && apiKey.isNotEmpty) {
      _apiKeyController.text = apiKey;
    }
    if (_cfIdController.text.isEmpty && cfId.isNotEmpty) {
      _cfIdController.text = cfId;
    }
    if (_cfSecretController.text.isEmpty && cfSecret.isNotEmpty) {
      _cfSecretController.text = cfSecret;
    }

    // Web (Telegram Mini App) always generates through the bot backend —
    // no provider switch, no credentials, just the workflow choice.
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: Text(l.settings)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l.generation,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l.generationWebInfo,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(l.workflow, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            _workflowSelector(comfyWorkflow),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l.generationBackend,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'xai', label: Text('xAI / Grok')),
              ButtonSegment(value: 'ol1n', label: Text('llm.ol1n.com')),
              ButtonSegment(value: 'comfyui', label: Text('ComfyUI')),
            ],
            selected: {provider},
            onSelectionChanged: (s) => _setProvider(s.first),
          ),
          const SizedBox(height: 24),

          if (provider == 'xai') ...[
            Text('xAI API', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              l.xaiInfo,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyController,
              obscureText: _obscureKey,
              decoration: InputDecoration(
                labelText: l.apiKey,
                hintText: 'xai-...',
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _obscureKey ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _obscureKey = !_obscureKey),
                    ),
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: _saveApiKey,
                    ),
                  ],
                ),
              ),
              onSubmitted: (_) => _saveApiKey(),
            ),
            const SizedBox(height: 8),
            if (apiKey.isNotEmpty) _savedBadge(context),

          ] else if (provider == 'ol1n') ...[
            Text(
              'llm.ol1n.com — Cloudflare Access',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              l.ol1nInfo,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ..._cfCredentialFields(context, cfId),
            const SizedBox(height: 8),
            if (cfId.isNotEmpty) _savedBadge(context),

          ] else ...[
            // ComfyUI
            Text(
              'ComfyUI — comfyui.ol1n.com',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              l.comfyInfo,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(l.workflow, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            _workflowSelector(comfyWorkflow),
            const SizedBox(height: 20),
            ..._cfCredentialFields(context, cfId),
            const SizedBox(height: 8),
            if (cfId.isNotEmpty) _savedBadge(context),
          ],
        ],
      ),
    );
  }

  List<Widget> _cfCredentialFields(BuildContext context, String cfId) {
    return [
      TextField(
        controller: _cfIdController,
        decoration: const InputDecoration(
          labelText: 'CF Client ID',
          hintText: 'xxxxxxxx.access',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _cfSecretController,
        obscureText: _obscureCfSecret,
        decoration: InputDecoration(
          labelText: 'CF Client Secret',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureCfSecret ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () => setState(() => _obscureCfSecret = !_obscureCfSecret),
          ),
        ),
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        icon: const Icon(Icons.save),
        label: Text(context.l10n.save),
        onPressed: _saveCfCredentials,
      ),
    ];
  }

  Widget _savedBadge(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle,
            size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          context.l10n.saved,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }

  void _setProvider(String type) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString('provider_type', type);
    ref.read(providerTypeProvider.notifier).state = type;
  }

  /// Model / ComfyUI workflow picker. Kept as one widget so both the Telegram
  /// and the local-ComfyUI section stay in sync when a model is added.
  Widget _workflowSelector(String current) {
    final l = context.l10n;
    final options = {
      'auto': l.wfAuto,
      'flux': l.wfFlux,
      'pony': l.wfPony,
      'juggernaut': l.wfJuggernaut,
      'wai': l.wfWai,
    };
    final effective = ref.watch(effectiveWorkflowProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: options.containsKey(current) ? current : 'auto',
          decoration: const InputDecoration(border: OutlineInputBorder()),
          isExpanded: true,
          items: [
            for (final e in options.entries)
              DropdownMenuItem(value: e.key, child: Text(e.value)),
          ],
          onChanged: (wf) {
            if (wf != null) _setComfyWorkflow(wf);
          },
        ),
        // Auto must never be silent: show which model it landed on.
        if (current == 'auto')
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l.templateChose(effective),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  void _setComfyWorkflow(String wf) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString('comfy_workflow', wf);
    ref.read(comfyWorkflowProvider.notifier).state = wf;
  }

  void _saveApiKey() {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) return;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString('xai_api_key', key);
    ref.read(apiKeyProvider.notifier).state = key;
    _showSnack(context.l10n.apiKeySaved);
  }

  void _saveCfCredentials() {
    final id = _cfIdController.text.trim();
    final secret = _cfSecretController.text.trim();
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString('ol1n_cf_id', id);
    prefs.setString('ol1n_cf_secret', secret);
    ref.read(ol1nCfIdProvider.notifier).state = id;
    ref.read(ol1nCfSecretProvider.notifier).state = secret;
    _showSnack(context.l10n.saved);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }
}
