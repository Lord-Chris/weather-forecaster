import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Neutral Colors
  static const white = Color(0XFFFFFFFF);
  static const black = Color(0XFF000000);
  static const transparent = Colors.transparent;

  /// ----------------------Named Colors From UI------------------
  static const primary600 = Color(0XFF004CCC);
  static const primary700 = Color(0XFF003999);
  static const biddaPry800 = Color(0XFF001638);
  static const gray50 = Color(0XFFF9FAFB);
  static const gray200 = Color(0XFFEAECF0);
  static const gray300 = Color(0XFFD0D5DD);
  static const gray400 = Color(0XFF98A2B3);
  static const gray500 = Color(0XFF667085);
  static const gray600 = Color(0XFF475467);
  static const gray700 = Color(0XFF344054);
  static const gray900 = Color(0XFF101828);

  /// Dark theme
  static const darkBackground = Color(0XFF0B1220);
  static const darkSurface = Color(0XFF151E30);
  static const darkOutline = Color(0XFF2A3550);

  /// Air quality index levels, 1 (good) to 5 (very poor).
  static const aqiColors = [
    Color(0XFF12B76A),
    Color(0XFF84CC16),
    Color(0XFFF79009),
    Color(0XFFF04438),
    Color(0XFF9E2A9E),
  ];
}
