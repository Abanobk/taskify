import 'package:equatable/equatable.dart';


abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object?> get props => [];
}

class ChangeLanguage extends LanguageEvent {
  final String languageCode;

  const ChangeLanguage({required this.languageCode});

  @override
  List<Object?> get props => [languageCode];
}