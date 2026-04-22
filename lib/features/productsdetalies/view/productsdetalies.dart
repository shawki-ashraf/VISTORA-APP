import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:mira_fashon/features/cart/cubit/cart_cubit.dart';
import 'package:mira_fashon/features/cart/data/cartmodel.dart';
import 'package:mira_fashon/features/productsdetalies/widgets/fly_to_cart.dart';
import 'package:mira_fashon/features/shared_widgets/custombottom.dart';

// Import the animation layer — the only coupling point.

// ─────────────────────────────────────────────────────────────
//  LOADING BUTTON  (wave-pulsing dots)
//  Shown in place of the CTA while CartLoading is active.
// ─────────────────────────────────────────────────────────────

class _LoadingButton extends StatefulWidget {
  const _LoadingButton();

  @override
  State<_LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<_LoadingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final phase = (_ctrl.value - i * 0.28).remainder(1.0);
              final t = phase < 0 ? phase + 1.0 : phase;
              final opacity = (t < 0.5 ? t * 2 : (1.0 - t) * 2).clamp(
                0.25,
                1.0,
              );
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.5),
                child: Opacity(
                  opacity: opacity,
                  child: const CircleAvatar(
                    radius: 4,
                    backgroundColor: Colors.white,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PRODUCT DETAILS SCREEN  (UI layer)
//
//  Responsibilities:
//    • Layout (image, overlay, bottom sheet)
//    • Local UI state (quantity, size selection)
//    • Delegating the add-to-cart call to CartCubit
//    • Delegating the success animation to FlyToCartAnimationController
//
//  No animation implementation lives here.
// ─────────────────────────────────────────────────────────────

class ProductsDetails extends StatefulWidget {
  final List<String> image;
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final double rating;
  final List<String> sizes;
  final double? discount;

  const ProductsDetails({
    super.key,
    required this.image,
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.rating,
    required this.sizes,
    this.discount,
  });

  @override
  State<ProductsDetails> createState() => _ProductsDetailsState();
}

class _ProductsDetailsState extends State<ProductsDetails> {
  // ── UI state ─────────────────────────────────────────────────
  int _quantity = 1;
  String _selectedSize = 'M';
  int _cartCount = 0;

  // ── Keys used by the animation layer to measure positions ────
  final GlobalKey _cartIconKey = GlobalKey();
  final GlobalKey _productImgKey = GlobalKey();

  // ── Animation controller (owns OverlayEntry lifecycle) ───────
  final FlyToCartAnimationController _flyController =
      FlyToCartAnimationController();

  // ── Lifecycle ─────────────────────────────────────────────────

  @override
  void dispose() {
    _flyController.dispose(); // ensures any in-flight overlay is removed
    super.dispose();
  }

  // ── Event handlers ────────────────────────────────────────────

  void _onCartSuccess() {
    _flyController.launch(
      context: context,
      imageUrl: widget.image.isNotEmpty ? widget.image[0] : '',
      sourceKey: _productImgKey,
      targetKey: _cartIconKey,
      onLanded: () => setState(() => _cartCount++),
    );
  }

  void _onAddToCartTap(BuildContext blocContext) {
    if (_flyController.isAnimating) return; // guard during in-flight animation
    blocContext.read<CartCubit>().addToCart(
      CartItemModel(
        id: widget.id,
        name: widget.name,
        image: widget.image,
        price: widget.price,
        quantity: _quantity,
        size: _selectedSize,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartCubit(),
      child: Scaffold(
        body: Stack(
          children: [
            _buildProductImage(),
            _buildDarkOverlay(),
            _buildBackButton(),
            _buildCartIcon(),
            _buildBottomSheet(),
          ],
        ),
      ),
    );
  }

  // ── Sub-builders (keeps build() scannable) ────────────────────

  /// Full-bleed product photo. The GlobalKey lets the animation
  /// layer measure this widget's global position at runtime.
  Widget _buildProductImage() {
    return Positioned.fill(
      key: _productImgKey,
      child: CachedNetworkImage(
        imageUrl: widget.image.isNotEmpty
            ? widget.image[0]
            : 'https://via.placeholder.com/400',
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (_, __) => const SizedBox(),
        errorWidget: (_, __, ___) =>
            const Icon(Icons.error, color: Colors.white),
      ),
    );
  }

  Widget _buildDarkOverlay() =>
      Positioned.fill(child: Container(color: Colors.black.withOpacity(0.22)));

  Widget _buildBackButton() => Positioned(
    top: 50.h,
    left: 20.w,
    child: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.32),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
      ),
    ),
  );

  /// Cart icon widget — completely self-contained (bounce + badge live here).
  Widget _buildCartIcon() => Positioned(
    top: 46.h,
    right: 20.w,
    child: CartIconWidget(cartKey: _cartIconKey, cartCount: _cartCount),
  );

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.62,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.white.withOpacity(0.26),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDragHandle(),
                    _buildNameAndRating(),
                    SizedBox(height: 6.h),
                    _buildCategory(),
                    SizedBox(height: 12.h),
                    _buildPrice(),
                    SizedBox(height: 20.h),
                    _buildSizeSelector(),
                    SizedBox(height: 18.h),
                    _buildQuantityRow(),
                    SizedBox(height: 20.h),
                    _buildDescription(),
                    SizedBox(height: 26.h),
                    _buildAddToCartButton(),
                    SizedBox(height: 14.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() => Center(
    child: Container(
      width: 38,
      height: 4,
      margin: EdgeInsets.only(bottom: 18.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  Widget _buildNameAndRating() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          widget.name,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.3,
          ),
        ),
      ),
      SizedBox(width: 10.w),
      Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
          SizedBox(width: 3.w),
          Text(
            '${widget.rating}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildCategory() => Text(
    widget.category,
    style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13.sp),
  );

  Widget _buildPrice() => Text(
    '${widget.price.toStringAsFixed(0)} EGP',
    style: TextStyle(
      fontSize: 19.sp,
      fontWeight: FontWeight.w800,
      color: Colors.white,
    ),
  );

  Widget _buildSizeSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Size',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(height: 8.h),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.sizes.map((size) {
            final selected = _selectedSize == size;
            return GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white
                      : Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.38)),
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    color: selected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );

  Widget _buildQuantityRow() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Quantity',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      Row(
        children: [
          _qtyButton(Icons.remove),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Text(
              '$_quantity',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          _qtyButton(Icons.add),
        ],
      ),
    ],
  );

  Widget _buildDescription() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Description',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(height: 6.h),
      Text(
        widget.description,
        style: TextStyle(
          color: Colors.white.withOpacity(0.75),
          fontSize: 13.sp,
          height: 1.55,
        ),
      ),
    ],
  );

  /// The only place CartCubit is consumed.
  /// - CartLoading → show loading dots
  /// - CartSuccess → delegate to _flyController (no animation code here)
  /// - CartFailure → show snackbar
  Widget _buildAddToCartButton() {
    return BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartLoaded) {
          _onCartSuccess();
        } else if (state is CartFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }
      },
      builder: (context, state) {
        if (state is CartLoading) return const _LoadingButton();

        return GestureDetector(
          onTap: () => _onAddToCartTap(context),
          child: Custombottom(text: 'Add To Cart'),
        );
      },
    );
  }

  Widget _qtyButton(IconData icon) {
    return GestureDetector(
      onTap: () => setState(() {
        if (icon == Icons.add) {
          _quantity++;
        } else if (_quantity > 1) {
          _quantity--;
        }
      }),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.35)),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}
