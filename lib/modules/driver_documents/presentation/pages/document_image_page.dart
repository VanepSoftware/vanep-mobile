import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';

class DocumentImagePage extends StatefulWidget {
  const DocumentImagePage({
    required this.title,
    required this.images,
    this.initialPage = 0,
    super.key,
  });

  final String title;
  final List<ImageProvider> images;
  final int initialPage;

  @override
  State<DocumentImagePage> createState() => DocumentImagePageState();
}

class DocumentImagePageState extends State<DocumentImagePage> {
  late final PageController controller = PageController(
    initialPage: widget.initialPage,
  );
  bool zoomed = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: VanepAppBar(title: widget.title),
      body: PageView.builder(
        controller: controller,
        physics: zoomed ? const NeverScrollableScrollPhysics() : null,
        itemCount: images.length,
        itemBuilder: (context, index) => ZoomableImage(
          image: images[index],
          onZoomChanged: (value) {
            if (value != zoomed) setState(() => zoomed = value);
          },
        ),
      ),
    );
  }
}

class ZoomableImage extends StatefulWidget {
  const ZoomableImage({
    required this.image,
    required this.onZoomChanged,
    super.key,
  });

  final ImageProvider image;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<ZoomableImage> createState() => ZoomableImageState();
}

class ZoomableImageState extends State<ZoomableImage> {
  final transformation = TransformationController();

  @override
  void dispose() {
    transformation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: transformation,
      maxScale: 5,
      onInteractionEnd: (_) =>
          widget.onZoomChanged(transformation.value.getMaxScaleOnAxis() > 1),
      child: Center(
        child: Image(
          image: widget.image,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) =>
              const Icon(Icons.broken_image_outlined, color: Colors.white54),
        ),
      ),
    );
  }
}
