class SettingsModel {
  final bool error;
  final String message;
  final Settings settings;

  SettingsModel({
    required this.error,
    required this.message,
    required this.settings,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      settings: Settings.fromJson(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'settings': settings.toJson(),
    };
  }
}

class Settings {
  final String companyTitle;
  final String currencyFullForm;
  final String currencySymbol;
  final String currencyCode;
  final String currencySymbolPosition;
  final String currencyFormat;
  final String decimalPointsInCurrency;
  final String timezone;
  final String dateFormat;
  final String timeFormat;
  final String toastPosition;
  final String toastTimeOut;
  final String footerText;
  final String fullLogo;
  final String halfLogo;
  final String favicon;
  final bool allowSignup;
  final String allowedMaxUploadSize;
  final String maxAttempts;
  final String lockTime;
  final bool priLangAsAuth;
  final String allowedFileTypes;
  final String maxFiles;
  final int upcomingWorkAnniversaries;
  final int membersOnLeave;
  final int upcomingBirthdays;
  final String siteUrl;

  Settings({
    required this.companyTitle,
    required this.currencyFullForm,
    required this.currencySymbol,
    required this.currencyCode,
    required this.currencySymbolPosition,
    required this.currencyFormat,
    required this.decimalPointsInCurrency,
    required this.timezone,
    required this.dateFormat,
    required this.timeFormat,
    required this.toastPosition,
    required this.toastTimeOut,
    required this.footerText,
    required this.fullLogo,
    required this.halfLogo,
    required this.favicon,
    required this.allowSignup,
    required this.allowedMaxUploadSize,
    required this.maxAttempts,
    required this.lockTime,
    required this.priLangAsAuth,
    required this.allowedFileTypes,
    required this.maxFiles,
    required this.upcomingWorkAnniversaries,
    required this.membersOnLeave,
    required this.upcomingBirthdays,
    required this.siteUrl,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      companyTitle: json['company_title'] ?? '',
      currencyFullForm: json['currency_full_form'] ?? '',
      currencySymbol: json['currency_symbol'] ?? '',
      currencyCode: json['currency_code'] ?? '',
      currencySymbolPosition: json['currency_symbol_position'] ?? '',
      currencyFormat: json['currency_formate'] ?? '',
      decimalPointsInCurrency: json['decimal_points_in_currency'] ?? '',
      timezone: json['timezone'] ?? '',
      dateFormat: json['date_format'] ?? '',
      timeFormat: json['time_format'] ?? '',
      toastPosition: json['toast_position'] ?? '',
      toastTimeOut: json['toast_time_out'] ?? '',
      footerText: json['footer_text'] ?? '',
      fullLogo: json['full_logo'] ?? '',
      halfLogo: json['half_logo'] ?? '',
      favicon: json['favicon'] ?? '',
      allowSignup: json['allowSignup'] ?? false,
      allowedMaxUploadSize: json['allowed_max_upload_size'] ?? '',
      maxAttempts: json['max_attempts'] ?? '',
      lockTime: json['lock_time'] ?? '',
      priLangAsAuth: json['priLangAsAuth'] ?? false,
      allowedFileTypes: json['allowed_file_types'] ?? '',
      maxFiles: json['max_files'] ?? '',
      upcomingWorkAnniversaries: json['upcomingWorkAnniversaries'] ?? 0,
      membersOnLeave: json['membersOnLeave'] ?? 0,
      upcomingBirthdays: json['upcomingBirthdays'] ?? 0,
      siteUrl: json['site_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_title': companyTitle,
      'currency_full_form': currencyFullForm,
      'currency_symbol': currencySymbol,
      'currency_code': currencyCode,
      'currency_symbol_position': currencySymbolPosition,
      'currency_formate': currencyFormat,
      'decimal_points_in_currency': decimalPointsInCurrency,
      'timezone': timezone,
      'date_format': dateFormat,
      'time_format': timeFormat,
      'toast_position': toastPosition,
      'toast_time_out': toastTimeOut,
      'footer_text': footerText,
      'full_logo': fullLogo,
      'half_logo': halfLogo,
      'favicon': favicon,
      'allowSignup': allowSignup,
      'allowed_max_upload_size': allowedMaxUploadSize,
      'max_attempts': maxAttempts,
      'lock_time': lockTime,
      'priLangAsAuth': priLangAsAuth,
      'allowed_file_types': allowedFileTypes,
      'max_files': maxFiles,
      'upcomingWorkAnniversaries': upcomingWorkAnniversaries,
      'membersOnLeave': membersOnLeave,
      'upcomingBirthdays': upcomingBirthdays,
      'site_url': siteUrl,
    };
  }
}
