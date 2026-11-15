import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/ui/vanep_brand_backdrop.dart';
import 'package:vanep_mobile/core/ui/vanep_logo.dart';

const double vanepSplashLogoWidth = 200;

class VanepBrandSplash extends StatelessWidget {
  const VanepBrandSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return const VanepBrandBackdrop(
      child: Center(child: VanepLogo(width: vanepSplashLogoWidth)),
    );
  }
}
