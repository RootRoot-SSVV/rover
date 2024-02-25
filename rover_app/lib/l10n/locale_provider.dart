import 'package:flutter/material.dart';
import 'package:rover_app/l10n/l10n.dart';

/// Provider za lokalizaciju
class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) return;
    _locale = locale;
    notifyListeners();
  }

  String getLanguageName(Locale loc) {
    if (loc == const Locale('en')) return 'English';
    if (loc == const Locale('hr')) return 'Hrvatski';
    return 'err';
  }
}
