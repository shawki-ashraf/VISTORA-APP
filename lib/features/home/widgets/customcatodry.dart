import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 8.w, bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        height: 35.h, // أطول شوي عشان يكون واضح
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8C5E5E) : Colors.grey[200],
          borderRadius: BorderRadius.circular(10.r), // أكبر شوية
          border: Border.all(
            color: isSelected ? const Color(0xFF8C5E5E) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // النص أولاً
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            // الأيقونة بعد النص
            SvgPicture.asset(
              iconPath,
              width: 35.w,
              height: 20.h,
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(
                isSelected ? Colors.white : Colors.black54,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
