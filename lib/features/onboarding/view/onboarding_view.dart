import 'package:flutter/material.dart';
import 'package:mira_fashon/features/auth/login_view/view/login_view.dart';
import 'package:mira_fashon/features/onboarding/data/onboardingmodel.dart';
import 'package:mira_fashon/features/onboarding/widgets/onboarding.dart';
import 'package:mira_fashon/features/shared_widgets/customtext.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _controller = PageController();
  final ValueNotifier<int> currentIndex = ValueNotifier(0);

  static const _kBrown = Color(0xFF795548);

  final List<OnboardingModel> onboardingData = const [
    OnboardingModel(
      image: "assets/b1.jpg",
      title: "Get Ready To Shine With Elegant Looks ✨",
      description:
          "We offer you a distinctive selection of clothes that combine high quality and unique designs.",
    ),
    OnboardingModel(
      image: "assets/b2.jpg",
      title: "Every Piece Has A Touch Of Love ❤",
      description:
          "We select the best for you and provide it with the quality you deserve.",
    ),
    OnboardingModel(
      image: "assets/b3.jpg",
      title: "Elegance Suits You, Choose The Right One!",
      description:
          "Our models are designed to suit you everywhere. Let your style speak for you.",
    ),
  ];

  @override
  void initState() {
    super.initState();

    /// 🔥 preload images بدون ما نوقف UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var item in onboardingData) {
        precacheImage(AssetImage(item.image), context);
      }
    });
  }

  void _goToRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

  void _nextPage() {
    if (currentIndex.value == onboardingData.length - 1) {
      _goToRegister();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (currentIndex.value > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -100) _nextPage();
          if ((details.primaryVelocity ?? 0) > 100) _previousPage();
        },
        child: Stack(
          children: [
            /// 🔥 PageView بدون loading
            PageView(
              controller: _controller,
              onPageChanged: (index) => currentIndex.value = index,
              children: onboardingData
                  .map((data) => OnboardingPage(data: data))
                  .toList(),
            ),

            SafeArea(
              child: Column(
                children: [
                  const Spacer(),

                  /// 🔹 Indicator
                  ValueListenableBuilder<int>(
                    valueListenable: currentIndex,
                    builder: (context, value, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          onboardingData.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: value == i ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: value == i ? _kBrown : Colors.white54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                    child: ValueListenableBuilder<int>(
                      valueListenable: currentIndex,
                      builder: (context, value, _) {
                        return Column(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Column(
                                key: ValueKey(value),
                                children: [
                                  Customtext(
                                    text: onboardingData[value].title,
                                    color: Colors.white,
                                    size: 18,
                                    textAlign: TextAlign.center,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  const SizedBox(height: 10),
                                  Customtext(
                                    text: onboardingData[value].description,
                                    color: Colors.white70,
                                    size: 13,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            /// 🔘 Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _nextPage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _kBrown,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    key: ValueKey(value),
                                    value == onboardingData.length - 1
                                        ? "Get Started"
                                        : "Next",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
