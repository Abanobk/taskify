import 'package:equatable/equatable.dart';


abstract class ActivityLogEvent extends Equatable {
  @override
  List<Object?> get props => [];
}


class PrivacyPolicy extends ActivityLogEvent {
  final String? privacyPolicyText;

  PrivacyPolicy({this.privacyPolicyText});

  @override
  List<Object> get props => [];
}
class GetPrivacyPolicy extends ActivityLogEvent {
  final String? privacyPolicyText;

  GetPrivacyPolicy({this.privacyPolicyText});

  @override
  List<Object> get props => [];
}
class GetTermsAndCondition extends ActivityLogEvent {


  GetTermsAndCondition();

  @override
  List<Object> get props => [];
}
class GetAboutUs extends ActivityLogEvent {
  final String? getText;

  GetAboutUs({this.getText});

  @override
  List<Object> get props => [];
}
class TermsAndCondition extends ActivityLogEvent {
  final String? termsAndConditionText;

  TermsAndCondition({this.termsAndConditionText});

  @override
  List<Object> get props => [];
}
class AbouUs extends ActivityLogEvent {
  final String? abouUsText;

  AbouUs({this.abouUsText});

  @override
  List<Object> get props => [];
}