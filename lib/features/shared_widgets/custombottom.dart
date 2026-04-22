import 'package:flutter/material.dart';
import 'package:mira_fashon/features/shared_widgets/customtext.dart';

class Custombottom extends StatelessWidget {
  final String text;
  final VoidCallback? ontap;
  const Custombottom({super.key, required this.text, this.ontap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Customtext(text: text, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
