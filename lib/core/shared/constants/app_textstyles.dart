import 'package:flutter/widgets.dart';

class AppTextStyles {
  static const ibmPlexSans = 'IBM_Plex_Sans';

  static TextStyle dynamic(
    double size, {
    Color? color,
    FontWeight? weight,
    double? height,
    double? spacing,
    FontStyle? style,
    String? fontFamily,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? ibmPlexSans,
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: height == null ? null : height / size,
      letterSpacing: spacing,
      fontStyle: style,
    );
  }

  static const regular12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.2,
  );

  static const regular14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static const regular16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const regular18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
  );

  static const medium12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const medium14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const medium16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const medium18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.56,
  );

  static const medium48 = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  static const semiBold14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const semiBold16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const semiBold18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.56,
  );

  static const semiBold20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const bold16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    height: 1.5,
  );
}
