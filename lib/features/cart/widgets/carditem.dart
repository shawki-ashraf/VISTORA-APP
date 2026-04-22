import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Carditem extends StatefulWidget {
  final String name;
  final String image;
  final double price;
  final int quantity;
  final String size;
  final void Function()? onDelete; // Callback for delete action

  const Carditem({
    super.key,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.size,
    this.onDelete,
  });

  @override
  State<Carditem> createState() => _CarditemState();
}

class _CarditemState extends State<Carditem> {
  late int qty;

  @override
  void initState() {
    super.initState();
    qty = widget.quantity;
  }

  void increaseQty() {
    setState(() {
      qty++;
    });
  }

  void decreaseQty() {
    if (qty > 1) {
      setState(() {
        qty--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.grey[200],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🖼 IMAGE
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
                child: Image.network(
                  widget.image,
                  height: 330.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  filterQuality: FilterQuality.high,
                ),
              ),

              /// 🗑 DELETE BUTTON
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  height: 30.r,
                  width: 30.r,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: widget.onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),

          /// 📦 DATA
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              children: [
                /// NAME + PRICE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Text(
                      "${widget.price} EGP",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                /// SIZE + QUANTITY
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// SIZE
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        "Size: ${widget.size}",
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),

                    /// 🔥 QUANTITY CONTROLLER
                    Row(
                      children: [
                        /// MINUS
                        GestureDetector(
                          onTap: decreaseQty,
                          child: Icon(Icons.remove_circle_outline, size: 22.sp),
                        ),

                        SizedBox(width: 8.w),

                        /// QTY NUMBER
                        Text(
                          "$qty",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(width: 8.w),

                        /// PLUS
                        GestureDetector(
                          onTap: increaseQty,
                          child: Icon(Icons.add_circle_outline, size: 22.sp),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
