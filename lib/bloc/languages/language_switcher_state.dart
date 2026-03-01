import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../../config/constants.dart';

class LanguageState extends Equatable {
  final Locale locale;
  final bool isRtl;
  const LanguageState({required this.locale,required this.isRtl});

  factory LanguageState.initial() =>  LanguageState(locale: Locale(defaultLanguage),isRtl:false);

  LanguageState copyWith({Locale? locale, bool? isRtl}) {
    return LanguageState(
      locale: locale ?? this.locale,
      isRtl: isRtl ?? this.isRtl,
    );
  }

  @override
  List<Object?> get props => [locale];
}
