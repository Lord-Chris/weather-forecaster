import 'package:flutter/material.dart';

import '_constants.dart';

class AppTheme {
  static final theme = ThemeData(
    primarySwatch: Colors.indigo,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary600),
    fontFamily: AppTextStyles.ibmPlexSans,
    scaffoldBackgroundColor: AppColors.gray50,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 1,
      iconTheme: const IconThemeData(size: 17),
      surfaceTintColor: AppColors.white,
      shadowColor: AppColors.gray400,
      centerTitle: true,
      titleTextStyle: AppTextStyles.semiBold16.copyWith(
        color: AppColors.gray900,
      ),
    ),
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (context) =>
          const Icon(Icons.arrow_back_ios, color: AppColors.black),
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      height: 90,
      color: AppColors.white,
      surfaceTintColor: AppColors.white,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      elevation: 3,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.gray50,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    cardTheme: const CardTheme(
      color: AppColors.white,
      surfaceTintColor: AppColors.transparent,
    ),
    checkboxTheme: CheckboxThemeData(
      side: const BorderSide(color: AppColors.gray300),
      shape: const CircleBorder(),
      fillColor: MaterialStateProperty.resolveWith(
        (states) {
          return states.isEmpty ? AppColors.transparent : null;
        },
      ),
    ),
    datePickerTheme: const DatePickerThemeData(
      surfaceTintColor: AppColors.transparent,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.gray200),
    expansionTileTheme: const ExpansionTileThemeData(
      tilePadding: EdgeInsets.symmetric(vertical: 4),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: CircleBorder(),
      backgroundColor: AppColors.primary700,
      foregroundColor: AppColors.white,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gray300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gray300, width: 1),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gray300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gray300, width: 1),
      ),
      filled: true,
      fillColor: AppColors.white,
      hintStyle: AppTextStyles.regular16.copyWith(color: AppColors.gray400),
    ),
  );
}
