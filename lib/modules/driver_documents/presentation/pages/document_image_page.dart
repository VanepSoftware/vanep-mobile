import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/network/api_image_loader.dart';
import 'package:vanep_mobile/core/network/api_image_provider.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';

class DocumentImagePage extends StatelessWidget {
  const DocumentImagePage({
    required this.title,
    required this.imageUrl,
    required this.loader,
    super.key,
  });

  final String title;
  final String imageUrl;
  final ApiImageLoader loader;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: VanepAppBar(title: title),
      body: InteractiveViewer(
        maxScale: 5,
        child: Center(
          child: Image(
            image: ApiImageProvider(path: imageUrl, loader: loader),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
