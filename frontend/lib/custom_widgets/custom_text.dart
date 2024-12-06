import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final TextStyle? style;
  final String text;

  const CustomText(this.text, {this.style, super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: text,
      child: Text(
        text,
        style: style,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
