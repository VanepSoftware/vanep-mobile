import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/ui/vanep_brand_splash.dart';
import 'package:vanep_mobile/core/ui/vanep_intro_frame.dart';

class VanepIntroGate extends StatefulWidget {
  const VanepIntroGate({required this.child, super.key});

  final Widget child;

  @override
  State<VanepIntroGate> createState() => VanepIntroGateState();
}

class VanepIntroGateState extends State<VanepIntroGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: vanepIntroDuration,
  );
  bool _introFinished = false;

  @override
  void initState() {
    super.initState();
    _intro
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _introFinished = true);
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showsIntro =
        !_introFinished && !MediaQuery.disableAnimationsOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(excluding: showsIntro, child: widget.child),
        if (showsIntro) VanepIntroOverlay(progress: _intro),
      ],
    );
  }
}

class VanepIntroOverlay extends StatelessWidget {
  const VanepIntroOverlay({required this.progress, super.key});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, _) => Opacity(
          opacity: fadeOutVanepIntroOverlay(progress.value),
          child: VanepBrandSplash(frame: VanepIntroFrame.at(progress.value)),
        ),
      ),
    );
  }
}
