import 'package:flutter/widgets.dart';

class AppRadius {
  AppRadius._();

  static const xs = Radius.circular(4);
  static const sm = Radius.circular(8);
  static const md = Radius.circular(12);
  static const lg = Radius.circular(16);
  static const xl = Radius.circular(24);
  static const xxl = Radius.circular(32);

  /// Fully rounded. Chips and pills used a literal 36 in five places; this is
  /// large enough to round any control height we ship.
  static const pill = Radius.circular(999);

  static const card = BorderRadius.all(lg);
  static const button = BorderRadius.all(md);
  static const dialog = BorderRadius.all(xl);

  /// Activity and board artwork — softer than a card, it reads as a tile.
  static const tile = BorderRadius.all(xl);
}