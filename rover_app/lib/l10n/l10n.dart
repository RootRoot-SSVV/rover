import 'package:flutter/material.dart';

/// Podaci za lokalizaciju

class L10n {
  static const List<Locale> all = [Locale('en'), Locale('hr')];
}

String getLanguageName(Locale loc) {
  if (loc == const Locale('en')) return 'English';
  if (loc == const Locale('hr')) return 'Hrvatski';
  return 'err';
}
