import 'package:flutter/material.dart';

class Customtext extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final TextDecoration? decoration;

  const Customtext({
    super.key,
    required this.text,
    required this.color,
    required this.size,
    this.fontWeight,
    this.textAlign,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(fontSize: size, fontWeight: fontWeight, color: color),
    );
  }
}
