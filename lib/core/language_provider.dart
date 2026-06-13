import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  bool _isEnglish = true;

  bool get isEnglish => _isEnglish;

  // Text Map for easy switching
  Map<String, String> get text => _isEnglish ? _en : _ar;

  void toggleLanguage() {
    _isEnglish = !_isEnglish;
    notifyListeners();
  }

  static const Map<String, String> _en = {
    'welcome': 'Welcome to Astrolabe',
    'loyalty': 'Knowledge Points',
    'reward_msg': '3 more cups to a free brew',
    'library': 'Branch Library',
    'search_books': 'Search for a book...',
    'featured': 'Today\'s Special',
  };

  static const Map<String, String> _ar = {
    'welcome': 'أهلاً بك في أسطرلاب',
    'loyalty': 'نقاط المعرفة',
    'reward_msg': '٣ أكواب متبقية لتحصل على قهوة مجانية',
    'library': 'مكتبة الفرع',
    'search_books': 'ابحث عن كتاب...',
    'featured': 'مميز اليوم',
  };
}