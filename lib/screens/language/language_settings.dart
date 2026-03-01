// import 'package:flutter/cupertino.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../data/localStorage/hive.dart';
//
//
// Future<Locale> setLocale(String languageCode) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.setString(languageCode, languageCode);
//   return _locale(languageCode);
// }
//
// Future<Locale> getLocale() async {
//   String languageCodes = await HiveStorage.getLanguage() as String ;
//   return _locale(languageCodes);
// }
//
// Locale _locale(String languageCode) {
//   switch (languageCode) {
//     case 'en':
//       return const Locale('en', 'US');
//   // case 'zh':
//   //   return const Locale('zh', 'CN');
//   // case 'fr':
//   //   return const Locale('fr', 'FR');
//   // case 'hi':
//   //   return const Locale('hi', 'IN');
//     case 'ar':
//       return const Locale('ar', 'DZ');
//   // case 'ru':
//   //   return const Locale('ru', 'RU');
//   // case 'ja':
//   //   return const Locale('ja', 'JP');
//   // case 'de':
//   //   return const Locale('de', 'DE');
//   // case 'es':
//   //   return const Locale('es', 'ES');
//     default:
//       return const Locale('en', 'US');
//   }
// }
