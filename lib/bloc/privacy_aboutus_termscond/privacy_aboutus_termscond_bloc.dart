import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../data/repositories/Setting/setting_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';
import 'privacy_aboutus_termscond_event.dart';
import 'privacy_aboutus_termscond_state.dart';

class PrivacyAboutusTermsCondBloc
    extends Bloc<ActivityLogEvent, PrivacyAboutusTermsCondState> {

  PrivacyAboutusTermsCondBloc() : super(PriInitial()) {
    on<PrivacyPolicy>(_onUpdatePrivacyPolicy);
    on<GetPrivacyPolicy>(_getPrivacyPolicy);
    on<GetAboutUs>(_getAbouUs);
    on<AbouUs>(_onUpdateAbouUs);
    on<TermsAndCondition>(_onUpdateTermsAndCondition);
    on<GetTermsAndCondition>(_getTermsAndCondition);
  }

  Future<void> _onUpdatePrivacyPolicy(
      PrivacyPolicy event, Emitter<PrivacyAboutusTermsCondState> emit) async {
    try {
      emit(PriLoading());
      Map<String, dynamic> result = await SettingRepo().privacyPolicyUpdate(
          privacyPolicy: event.privacyPolicyText, from: "privacypolicy");

      if (result['error'] == false) {
        emit(PrivacyUpdatedSuccess(result['data']['value']));
      }
      if (result['error'] == true) {
        emit((PrivacyUpdatedError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((PrivacyUpdatedError("Error: $e")));
    }
  }

  Future<void> _getPrivacyPolicy(GetPrivacyPolicy event,
      Emitter<PrivacyAboutusTermsCondState> emit) async {
    try {
      String privacypolicy;
      emit(PriLoading());
      Map<String, dynamic> result = await SettingRepo().privacyPolicy();
      privacypolicy = result['settings']['privacy_policy']??"";
      print(";grfdklm $privacypolicy");
      if (result['error'] == false) {
        emit(PrivacyPolicyValue(privacypolicy));
      }
      if (result['error'] == true) {
        emit((PrivacyUpdatedError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((CommonError("Error: $e")));
    }
  }

  Future<void> _getTermsAndCondition(GetTermsAndCondition event,
      Emitter<PrivacyAboutusTermsCondState> emit) async {
    try {
      String privacypolicy;
      emit(PriLoading());
      Map<String, dynamic> result = await SettingRepo().termsAndConditions();
      privacypolicy = result['settings']['terms_conditions']??"";
      print("fsjdfhn $privacypolicy");
      if (result['error'] == false) {
        emit(TermsAndConditionValue(privacypolicy));
      }
      if (result['error'] == true) {
        emit((TermsAndConditionError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((CommonError("Error: $e")));
    }
  }

  Future<void> _getAbouUs(
      GetAboutUs event, Emitter<PrivacyAboutusTermsCondState> emit) async {
    try {
      String aboutUs;
      emit(PriLoading());
      Map<String, dynamic> result = await SettingRepo().aboutUs();
      aboutUs = result['settings']['about_us']??"";
      if (result['error'] == false) {
        emit(AboutUsValue(aboutUs));
      }
      if (result['error'] == true) {
        emit((AboutUsError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((CommonError("Error: $e")));
    }
  }

  Future<void> _onUpdateAbouUs(
      AbouUs event, Emitter<PrivacyAboutusTermsCondState> emit) async {
    try {
      emit(PriLoading());
      Map<String, dynamic> result = await SettingRepo().privacyPolicyUpdate(
          privacyPolicy: event.abouUsText, from: "aboutus");

      if (result['error'] == false) {
        emit(AboutUsUpdatedSuccess(result['data']['value']));
      }
      if (result['error'] == true) {
        emit((PrivacyUpdatedError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((PrivacyUpdatedError("Error: $e")));
    }
  }

  Future<void> _onUpdateTermsAndCondition(TermsAndCondition event,
      Emitter<PrivacyAboutusTermsCondState> emit) async {
    try {
      emit(PriLoading());
      Map<String, dynamic> result = await SettingRepo().privacyPolicyUpdate(
          privacyPolicy: event.termsAndConditionText, from: "terms");

      if (result['error'] == false) {
        emit(TermsAndConditionsUpdatedSuccess(
            result['data']['value']));
      }
      if (result['error'] == true) {
        emit((PrivacyUpdatedError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((PrivacyUpdatedError("Error: $e")));
    }
  }
}
