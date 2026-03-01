import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDateFromApi(String date, BuildContext context) {
  final DateTime parsedDate = DateTime.parse(date);
  final DateFormat formatter = DateFormat('MMM dd, yyyy');
  return formatter.format(parsedDate);
}

DateTime parseDateStringFromApi(String date) {
  return DateTime.parse(date);
}

String dateFormatConfirmed(DateTime date, BuildContext context) {
  final DateFormat formatter = DateFormat('MMM dd, yyyy');
  return formatter.format(date);
} 