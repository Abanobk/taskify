import 'package:flutter/material.dart';

abstract class AppLocalizations {
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get selectDays;
  String get enterDays;
  String get cancel;
  String get submit;
  String get upcomingWorkAnni;
} 