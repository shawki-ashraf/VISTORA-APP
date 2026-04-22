import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchView extends StatelessWidget {
  final ValueChanged<String>? onchanged;

  const SearchView({super.key, required this.onchanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r), // 👈 soft rounded
          /// 🌫️ background مريح للعين (مش أبيض صافي)
          color: const Color(0xFFF7F7F7),

          /// ✨ border soft جدًا (مش black خالص)
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),

          /// 💡 shadow خفيف جدًا (modern depth)
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: TextField(
          onChanged: onchanged,

          decoration: InputDecoration(
            hintText: "Search clothes, shoes...",

            /// 🎨 hint softer gray
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),

            /// 🔍 icon soft gray
            prefixIcon: Icon(
              CupertinoIcons.search,
              color: Colors.grey.shade600,
              size: 22.sp,
            ),

            /// 🎛 filter icon
            suffixIcon: Icon(
              Icons.tune,
              color: Colors.grey.shade600,
              size: 20.sp,
            ),

            border: InputBorder.none,

            contentPadding: EdgeInsets.symmetric(vertical: 15.h),
          ),

          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
        ),
      ),
    );
  }
}
