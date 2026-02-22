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
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = ref.watch(apiKeyProvider);

    // Sync controller with current value (only if user isn't editing)
    if (_apiKeyController.text.isEmpty && apiKey.isNotEmpty) {
      _apiKeyController.text = apiKey;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nastavení')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'xAI API',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Zadej API klíč z console.x.ai pro generování obrázků.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'API klíč',
              hintText: 'xai-...',
              border: const OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
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
          if (apiKey.isNotEmpty)
            Row(
              children: [
                Icon(Icons.check_circle,
                    size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  'API klíč uložen',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _saveApiKey() {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) return;

    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString('xai_api_key', key);
    ref.read(apiKeyProvider.notifier).state = key;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('API klíč uložen'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
