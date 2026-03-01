import 'package:equatable/equatable.dart';


abstract class PrivacyAboutusTermsCondState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PriInitial extends PrivacyAboutusTermsCondState {}


class PriLoading extends PrivacyAboutusTermsCondState {}


class PriError extends PrivacyAboutusTermsCondState {
  final String errorMessage;

  PriError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class PrivacyUpdatedSuccess extends PrivacyAboutusTermsCondState {
final String privacyPolicy;

PrivacyUpdatedSuccess(this.privacyPolicy);

  @override
  List<Object> get props => [privacyPolicy];
}
class PrivacyPolicyValue extends PrivacyAboutusTermsCondState {
final String privacyPolicy;

PrivacyPolicyValue(this.privacyPolicy);

  @override
  List<Object> get props => [privacyPolicy];
}
class TermsAndConditionValue extends PrivacyAboutusTermsCondState {
final String terms;

TermsAndConditionValue(this.terms);

  @override
  List<Object> get props => [terms];
}
class AboutUsValue extends PrivacyAboutusTermsCondState {
final String aboutUs;

AboutUsValue(this.aboutUs);

  @override
  List<Object> get props => [aboutUs];
}
class PrivacyUpdatedError extends PrivacyAboutusTermsCondState {
  final String errorMessage;

  PrivacyUpdatedError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}class TermsAndConditionError extends PrivacyAboutusTermsCondState {
  final String errorMessage;

  TermsAndConditionError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}class AboutUsError extends PrivacyAboutusTermsCondState {
  final String errorMessage;

  AboutUsError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class AboutUsUpdatedSuccess extends PrivacyAboutusTermsCondState {
  final String aboutUs;

  AboutUsUpdatedSuccess(this.aboutUs);

  @override
  List<Object> get props => [aboutUs];
}
class AboutUsUpdatedDeleteError extends PrivacyAboutusTermsCondState {
  final String errorMessage;

  AboutUsUpdatedDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class TermsAndConditionsUpdatedSuccess extends PrivacyAboutusTermsCondState {
  final String termsAndConditions;

  TermsAndConditionsUpdatedSuccess(this.termsAndConditions);

  @override
  List<Object> get props => [termsAndConditions];
}
class TermsAndConditionsUpdatedDeleteError extends PrivacyAboutusTermsCondState {
  final String errorMessage;

  TermsAndConditionsUpdatedDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class CommonError extends PrivacyAboutusTermsCondState {
  final String errorMessage;

  CommonError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}