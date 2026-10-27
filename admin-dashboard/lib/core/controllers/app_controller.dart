import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

/// Global controller managing application-wide Theme (Dark/Light) and Language (EN/AR).
/// Acts as the primary state-driven controller for Provider and reactive builders.
class AppController extends ChangeNotifier {
  static final AppController instance = AppController._internal();

  AppController._internal();

  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  String _language = 'en'; // 'en' or 'ar'
  String get language => _language;
  Locale get locale => Locale(_language);

  bool get isArabic => _language == 'ar';
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void toggleLanguage() {
    _language = _language == 'en' ? 'ar' : 'en';
    notifyListeners();
  }

  void setDarkMode(bool dark) {
    if (_isDarkMode != dark) {
      _isDarkMode = dark;
      notifyListeners();
    }
  }

  void setLanguage(String lang) {
    if (_language != lang) {
      _language = lang;
      notifyListeners();
    }
  }

  /// Translate key according to currently selected language
  String tr(String key) {
    final localizations = AppLocalizations(locale);
    return localizations.tr(key);
  }
}

/// Global helper method for quick translations
String tr(String key) => AppController.instance.tr(key);
