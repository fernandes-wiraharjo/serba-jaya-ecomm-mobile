import 'package:flutter/material.dart';

abstract final class AppMotion {
  static const page = Duration(milliseconds: 350);
  static const pageReverse = Duration(milliseconds: 300);
  static const tabs = Duration(milliseconds: 180);
  static const dialog = Duration(milliseconds: 220);
  static const dialogReverse = Duration(milliseconds: 180);
  static const sheet = Duration(milliseconds: 300);
  static const press = Duration(milliseconds: 110);

  static const enter = Curves.easeOutCubic;
  static const fade = Curves.easeOut;
  static const pressedScale = 0.97;
  static const dialogStartScale = 0.96;
  static const barrierColor = Color(0x66000000);

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  static Duration duration(BuildContext context, Duration value) =>
      reduced(context) ? Duration.zero : value;
}
