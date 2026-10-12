import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vanep_mobile/core/ui/vanep_brand_backdrop.dart';
import 'package:vanep_mobile/core/ui/vanep_intro_frame.dart';
import 'package:vanep_mobile/core/ui/vanep_logo.dart';

const double vanepSplashLogoWidth = 200;

class VanepBrandSplash extends StatelessWidget {
  const VanepBrandSplash({this.frame, super.key});

  final VanepIntroFrame? frame;

  @override
  Widget build(BuildContext context) {
    final shownFrame = frame ?? VanepIntroFrame.rest();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: VanepBrandBackdrop(
        gradientOpacity: shownFrame.backdropReveal,
        sheenCenter: shownFrame.sheenCenter,
        child: Center(
          child: Transform.scale(
            scale: shownFrame.logoScale,
            child: VanepLogo(
              width: vanepSplashLogoWidth,
              letterReveals: shownFrame.letterReveals,
            ),
          ),
        ),
      ),
    );
  }
}
