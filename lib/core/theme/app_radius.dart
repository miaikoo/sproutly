import 'package:flutter/widgets.dart';

class AppRadius {
  AppRadius._();

  static const xs = Radius.circular(4);
  static const sm = Radius.circular(8);
  static const md = Radius.circular(12);
  static const lg = Radius.circular(16);
  static const xl = Radius.circular(24);

  static const card = BorderRadius.all(lg);
  static const button = BorderRadius.all(md);
  static const dialog = BorderRadius.all(xl);
}