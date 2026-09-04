import 'package:flutter/material.dart';

/// Tokens de radios de curvatura del Design System de Yago.
class AppRadius {
  AppRadius._();

  /// sm = 8.0: Tags, chips, badges compactos
  static const double smValue = 8.0;
  static const Radius sm = Radius.circular(smValue);
  static const BorderRadius smBorder = BorderRadius.all(sm);

  /// md = 12.0: Cards, botones, inputs
  static const double mdValue = 12.0;
  static const Radius md = Radius.circular(mdValue);
  static const BorderRadius mdBorder = BorderRadius.all(md);

  /// lg = 16.0: Tarjetas principales, modales, sheets
  static const double lgValue = 16.0;
  static const Radius lg = Radius.circular(lgValue);
  static const BorderRadius lgBorder = BorderRadius.all(lg);

  /// xl = 20.0: Hero cards, contenedores destacados
  static const double xlValue = 20.0;
  static const Radius xl = Radius.circular(xlValue);
  static const BorderRadius xlBorder = BorderRadius.all(xl);

  /// full = 9999.0: Avatares, pills, tags circulares
  static const double fullValue = 9999.0;
  static const Radius full = Radius.circular(fullValue);
  static const BorderRadius fullBorder = BorderRadius.all(full);
}
