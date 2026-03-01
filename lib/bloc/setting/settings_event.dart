import "dart:io";

import "package:equatable/equatable.dart";
import "package:taskify/data/model/settings/sms_gateway.dart";

abstract class SettingsEvent extends Equatable{
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}


class SettingsList extends SettingsEvent {
final String? endPoints;
  const SettingsList(this.endPoints);

  @override
  List<Object?> get props => [endPoints];
}
class UpdateSettingsSmsHeader extends SettingsEvent {
final SmsGatewayModel smsModel;
  const UpdateSettingsSmsHeader(this.smsModel);

  @override
  List<Object?> get props => [smsModel];
}

class UpdateSettingsWhatsApp extends SettingsEvent {
  final String accessToken;
  final String phoneNumId;

  const UpdateSettingsWhatsApp({required this.phoneNumId,required this.accessToken});

  @override
  List<Object?> get props => [accessToken,phoneNumId];
}

class UpdateSettingsSlack extends SettingsEvent {
  final String slackBotToken;


  const UpdateSettingsSlack({required this.slackBotToken});

  @override
  List<Object?> get props => [slackBotToken];
}
class UpdateSettingsMediaStorage extends SettingsEvent {
  final String storage;
  final String? s3AccessKey;
  final String? s3SecretKey;
  final String? s3RegionKey;
  final String? s3BucketKey;


  const UpdateSettingsMediaStorage({required this.storage,this.s3SecretKey, this.s3AccessKey,this.s3BucketKey,this.s3RegionKey});

  @override
  List<Object?> get props => [storage];
}
class UpdateSettingsSecurity extends SettingsEvent {
  final String maxAttempt;
  final String lockTime;
  final String allowMaxUploadSize;
  final String maxFilesAllowed;
  final String allowedFileType;
  final String isAllowedSignUP;


  const UpdateSettingsSecurity({required this.maxAttempt,required this.lockTime,required this.allowMaxUploadSize,
    required this.maxFilesAllowed,required this.allowedFileType,required this.isAllowedSignUP});

  @override
  List<Object?> get props => [maxFilesAllowed,maxAttempt,allowedFileType,allowMaxUploadSize,isAllowedSignUP,lockTime];
}
class UpdateSettingsCompanyInfo extends SettingsEvent {
  final String companyEmail;
  final String companyPhone;
  final String companyAddress;
  final String companyCity;
  final String companyState;
  final String companyCountry;
  final String companyZip;
  final String companyVat;

  const UpdateSettingsCompanyInfo({
    required this.companyEmail,
    required this.companyPhone,
    required this.companyAddress,
    required this.companyCity,
    required this.companyState,
    required this.companyCountry,
    required this.companyZip,
    required this.companyVat,
  });

  @override
  List<Object?> get props => [
    companyEmail,
    companyPhone,
    companyAddress,
    companyCity,
    companyState,
    companyCountry,
    companyZip,
    companyVat
  ];
}
class UpdateSettingsEmail extends SettingsEvent {
  final String email;
  final String password;
  final String smtpHost;
  final String smtpPort;
  final String emailContentType;
  final String smtpEncryption;


  const UpdateSettingsEmail({
    required this.email,
    required this.password,
    required this.smtpEncryption,
    required this.smtpPort,
    required this.emailContentType,
    required this.smtpHost,

  });

  @override
  List<Object?> get props => [
    email,
    password,
    smtpEncryption,
    smtpPort,
    emailContentType,
    smtpHost,
  ];
}

class UpdateGeneralSettings extends SettingsEvent {
  final String? title;
  final String? siteUrl;
  final File? fullLogo;
  final File? favicon;
  final String? timezone;
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

  const UpdateGeneralSettings({
    this.title,
    this.siteUrl,
    this.fullLogo,
    this.favicon,
    this.currencyFullForm,
    this.currencySymbol,
    this.timezone,
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
    timezone,
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



