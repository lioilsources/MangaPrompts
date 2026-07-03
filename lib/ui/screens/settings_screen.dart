import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    if (_apiKeyController.text.isEmpty && apiKey.isNotEmpty) {
      _apiKeyController.text = apiKey;
    }
    if (_cfIdController.text.isEmpty && cfId.isNotEmpty) {
      _cfIdController.text = cfId;
    }
    if (_cfSecretController.text.isEmpty && cfSecret.isNotEmpty) {
      _cfSecretController.text = cfSecret;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nastavení')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Backend pro generování',
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
              'API klíč z console.x.ai pro generování přes Grok.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyController,
              obscureText: _obscureKey,
              decoration: InputDecoration(
                labelText: 'API klíč',
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
              'Lokální AiStack (Flux diffusers API). '
              'Zadej CF Access service token nebo nech prázdné '
              'pokud je nastaven při buildu (--dart-define).',
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
              'Lokální ComfyUI (Flux / Pony workflow). '
              'Sdílí CF Access token s llm.ol1n.com.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text('Workflow', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'flux', label: Text('Flux')),
                ButtonSegment(value: 'pony', label: Text('Pony Diffusion')),
              ],
              selected: {comfyWorkflow},
              onSelectionChanged: (s) => _setComfyWorkflow(s.first),
            ),
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
        label: const Text('Uložit'),
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
          'Uloženo',
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
    _showSnack('API klíč uložen');
  }

  void _saveCfCredentials() {
    final id = _cfIdController.text.trim();
    final secret = _cfSecretController.text.trim();
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString('ol1n_cf_id', id);
    prefs.setString('ol1n_cf_secret', secret);
    ref.read(ol1nCfIdProvider.notifier).state = id;
    ref.read(ol1nCfSecretProvider.notifier).state = secret;
    _showSnack('Uloženo');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }
}
