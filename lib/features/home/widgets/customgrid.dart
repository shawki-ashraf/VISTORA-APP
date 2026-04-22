import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mira_fashon/features/shared_widgets/customtext.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GridProductsModern extends StatefulWidget {
  final String name;
  final String image;
  final double rate;
  final String category;
  final double price;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const GridProductsModern({
    super.key,
    required this.name,
    required this.image,
    required this.rate,
    required this.category,
    required this.price,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  State<GridProductsModern> createState() => _GridProductsModernState();
}

class _GridProductsModernState extends State<GridProductsModern>
    with AutomaticKeepAliveClientMixin {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  bool get wantKeepAlive => true;

  void toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    widget.onFavoriteToggle();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE + FAVORITE
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 0.75,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8.r),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.image,
                      fit: BoxFit.cover,

                      // 🔥 أهم حاجة لتقليل الفلاش
                      useOldImageOnUrlChange: true,

                      // 🔥 منع fade اللي بيعمل flicker
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,

                      // 🔥 placeholder خفيف جدًا
                      placeholder: (context, url) =>
                          Container(color: Colors.transparent),

                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),

                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: toggleFavorite,
                    child: AnimatedScale(
                      scale: _isFavorite ? 1.0 : 0.7,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 28.w,
                        height: 28.h,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // CONTENT
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Rate
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Customtext(
                          text: widget.category.toUpperCase(),
                          size: 10.sp,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < widget.rate.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.orange,
                            size: 12.sp,
                          );
                        }),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),

                  // Name
                  Customtext(
                    text: widget.name,
                    size: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),

                  SizedBox(height: 4.h),

                  // Price
                  Customtext(
                    text: "${widget.price} EGY",
                    size: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
