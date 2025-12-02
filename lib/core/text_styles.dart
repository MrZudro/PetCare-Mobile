import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';

class TextStyles {
  static const TextStyle bodyTextBlack = TextStyle(
    fontSize: 18,
    color: AppColors.primaryText,
    fontFamily: 'Poppins',
  );

  static const TextStyle bodyTextWhite = TextStyle(
    fontSize: 18,
    color: AppColors.secondaryText,
    fontFamily: 'Poppins',
  );

  static const TextStyle titleText = TextStyle(
    fontSize: 24,
    color: Colors.white,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
  );
}
