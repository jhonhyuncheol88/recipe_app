import 'package:flutter/widgets.dart';

/// Wanted DS corner radius scale.
class AppRadius {
  AppRadius._();

  static const double r2 = 2;
  static const double r4 = 4;
  static const double r6 = 6;
  static const double r8 = 8;
  static const double r10 = 10;
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r20 = 20;
  static const double r24 = 24;
  static const double r32 = 32;

  /// Pill shape — large enough to fully round any common UI element.
  static const double pill = 2500;

  static const BorderRadius brR8 = BorderRadius.all(Radius.circular(r8));
  static const BorderRadius brR10 = BorderRadius.all(Radius.circular(r10));
  static const BorderRadius brR12 = BorderRadius.all(Radius.circular(r12));
  static const BorderRadius brR16 = BorderRadius.all(Radius.circular(r16));
  static const BorderRadius brR20 = BorderRadius.all(Radius.circular(r20));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));
}
