import 'package:flutter/material.dart';
import 'package:mira_fashon/features/onboarding/data/onboardingmodel.dart';

// ✅ StatefulWidget + KeepAlive ensures the page widget (and its decoded
// image) is NEVER destroyed when you swipe away. No re-decode on swipe back.
class OnboardingPage extends StatefulWidget {
  final OnboardingModel data;
  const OnboardingPage({super.key, required this.data});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // ✅ Never unmount this page

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by mixin
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(
          image: AssetImage(widget.data.image),
          fit: BoxFit.cover,
          // ✅ Never flash blank between rebuilds
          gaplessPlayback: true,
          // ✅ Only animate on very first load; instant if cached
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeIn,
              child: child,
            );
          },
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.4, 1.0],
              colors: [Colors.transparent, Colors.black87],
            ),
          ),
        ),
      ],
    );
  }
}
