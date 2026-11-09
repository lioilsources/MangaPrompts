import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

class ReposeScreen extends StatelessWidget {
  const ReposeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.reposeTitle)),
      body: Center(child: Text(context.l10n.reposeWebUnavailable)),
    );
  }
}
