import 'package:flutter/material.dart';

/// Tokens de espaciado modular en base 4px del Design System de Yago.
class AppSpacing {
  AppSpacing._();

  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
  static const double s64 = 64.0;

  // Espaciadores verticales
  static const SizedBox gap4 = SizedBox(height: s4, width: s4);
  static const SizedBox gap8 = SizedBox(height: s8, width: s8);
  static const SizedBox gap12 = SizedBox(height: s12, width: s12);
  static const SizedBox gap16 = SizedBox(height: s16, width: s16);
  static const SizedBox gap20 = SizedBox(height: s20, width: s20);
  static const SizedBox gap24 = SizedBox(height: s24, width: s24);
  static const SizedBox gap32 = SizedBox(height: s32, width: s32);
  static const SizedBox gap48 = SizedBox(height: s48, width: s48);
  static const SizedBox gap64 = SizedBox(height: s64, width: s64);
}
