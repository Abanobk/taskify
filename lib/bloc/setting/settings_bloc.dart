import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:taskify/bloc/setting/settings_event.dart';
import 'package:taskify/data/repositories/Setting/setting_repo.dart';
import '../../data/model/settings/timezone_model.dart';
import '../../utils/widgets/toast_widget.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  String? currencySymbol;
  String? currencyPosition;
  String? currencyFormat;
  String? decimalPoints;
  String? dateformat;
  String? comapanyTitle;
  String? currencyFullForm;
  String? currencyCode;
  String? decimalPointsInCurrency;
  String? timeZone;
  String? timeFormat;
  String? fullLogo;
  String? halfLogo;
  String? favicon;
  int? allowSignup;
  String? maxAllowedUplaodSize;
  String? maxAttempts;
  String? lockTime;
  String? allowedFileTypes;
  String? siteUrl;
  String? maxFiles;
  int? upcomingAnniversary;
  int? membersOnLeave;
  int? upcomingBirthdays;
  String? email;
  String? phone;
  String? address;
  String? city;
  String? stateOfComapny;
  String? country;
  String? website;
  String? zipcode;
  String? vatNumber;
  String? companyEmail;
  String? emailPasswordSetting;
  String? smtpHost;
  String? smtpPort;
  String? emailContentType;
  String? smtpEncryption;
  String? baseUrl;
  String? mediaStorageType;
  String? s3Key;
  String? s3Secret;
  String? s3Region;
  String? s3Bucket;
  String? whatsappAccessToken;
  String? whatsappPhoneNumberId;
  String? authorization;
  String? bodyFrom;
  String? bodyTo;
  String? body;
  String? messagingAuthorization;
  Map<String, String>? headerData;
  Map<String, String>? bodyFormData;
  Map<String, String>? paramsData;
  List<Map<String, String>> headerDataList = [];
  List<Map<String, String>> bodyFormDataList = [];
  List<TimeZoneInfoModel> timeZoneList = [];
  List<Map<String, String>> paramDataList = [];
  String? mediaStorage;
  String? method;
  String? slackBotToken;
  SettingsBloc() : super(SettingsInitial()) {
    on<SettingsList>(_getListOfSettings);
    on<UpdateSettingsSmsHeader>(_onUpdateSettingsSmsHeader);
    on<UpdateSettingsWhatsApp>(_onUpdateSettingsWhatsApp);
    on<UpdateSettingsSlack>(_onUpdateSettingsSlack);
    on<UpdateSettingsMediaStorage>(_onUpdateSettingsMediaStorage);
    on<UpdateGeneralSettings>(_onUpdateGeneralSettings);
    on<UpdateSettingsSecurity>(_onUpdateSettingsSecurity);
    on<UpdateSettingsCompanyInfo>(_onUpdateSettingsCompanyInfo);
    on<UpdateSettingsEmail>(_onUpdateSettingsEmail);
  }
  void _onUpdateSettingsCompanyInfo(
      UpdateSettingsCompanyInfo event, Emitter<SettingsState> emit) async {
    if (state is SettingsSuccess) {
      emit(HeaderSettingEditSuccessLoading());
      try {
        Map<String, dynamic> result =
            await SettingRepo().companyInformationUpdate(
          email: event.companyEmail,
          phoneNumber: event.companyPhone,
          vatNumber: event.companyVat,
          address: event.companyAddress,
          city: event.companyCity,
          state: event.companyState,
          country: event.companyCountry,
          zipCode: event.companyZip,
        );

        if (result['error'] == false) {
          emit(UpdateCompanyInfoSetting()); // Emit success state
        } else {
          emit(ComapnyInformationSettingsEditError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } catch (e) {
        print('Error while updating security settings: $e');
        emit(SettingsError(
            'An error occurred while updating security settings'));
      }
    }
  }

  void _onUpdateSettingsEmail(
      UpdateSettingsEmail event, Emitter<SettingsState> emit) async {
    if (state is SettingsSuccess) {
      emit(UpdateEmailSettingLoadingSuccess());
      try {
        Map<String, dynamic> result = await SettingRepo().emailUpdate(
          email: event.email,
          password: event.password,
          smtpEncyption: event.smtpEncryption,
          smtpPort: event.smtpPort,
          smtpHost: event.smtpHost,
          emailContentType: event.emailContentType,
        );

        if (result['error'] == false) {
          emit(UpdateEmailSettingSuccess()); // Emit success state
        } else {
          emit(UpdateEmailSettingError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } catch (e) {
        print('Error while updating security settings: $e');
        emit(SettingsError(
            'An error occurred while updating security settings'));
      }
    }
  }

  void _onUpdateSettingsSecurity(
      UpdateSettingsSecurity event, Emitter<SettingsState> emit) async {
    if (state is SettingsSuccess) {
      emit(HeaderSettingEditSuccessLoading());
      try {
        Map<String, dynamic> result = await SettingRepo().securitySettingUpdate(
          maxAttempt: event.maxAttempt,
          lockTime: event.lockTime,
          allowMaxUploadSize: event.allowMaxUploadSize,
          maxFilesAllowed: event.maxFilesAllowed,
          allowedFileType: event.allowedFileType,
          isAllowedSignUP: event.isAllowedSignUP,
        );

        if (result['error'] == false) {
          emit(UpdateSecuritySetting()); // Emit success state
        } else {
          emit(SecuritySettingsEditError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } catch (e) {
        print('Error while updating security settings: $e');
        emit(SecuritySettingsEditError(
            'An error occurred while updating security settings'));
      }
    }
  }

  void _onUpdateGeneralSettings(
      UpdateGeneralSettings event, Emitter<SettingsState> emit) async {
    if (state is SettingsSuccess) {
      emit(HeaderSettingEditSuccessLoading());
      print("krheASKFRHs ${event.fullLogo}");
      try {
        Map<String, dynamic> result = await SettingRepo().generalSettingUpdate(
          title: event.title,
          siteUrl: event.siteUrl,
          fullLogo: event.fullLogo,
          favicon: event.favicon,
          currencyFullForm: event.currencyFullForm,
          currencySymbol: event.currencySymbol,
          timezone: event.timezone,
          currencyCode: event.currencyCode,
          currencySymbolPosition: event.currencySymbolPosition,
          currencyFormat: event.currencyFormat,
          decimalPoints: event.decimalPoints,
          dateFormat: event.dateFormat,
          timeFormat: event.timeFormat,
          birthdaySec: event.birthdaySec,
          workanniversarySec: event.workAnniversarySec,
          leaveReqSec: event.leaveReqSec,
        );

        if (result['error'] == false) {
          emit(UpdateGeneralSetting());
          // add(const WorkspaceList());
        } else {
          emit(GeneralSettingsEditError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } catch (e) {
        print('Error while updating Task: $e');
        emit(GeneralSettingsEditError(
            'An error occurred while updating settings'));
      }
    }
  }

  void _onUpdateSettingsSmsHeader(
      UpdateSettingsSmsHeader event, Emitter<SettingsState> emit) async {
    if (state is SettingsSuccess) {
      emit(HeaderSettingEditSuccessLoading());
      try {
        Map<String, dynamic> result =
            await SettingRepo().settingUpdate(event.smsModel);
        if (result['error'] == false) {
          emit(SettingsHeaderUpdated(smsModel: event.smsModel));
          // add(const WorkspaceList());
        }
        if (result['error'] == true) {
          emit((SettingHeaderEditError(result['message'])));
          flutterToastCustom(msg: result['message']);
        }
      } catch (e) {
        print('Error while updating Task: $e');
        // Optionally, handle the error state, e.g. emit an error state
      }
    }
  }

  void _onUpdateSettingsWhatsApp(
      UpdateSettingsWhatsApp event, Emitter<SettingsState> emit) async {
    if (state is SettingsSuccess) {
      emit(WhatsappSettingEditSuccessLoading());
      try {
        Map<String, dynamic> result = await SettingRepo()
            .whatsAppsettingUpdate(event.accessToken, event.phoneNumId);
        if (result['error'] == false) {
          emit(SettingsWhatsAppUpdated());
          // add(const WorkspaceList());
        }
        if (result['error'] == true) {
          emit((SettingWhatsappEditError(result['message'])));
          flutterToastCustom(msg: result['message']);
        }
      } catch (e) {
        print('Error while updating Task: $e');
        // Optionally, handle the error state, e.g. emit an error state
      }
    }
  }

  void _onUpdateSettingsSlack(
      UpdateSettingsSlack event, Emitter<SettingsState> emit) async {
    if (state is SettingsSuccess) {
      emit(SlackSettingEditSuccessLoading());
      try {
        Map<String, dynamic> result =
            await SettingRepo().slackSettingUpdate(event.slackBotToken);
        if (result['error'] == false) {
          emit(SettingsSlackUpdated());
          // add(const WorkspaceList());
        }
        if (result['error'] == true) {
          emit((SettingSlackEditError(result['message'])));
          flutterToastCustom(msg: result['message']);
        }
      } catch (e) {
        print('Error while updating Task: $e');
        // Optionally, handle the error state, e.g. emit an error state
      }
    }
  }

  void _onUpdateSettingsMediaStorage(
      UpdateSettingsMediaStorage event, Emitter<SettingsState> emit) async {
    if (state is SettingsSuccess) {
      emit(MediaStorageSettingEditSuccessLoading());
      try {
        Map<String, dynamic> result = await SettingRepo()
            .mediaStorageSettingUpdate(
                storageType: event.storage,
                key: event.s3AccessKey,
                secret: event.s3SecretKey,
                region: event.s3RegionKey,
                bucket: event.s3BucketKey);
        if (result['error'] == false) {
          emit(SettingsMediaStorageUpdated());
          // add(const WorkspaceList());
        }
        if (result['error'] == true) {
          emit((SettingMediaStorageEditError(result['message'])));
          flutterToastCustom(msg: result['message']);
        }
      } catch (e) {
        print('Error while updating Task: $e');
        // Optionally, handle the error state, e.g. emit an error state
      }
    }
  }

  Future<void> _getListOfSettings(
      SettingsList event, Emitter<SettingsState> emit) async {
    try {
      emit(SettingsLoading());

      int parseToInt(dynamic value) {
        if (value is int) return value;
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      }

      var result = await SettingRepo().setting(event.endPoints);

      if (result['error'] == false) {
        print("fjsfbsLDKFJB ${result['variable']}");
        print("fjsfbsLDKFJB ${result['settings'].isNotEmpty}");

        if (result['error'] == false) {
          switch (result['variable']) {
            case 'general_settings':
              if (result['settings'].isNotEmpty) {
                var settings = result['settings'];
                settings.forEach((key, value) {
                  print("Key: $key, Value: $value, Type: ${value.runtimeType}");
                });
                comapanyTitle = settings?['company_title'] ?? "";
                currencyFullForm = settings?['currency_full_form'] ?? "";
                currencySymbol = settings?['currency_symbol'] ?? "";
                currencyCode = settings?['currency_code'] ?? "";
                dateformat = settings?['date_format'] ?? "";
                fullLogo = settings?['full_logo'] ?? "";
                halfLogo = settings?['half_logo'] ?? "";
                favicon = settings?['favicon'] ?? "";
                allowedFileTypes = settings?['allowed_file_types'] ?? "";

                maxAttempts = settings?['max_attempts'];

                lockTime = settings?['lock_time'];

                maxFiles = settings?['max_files'];


                maxAllowedUplaodSize = settings?['allowed_max_upload_size'];


                allowSignup = settings?['allowSignup'];
                if (allowSignup is! int) {
                  allowSignup = int.tryParse(allowSignup.toString()) ?? 0;
                }

                decimalPoints = settings?['decimal_points'];


                currencyPosition = settings?['currency_symbol_position'] ?? "";
                currencyFormat = settings?['currency_format'] ?? "";
                timeFormat = settings?['time_format'] ?? "";
                siteUrl = settings?['site_url'] ?? "";

                upcomingBirthdays = parseToInt(settings?['upcomingBirthdays']);
                upcomingAnniversary = parseToInt(settings?['upcomingWorkAnniversaries']);
                membersOnLeave = parseToInt(settings?['membersOnLeave']);
                timeZone = settings?['timezone'] ?? "";
                decimalPointsInCurrency = settings?['decimal_points_in_currency'] ?? "";

                timeZoneList = (settings?['timezones'] as List?)
                    ?.map((e) => TimeZoneInfoModel.fromList(e))
                    .toList() ??
                    [];

                print("Timezone: $upcomingAnniversary");
                print("Site URL: $siteUrl");
                print("Currency Symbol: $currencySymbol");
              }
              break;

            case 'company_information':
              if (result['settings'].isNotEmpty) {
                print("kgfnfg,nrdf gv.,m ");
                var settings = result['settings'];
                email = settings?['companyEmail'] ?? "";
                phone = settings?['companyPhone'] ?? "";
                address = settings?['companyAddress'] ?? "";
                city = settings?['companyCity'] ?? "";
                stateOfComapny = settings?['companyState'] ?? "";
                country = settings?['companyCountry'] ?? "";
                zipcode = settings?['companyZip'] ?? "";
                website = settings?['companyWebsite'] ?? "";
                vatNumber = settings?['companyVatNumber'] ?? "";
              }
              break;
            case 'email_settings':
              if (result['settings'].isNotEmpty) {
                var settings = result['settings'];
                print("fjsfbsLDKFJB ${result['settings'].isNotEmpty}");

                companyEmail = settings['email'] ?? "";
                emailPasswordSetting = settings['password'] ?? "";
                smtpHost = settings['smtp_host'] ?? "";
                smtpPort = settings['smtp_port'] ?? "";
                emailContentType = settings['email_content_type'] ?? "";
                smtpEncryption = settings['smtp_encryption'] ?? "";
              }
              break;
            case 'sms_gateway_settings':
              if (result['settings'].isNotEmpty) {
                var settings = result['settings'];
                baseUrl = settings?['base_url'] ?? "";
                if (settings?['header_data'] != null) {
                  Map<String, dynamic> rawHeaderData = settings['header_data'];
                  headerDataList = rawHeaderData.entries
                      .map((entry) => {entry.key: entry.value.toString()})
                      .toList();
                }
                if (settings?['body_formdata'] != null) {
                  Map<String, dynamic> rawBodyData = settings['body_formdata'];
                  bodyFormDataList = rawBodyData.entries
                      .map((entry) => {entry.key: entry.value.toString()})
                      .toList();
                }
                if (settings?['params_data'] != null) {
                  Map<String, dynamic> rawParamsData = settings['params_data'];
                  paramDataList = rawParamsData.entries
                      .map((entry) => {entry.key: entry.value.toString()})
                      .toList();
                }
                messagingAuthorization =
                    settings?['header_data']?['Authorization'] ?? "";
                method = settings?['sms_gateway_method'] ?? "";
              }
              break;
            case 'media_storage_settings':
              if (result['settings'].isNotEmpty) {
                print("fjsfbsLDKFJB s as ${result['settings']}");
                var settings = result['settings'];
                mediaStorageType = settings['media_storage_type'] ?? "";
                s3Key = settings['s3_key'] ?? "";
                s3Secret = settings['s3_secret'] ?? "";
                s3Region = settings['s3_region'] ?? "";
                s3Bucket = settings['s3_bucket'] ?? "";
                print("fjsfbsLDKFJB s asfed ${mediaStorageType}");
              }
              break;
            default:
              if ( result['settings'].isNotEmpty) {
                var settings = result['settings'];
                comapanyTitle = settings?['company_title'] ?? "";
                currencyFullForm = settings?['currency_full_form'] ?? "";
                currencySymbol = settings['currency_symbol'] ?? "";
                currencyCode = settings?['currency_code'] ?? "";

                fullLogo = settings?['full_logo'] ?? "";
                halfLogo = settings?['half_logo'] ?? "";
                favicon = settings?['favicon'] ?? "";
                allowedFileTypes = settings?['allowed_file_types'] ?? "";
                maxAttempts = settings?['max_attempts'] ?? "";
                lockTime = settings?['lock_time'] ?? "";
                maxFiles = settings?['max_files'] ?? "";
                maxAllowedUplaodSize =
                    settings?['allowed_max_upload_size'] ?? "";
                allowSignup = settings?['allowSignup'] ?? "";
                siteUrl = settings?['site_url'] ?? "";
                currencyPosition = settings?['currency_symbol_position'] ?? "";
                currencyFormat = settings?['currency_format'] ?? "";
                decimalPoints = settings?['decimal_points'] ?? "";
                timeFormat = settings?['time_format'] ?? "";
                upcomingBirthdays = settings?['upcomingBirthdays'] ?? "";
                upcomingAnniversary =
                    parseToInt(settings?['upcomingWorkAnniversaries'] ?? 0);
                membersOnLeave = settings?['membersOnLeave'] ?? "";
                decimalPointsInCurrency =
                    settings?['decimal_points_in_currency'] ?? "";
                timeZoneList = (settings?['timezones'] as List?)
                        ?.map((e) => TimeZoneInfoModel.fromList(e))
                        .toList() ??
                    [];
                print("fgesdg $currencySymbol");
              }
              if (result['settings'] is List && result['settings'].isNotEmpty) {
                var settings = result['settings'][0];
                currencySymbol = settings?['currency_symbol'] ?? "";
              }
          }

          emit(SettingsSuccess());
        }

        emit(SettingsSuccess());
      } else {
        emit(SettingsError(result['message']));
      }
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
