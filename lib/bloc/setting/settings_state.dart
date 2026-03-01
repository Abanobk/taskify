import 'package:equatable/equatable.dart';

import '../../data/model/settings/sms_gateway.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}
class HeaderSettingEditSuccessLoading extends SettingsState {}
class WhatsappSettingEditSuccessLoading extends SettingsState {}
class SlackSettingEditSuccessLoading extends SettingsState {}
class MediaStorageSettingEditSuccessLoading extends SettingsState {}
class UpdateEmailSettingSuccess extends SettingsState {}
class UpdateEmailSettingLoadingSuccess extends SettingsState {}

class SettingsSuccess extends SettingsState {
  const SettingsSuccess();



  @override
  List<Object> get props => [];
}

class SettingsError extends SettingsState {
  final String errorMessage;
  const SettingsError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class UpdateEmailSettingError extends SettingsState {
  final String errorMessage;
  const UpdateEmailSettingError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class SettingHeaderEditError extends SettingsState {
  final String errorMessage;
  const SettingHeaderEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class SettingWhatsappEditError extends SettingsState {
  final String errorMessage;
  const SettingWhatsappEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class SettingSlackEditError extends SettingsState {
  final String errorMessage;
  const SettingSlackEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class GeneralSettingsEditError extends SettingsState {
  final String errorMessage;
  const GeneralSettingsEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class SettingMediaStorageEditError extends SettingsState {
  final String errorMessage;
  const SettingMediaStorageEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class SecuritySettingsEditError extends SettingsState {
  final String errorMessage;
  const SecuritySettingsEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ComapnyInformationSettingsEditError extends SettingsState {
  final String errorMessage;
  const ComapnyInformationSettingsEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class SettingsHeaderUpdated extends SettingsState {
  final SmsGatewayModel smsModel;

  SettingsHeaderUpdated({
    required this.smsModel,

  });

  @override
  List<Object> get props => [smsModel];
}
class UpdateSecuritySetting extends SettingsState {
  UpdateSecuritySetting();

  @override
  List<Object> get props => [];
}
class UpdateCompanyInfoSetting extends SettingsState {
  UpdateCompanyInfoSetting();

  @override
  List<Object> get props => [];
}

class UpdateGeneralSetting extends SettingsState {
  final String? title;
  final String? siteUrl;
  final String? fullLogo;
  final String? favicon;
  final String? currencyFullForm;
  final String? currencySymbol;
  final String? currencyCode;
  final String? currencySymbolPosition;
  final String? currencyFormat;
  final String? decimalPoints;
  final String? dateFormat;
  final String? timeFormat;
  final int? birthdaySec;
  final int? workAnniversarySec;
  final int? leaveReqSec;

  UpdateGeneralSetting({
    this.title,
    this.siteUrl,
    this.fullLogo,
    this.favicon,
    this.currencyFullForm,
    this.currencySymbol,
    this.currencyCode,
    this.currencySymbolPosition,
    this.currencyFormat,
    this.decimalPoints,
    this.dateFormat,
    this.timeFormat,
    this.birthdaySec,
    this.workAnniversarySec,
    this.leaveReqSec,
  });

  @override
  List<Object?> get props => [
    title,
    siteUrl,
    fullLogo,
    favicon,
    currencyFullForm,
    currencySymbol,
    currencyCode,
    currencySymbolPosition,
    currencyFormat,
    decimalPoints,
    dateFormat,
    timeFormat,
    birthdaySec,
    workAnniversarySec,
    leaveReqSec,
  ];
}

class SettingsWhatsAppUpdated extends SettingsState {

  SettingsWhatsAppUpdated();

  @override
  List<Object> get props => [];
}
class SettingsSlackUpdated extends SettingsState {

  SettingsSlackUpdated();

  @override
  List<Object> get props => [];
}
class SettingsMediaStorageUpdated extends SettingsState {

  SettingsMediaStorageUpdated();

  @override
  List<Object> get props => [];
}
