import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSearchBar extends StatelessWidget {
  final VoidCallback? onFilterTap;
  final VoidCallback? onTap;

  const CustomSearchBar({super.key, this.onFilterTap, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20.r),
      elevation: 5, // shadow
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Container(
          height: 55.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey, size: 24.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Find your favorite products',
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              ),
              GestureDetector(
                onTap: onFilterTap,
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6D4C4C),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.tune, color: Colors.white, size: 20.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
