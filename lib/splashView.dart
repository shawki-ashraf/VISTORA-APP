import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'features/onboarding/view/onboarding_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final List<String> images = const [
    "assets/b1.jpg",
    "assets/b2.jpg",
    "assets/b3.jpg",
  ];

  bool _ready = false;

  Future<void> preloadImages() async {
    for (final img in images) {
      await precacheImage(AssetImage(img), context);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _start();
    });
  }

  Future<void> _start() async {
    await preloadImages();

    if (!mounted) return;

    setState(() => _ready = true);

    await Future.delayed(const Duration(milliseconds: 200));

    _navigate();
  }

  void _navigate() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const OnboardingView(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _ready
            ? const SizedBox()
            : Center(
                child: SvgPicture.asset("assets/v2.svg", fit: BoxFit.contain),
              ),
      ),
    );
  }
}
