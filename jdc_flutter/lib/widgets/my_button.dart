import 'package:flutter/material.dart';
import 'package:jdc/constants.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    Key? key,
    this.text = '',
    this.textColor,
    this.disabledTextColor,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.fontSize = 14.0,
    this.minHeight = 48.0,
    this.minWidth = double.infinity,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.radius = 5.0,
    this.side = BorderSide.none,
    required this.onPressed,
  }) : super(key: key);

  final String text;
  final double fontSize;
  final VoidCallback? onPressed;
  final Color? textColor;
  final Color? disabledTextColor;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final double? minHeight;
  final double? minWidth;
  final double radius;
  final BorderSide side;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize),
        ),
        onPressed: onPressed,
        style: ButtonStyle(
          // 文字颜色
          foregroundColor: MaterialStateProperty.resolveWith(
            (states) {
              if (states.contains(MaterialState.disabled)) {
                return disabledTextColor ?? secondaryColor;
              }
              return textColor ?? Colors.white;
            },
          ),
          // 背景颜色
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return disabledBackgroundColor ?? Color(0xFFCEDBF2);
            }
            return backgroundColor ?? secondaryColor;
          }),
          // 水波纹
          overlayColor: MaterialStateProperty.resolveWith((states) {
            return (textColor ?? Colors.white.withOpacity(0.12));
          }),
          // 按钮最小大小
          minimumSize: (minWidth == null || minHeight == null) ? null : MaterialStateProperty.all<Size>(Size(minWidth!, minHeight!)),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(padding),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          side: MaterialStateProperty.all<BorderSide>(side),
        ));
  }
}
