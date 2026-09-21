import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';
import 'vanep_coming_soon.dart';

class VanepComingSoonPage extends StatelessWidget {
  const VanepComingSoonPage({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VanepColors.surface,
      appBar: AppBar(),
      body: VanepComingSoon(title: title, message: message),
    );
  }
}

Future<void> openComingSoonPage(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => VanepComingSoonPage(title: title, message: message),
    ),
  );
}
