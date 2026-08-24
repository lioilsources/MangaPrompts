import 'package:flutter/material.dart';

class ReposeScreen extends StatelessWidget {
  const ReposeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Repose')),
      body: const Center(child: Text('Repose is not available on the web')),
    );
  }
}
