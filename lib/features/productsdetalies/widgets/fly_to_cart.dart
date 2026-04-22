import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ─────────────────────────────────────────────────────────────
//  CUSTOM SPRING CURVE
//  Approximates cubic-bezier(0.34, 1.56, 0.64, 1) — the same
//  spring easing used in iOS system animations. Overshoots
//  slightly before settling, making the badge/icon feel "alive".
// ─────────────────────────────────────────────────────────────

class _SnapCurve extends Curve {
  const _SnapCurve();

  @override
  double transformInternal(double t) {
    const c1 = Offset(0.34, 1.56);
    const c2 = Offset(0.64, 1.0);
    double s = t;
    for (int i = 0; i < 5; i++) {
      final x =
          3 * s * (1 - s) * (1 - s) * c1.dx +
          3 * s * s * (1 - s) * c2.dx +
          s * s * s;
      final dx =
          3 * (1 - s) * (1 - s) * c1.dx +
          6 * s * (1 - s) * (c2.dx - c1.dx) +
          3 * s * s * (1 - c2.dx);
      if (dx.abs() < 1e-6) break;
      s -= (x - t) / dx;
    }
    return 3 * s * (1 - s) * (1 - s) * c1.dy +
        3 * s * s * (1 - s) * c2.dy +
        s * s * s;
  }
}

/// Exposed so consumers can use it in their own animations if needed.
const snapCurve = _SnapCurve();

// ─────────────────────────────────────────────────────────────
//  FLY-TO-CART ANIMATION CONTROLLER
//
//  Encapsulates the full OverlayEntry lifecycle. Drop this into
//  any screen; it has zero dependencies on ProductDetails.
//
//  Usage:
//    final _flyController = FlyToCartAnimationController();
//
//    // In initState / dispose:
//    @override void dispose() { _flyController.dispose(); super.dispose(); }
//
//    // To trigger:
//    _flyController.launch(
//      context:       context,
//      imageUrl:      'https://...',
//      sourceKey:     _productImageKey,   // GlobalKey on the source widget
//      targetKey:     _cartIconKey,       // GlobalKey on the cart icon
//      onLanded: () { setState(() => _cartCount++); },
//    );
// ─────────────────────────────────────────────────────────────

class FlyToCartAnimationController {
  OverlayEntry? _entry;

  /// Whether an animation is currently in-flight.
  bool get isAnimating => _entry != null;

  /// Launches the fly animation.
  ///
  /// [imageUrl]  — product thumbnail URL.
  /// [sourceKey] — GlobalKey attached to the source widget (e.g. product image).
  /// [targetKey] — GlobalKey attached to the destination widget (e.g. cart icon).
  /// [onLanded]  — called when the bubble reaches the cart icon (update count here).
  /// [startSizeFactor] — bubble diameter as a fraction of screen width (default 0.22).
  void launch({
    required BuildContext context,
    required String imageUrl,
    required GlobalKey sourceKey,
    required GlobalKey targetKey,
    required VoidCallback onLanded,
    double startSizeFactor = 0.22,
  }) {
    if (isAnimating) return;

    final startCenter = _centerOf(sourceKey);
    final endCenter = _centerOf(targetKey);
    if (startCenter == null || endCenter == null) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final startSize = (screenWidth * startSizeFactor).clamp(64.0, 112.0);

    _entry = OverlayEntry(
      builder: (_) => _FlyingBubble(
        imageUrl: imageUrl,
        startCenter: startCenter,
        endCenter: endCenter,
        startSize: startSize,
        onComplete: () {
          _entry?.remove();
          _entry = null;
          onLanded();
        },
      ),
    );

    Overlay.of(context).insert(_entry!);
  }

  /// Must be called from the host widget's dispose().
  void dispose() {
    _entry?.remove();
    _entry = null;
  }

  // ── Private helpers ──────────────────────────────────────────

  static Offset? _centerOf(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final topLeft = box.localToGlobal(Offset.zero);
    return topLeft + Offset(box.size.width / 2, box.size.height / 2);
  }
}

// ─────────────────────────────────────────────────────────────
//  _FlyingBubble  (internal — not exported)
//
//  Stateful widget that runs a single fly animation and calls
//  [onComplete] when finished. Inserted into the Overlay by
//  FlyToCartAnimationController so it renders above everything.
// ─────────────────────────────────────────────────────────────

class _FlyingBubble extends StatefulWidget {
  final String imageUrl;
  final Offset startCenter;
  final Offset endCenter;
  final double startSize;
  final VoidCallback onComplete;

  const _FlyingBubble({
    required this.imageUrl,
    required this.startCenter,
    required this.endCenter,
    required this.startSize,
    required this.onComplete,
  });

  @override
  State<_FlyingBubble> createState() => _FlyingBubbleState();
}

class _FlyingBubbleState extends State<_FlyingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // ── Individual animation tracks ─────────────────────────────

  /// Eased [0→1] value used as the Bézier path parameter.
  late final Animation<double> _pathT;

  /// Bubble diameter: startSize → 24 px (shrinks as it "enters" the cart).
  late final Animation<double> _size;

  /// Holds at 1.0 for 78% of flight, then quick fade so it "disappears into" the icon.
  late final Animation<double> _opacity;

  /// Dips to 0.76× at launch (pick-up feel) then springs back with _SnapCurve.
  late final Animation<double> _launchScale;

  /// Slight Z-tilt for organic, non-robotic motion.
  late final Animation<double> _rotation;

  /// Directional motion-blur: peaks mid-flight, horizontal bias for speed sensation.
  late final Animation<double> _blurSigma;

  // ── Bézier control points ────────────────────────────────────
  late final Offset _cp1;
  late final Offset _cp2;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );

    // CP1: lift above the start point.
    // CP2: sweep into the cart from above.
    final dx = widget.endCenter.dx - widget.startCenter.dx;
    final dy = widget.endCenter.dy - widget.startCenter.dy;
    final arcHeight = (dy.abs() * 0.55 + 80).clamp(80.0, 220.0);

    _cp1 = Offset(
      widget.startCenter.dx + dx * 0.08,
      widget.startCenter.dy - arcHeight,
    );
    _cp2 = Offset(
      widget.endCenter.dx - dx * 0.08,
      widget.endCenter.dy - arcHeight * 0.35,
    );

    // Path easing — smooth acceleration + deceleration.
    _pathT = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);

    // Size shrinks on an accelerating curve so it feels pulled in.
    _size = Tween<double>(
      begin: widget.startSize,
      end: 24,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInCubic));

    // Opacity: opaque → fades in final 22% of travel.
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 78),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 22,
      ),
    ]).animate(_ctrl);

    // Launch dip: 1.0 → 0.76 (fast) → 1.0 (spring).
    _launchScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.76,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.76, end: 1.0).chain(CurveTween(curve: snapCurve)),
        weight: 86,
      ),
    ]).animate(_ctrl);

    // Rotation: tilt left during ascent, partially correct on descent.
    _rotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -0.22,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -0.22,
          end: 0.08,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
    ]).animate(_ctrl);

    // Blur: 0 → peak (5) → 0. Horizontal bias applied in build().
    _blurSigma = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 5.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 5.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 65,
      ),
    ]).animate(_ctrl);

    _ctrl.forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Cubic Bézier interpolation ───────────────────────────────

  Offset _bezier(double t) {
    final mt = 1 - t;
    return Offset(
      mt * mt * mt * widget.startCenter.dx +
          3 * mt * mt * t * _cp1.dx +
          3 * mt * t * t * _cp2.dx +
          t * t * t * widget.endCenter.dx,
      mt * mt * mt * widget.startCenter.dy +
          3 * mt * mt * t * _cp1.dy +
          3 * mt * t * t * _cp2.dy +
          t * t * t * widget.endCenter.dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final pos = _bezier(_pathT.value);
        final sz = _size.value;
        final sigmaX = _blurSigma.value;
        final sigmaY = sigmaX * 0.3; // horizontal bias → feels fast

        return Positioned(
          left: pos.dx - sz / 2,
          top: pos.dy - sz / 2,
          width: sz,
          height: sz,
          child: Opacity(
            opacity: _opacity.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _launchScale.value,
              child: Transform.rotate(
                angle: _rotation.value,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: sigmaX,
                    sigmaY: sigmaY,
                    tileMode: TileMode.decal,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.30 * _opacity.value,
                          ),
                          blurRadius: 14,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CART ICON WITH ANIMATED BADGE  (reusable widget)
//
//  Drop this wherever you need a cart icon that bounces and
//  shows a live-updating badge without any glue code.
//
//  Usage:
//    CartIconWidget(
//      cartKey:   _cartIconKey,
//      cartCount: _cartCount,
//    )
// ─────────────────────────────────────────────────────────────

class CartIconWidget extends StatefulWidget {
  final GlobalKey cartKey;
  final int cartCount;
  final Color iconColor;
  final double iconSize;

  const CartIconWidget({
    super.key,
    required this.cartKey,
    required this.cartCount,
    this.iconColor = Colors.white,
    this.iconSize = 28,
  });

  @override
  State<CartIconWidget> createState() => _CartIconWidgetState();
}

class _CartIconWidgetState extends State<CartIconWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    // Damped two-overshoot bounce: expand → compress → small expand → settle.
    _bounce = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.42,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.42,
          end: 0.86,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.86,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 28,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.08,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 17,
      ),
    ]).animate(_ctrl);
  }

  @override
  void didUpdateWidget(CartIconWidget old) {
    super.didUpdateWidget(old);
    if (widget.cartCount != old.cartCount) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _bounce,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            key: widget.cartKey,
            Icons.shopping_bag_outlined,
            color: widget.iconColor,
            size: widget.iconSize,
          ),
          if (widget.cartCount > 0)
            Positioned(
              right: -8,
              top: -8,
              child: _AnimatedBadge(count: widget.cartCount),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  _AnimatedBadge  (internal)
//
//  Pops in on first appearance; slides the number up/out and
//  the new number in from below on every increment.
// ─────────────────────────────────────────────────────────────

class _AnimatedBadge extends StatefulWidget {
  final int count;

  const _AnimatedBadge({required this.count});

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  int _displayed = 0;

  @override
  void initState() {
    super.initState();
    _displayed = widget.count;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.28,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.28, end: 1.0).chain(CurveTween(curve: snapCurve)),
        weight: 45,
      ),
    ]).animate(_ctrl);

    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_AnimatedBadge old) {
    super.didUpdateWidget(old);
    if (widget.count != old.count) {
      setState(() => _displayed = widget.count);
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF4D6D), Color(0xFFD90429)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD90429).withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) => SlideTransition(
            position: Tween(begin: const Offset(0, -0.9), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                ),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Text(
            '$_displayed',
            key: ValueKey(_displayed),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              height: 1.7,
            ),
          ),
        ),
      ),
    );
  }
}
