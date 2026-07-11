import 'package:flutter/material.dart';

/// Vanep brand palette — navy gradient + teal accent (from vanep-frontend).
class VanepColors {
  static const Color backgroundDeep = Color(0xFF071D37);
  static const Color backgroundMid = Color(0xFF0A2C50);
  static const Color backgroundSoft = Color(0xFF103E6E);
  static const Color foreground = Color(0xFFEAF4FB);
  static const Color brand = Color(0xFF5CBCD6);
}

class VanepApp extends StatelessWidget {
  const VanepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vanep',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: VanepColors.brand,
          brightness: Brightness.dark,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        // Base navy gradient (linear-gradient 155deg from the frontend).
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.6, -1),
            end: Alignment(0.6, 1),
            colors: [
              VanepColors.backgroundDeep,
              VanepColors.backgroundMid,
              VanepColors.backgroundSoft,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Teal glow, upper-right (radial-gradient at 72% 38%).
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.44, -0.24),
                    radius: 1.1,
                    colors: [
                      Color(0x335CBCD6),
                      Color(0x005CBCD6),
                    ],
                    stops: [0.0, 0.6],
                  ),
                ),
              ),
            ),
            // Softer glow, lower-left (radial-gradient at 8% 88%).
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.84, 0.76),
                    radius: 1.0,
                    colors: [
                      Color(0x2445A9C6),
                      Color(0x0045A9C6),
                    ],
                    stops: [0.0, 0.55],
                  ),
                ),
              ),
            ),
            Center(child: _Wordmark()),
          ],
        ),
      ),
    );
  }
}

/// The "vanep." logotype recreated in text, matching the brand wordmark.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'vanep', style: TextStyle(color: VanepColors.foreground)),
          TextSpan(text: '.', style: TextStyle(color: VanepColors.brand)),
        ],
        style: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.7,
          height: 1,
        ),
      ),
    );
  }
}
