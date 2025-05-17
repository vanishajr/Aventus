import 'package:flutter/material.dart';
import '../services/translation_service.dart';
import '../translations/app_strings.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en';
  bool _isTranslating = false;

  String get currentLanguage => _currentLanguage;
  bool get isTranslating => _isTranslating;
  String get currentLanguageName => TranslationService.supportedLanguages[_currentLanguage] ?? 'English';

  String translate(String key) {
    return AppStrings.translations[_currentLanguage]?[key] ?? 
           AppStrings.translations['en']?[key] ?? 
           key;
  }

  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;

    try {
      _isTranslating = true;
      notifyListeners();

      _currentLanguage = languageCode;
      
      notifyListeners();
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  Future<String> translateText(String text, String targetLanguage) async {
    if (_currentLanguage == targetLanguage || text.isEmpty) {
      return text;
    }

    try {
      _isTranslating = true;
      notifyListeners();

      final translatedText = await TranslationService.translateText(text, targetLanguage);
      _currentLanguage = targetLanguage;
      
      return translatedText;
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }
} 