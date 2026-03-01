import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i18n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('hi'),
    Locale('ko'),
    Locale('pt'),
    Locale('vi')
  ];

  /// No description provided for @isDemooperation.
  ///
  /// In en, this message translates to:
  /// **'This operation is not allowed in Demo Mode'**
  String get isDemooperation;

  /// No description provided for @rememberDailyTasks.
  ///
  /// In en, this message translates to:
  /// **'Remember Daily Tasks'**
  String get rememberDailyTasks;

  /// No description provided for @theAppProvideAPlatformWhereYouNoNeedToRememberYouEverydayTask.
  ///
  /// In en, this message translates to:
  /// **'The app provide a platform where you no need to remember you everyday task'**
  String get theAppProvideAPlatformWhereYouNoNeedToRememberYouEverydayTask;

  /// No description provided for @trackProgress.
  ///
  /// In en, this message translates to:
  /// **'Track Progress'**
  String get trackProgress;

  /// No description provided for @youCanEasilyTrackYourDailyProgressAndPerformYourTaskEfficiently.
  ///
  /// In en, this message translates to:
  /// **'You can easily track your daily progress and perform your task efficiently'**
  String get youCanEasilyTrackYourDailyProgressAndPerformYourTaskEfficiently;

  /// No description provided for @getNotifiedInstantly.
  ///
  /// In en, this message translates to:
  /// **'Get Notified Instantly'**
  String get getNotifiedInstantly;

  /// No description provided for @youGetNotificationsOfYourTaskAndTrackYourDailyWorkOnThisPlatform.
  ///
  /// In en, this message translates to:
  /// **'You get notifications of your task and track your daily work on this platform'**
  String get youGetNotificationsOfYourTaskAndTrackYourDailyWorkOnThisPlatform;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @tryagain.
  ///
  /// In en, this message translates to:
  /// **'Please, Try again..'**
  String get tryagain;

  /// No description provided for @totalProject.
  ///
  /// In en, this message translates to:
  /// **'Total Projects'**
  String get totalProject;

  /// No description provided for @selectmembers.
  ///
  /// In en, this message translates to:
  /// **'Select members'**
  String get selectmembers;

  /// No description provided for @settingbuttontootltip.
  ///
  /// In en, this message translates to:
  /// **'Onclick, date and currency will be updated'**
  String get settingbuttontootltip;

  /// No description provided for @settingbutton.
  ///
  /// In en, this message translates to:
  /// **'Date and Currency Updated'**
  String get settingbutton;

  /// No description provided for @sevendays.
  ///
  /// In en, this message translates to:
  /// **'7 day(s)'**
  String get sevendays;

  /// No description provided for @viewmore.
  ///
  /// In en, this message translates to:
  /// **'view more'**
  String get viewmore;

  /// No description provided for @swipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe'**
  String get swipe;

  /// No description provided for @swipelefttodelete.
  ///
  /// In en, this message translates to:
  /// **'⬅️ Swipe left to delete'**
  String get swipelefttodelete;

  /// No description provided for @swiperighttoedit.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to edit ➡️'**
  String get swiperighttoedit;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @speak.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get speak;

  /// No description provided for @usersFordrawer.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersFordrawer;

  /// No description provided for @clientsFordrawer.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clientsFordrawer;

  /// No description provided for @trytosaysomething.
  ///
  /// In en, this message translates to:
  /// **'Try saying something...'**
  String get trytosaysomething;

  /// No description provided for @nodescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get nodescription;

  /// No description provided for @verifiedemail.
  ///
  /// In en, this message translates to:
  /// **'Verified Email'**
  String get verifiedemail;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @nousers.
  ///
  /// In en, this message translates to:
  /// **'no user'**
  String get nousers;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @startdate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startdate;

  /// No description provided for @selectstartandenddatefromhere.
  ///
  /// In en, this message translates to:
  /// **'(select start and end date from here)'**
  String get selectstartandenddatefromhere;

  /// No description provided for @privacypolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacypolicy;

  /// No description provided for @personalinfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalinfo;

  /// No description provided for @aboutus.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get aboutus;

  /// No description provided for @allusers.
  ///
  /// In en, this message translates to:
  /// **'All User(s)'**
  String get allusers;

  /// No description provided for @allclients.
  ///
  /// In en, this message translates to:
  /// **'All Client(s)'**
  String get allclients;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accounts;

  /// No description provided for @termsandconditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsandconditions;

  /// No description provided for @privacyandsecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy and Security'**
  String get privacyandsecurity;

  /// No description provided for @createleavereq.
  ///
  /// In en, this message translates to:
  /// **'Create leave request'**
  String get createleavereq;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitApp;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @pushin.
  ///
  /// In en, this message translates to:
  /// **'Push-In'**
  String get pushin;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @priorities.
  ///
  /// In en, this message translates to:
  /// **'Priorities'**
  String get priorities;

  /// No description provided for @doyouwanttoexitApp.
  ///
  /// In en, this message translates to:
  /// **'Do you want to exit the app?'**
  String get doyouwanttoexitApp;

  /// No description provided for @totalTask.
  ///
  /// In en, this message translates to:
  /// **'Total Tasks'**
  String get totalTask;

  /// No description provided for @totalUser.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUser;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'All Clear'**
  String get clear;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @totalClient.
  ///
  /// In en, this message translates to:
  /// **'Total Clients'**
  String get totalClient;

  /// No description provided for @noPermission.
  ///
  /// In en, this message translates to:
  /// **'Unauthorised to access this.'**
  String get noPermission;

  /// No description provided for @totalMeeting.
  ///
  /// In en, this message translates to:
  /// **'Total Meetings'**
  String get totalMeeting;

  /// No description provided for @totalTodo.
  ///
  /// In en, this message translates to:
  /// **'Total Todos'**
  String get totalTodo;

  /// No description provided for @todo.
  ///
  /// In en, this message translates to:
  /// **'Todo'**
  String get todo;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @seeall.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeall;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome '**
  String get welcomeBack;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @hey.
  ///
  /// In en, this message translates to:
  /// **'Hey 👋🏻 '**
  String get hey;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgetPassword;

  /// No description provided for @noInternetWhoops.
  ///
  /// In en, this message translates to:
  /// **'Whoops !!'**
  String get noInternetWhoops;

  /// No description provided for @nointernet.
  ///
  /// In en, this message translates to:
  /// **'No Internet connection found. \n Check your connection or Try again. !!'**
  String get nointernet;

  /// No description provided for @noOnternetDesc.
  ///
  /// In en, this message translates to:
  /// **'Slow or no internet connection.\n Please check your internet settings.'**
  String get noOnternetDesc;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @myproject.
  ///
  /// In en, this message translates to:
  /// **'My Projects'**
  String get myproject;

  /// No description provided for @taskpending.
  ///
  /// In en, this message translates to:
  /// **'Tasks Pending'**
  String get taskpending;

  /// No description provided for @todaysTask.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Tasks'**
  String get todaysTask;

  /// No description provided for @upcomingBirthday.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Birthdays 🎂🥳'**
  String get upcomingBirthday;

  /// No description provided for @upcomingLeaveRequest.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Leave Request'**
  String get upcomingLeaveRequest;

  /// No description provided for @upcomingWorkAnni.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Work Anniversaries 🥳'**
  String get upcomingWorkAnni;

  /// No description provided for @alreadyhaveanaccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyhaveanaccount;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create New\nAccount'**
  String get createNewAccount;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @searchhere.
  ///
  /// In en, this message translates to:
  /// **'Search here'**
  String get searchhere;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @yourtodaystaskalmostdone.
  ///
  /// In en, this message translates to:
  /// **'Your today’s task almost done!'**
  String get yourtodaystaskalmostdone;

  /// No description provided for @tasksFromDrawer.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksFromDrawer;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Task(s)'**
  String get tasks;

  /// No description provided for @createProj.
  ///
  /// In en, this message translates to:
  /// **'Create project'**
  String get createProj;

  /// No description provided for @deleteProj.
  ///
  /// In en, this message translates to:
  /// **'Delete project'**
  String get deleteProj;

  /// No description provided for @task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task;

  /// No description provided for @statuses.
  ///
  /// In en, this message translates to:
  /// **'Statuses'**
  String get statuses;

  /// No description provided for @workspaces.
  ///
  /// In en, this message translates to:
  /// **'Workspace(s)'**
  String get workspaces;

  /// No description provided for @workspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get workspace;

  /// No description provided for @workspaceFromDrawer.
  ///
  /// In en, this message translates to:
  /// **'Workspaces'**
  String get workspaceFromDrawer;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @todos.
  ///
  /// In en, this message translates to:
  /// **'Todos'**
  String get todos;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'User(s)'**
  String get users;

  /// No description provided for @notificationusers.
  ///
  /// In en, this message translates to:
  /// **'Notification users'**
  String get notificationusers;

  /// No description provided for @notificationclient.
  ///
  /// In en, this message translates to:
  /// **'Notification Client(s)'**
  String get notificationclient;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Client(s)'**
  String get clients;

  /// No description provided for @contracts.
  ///
  /// In en, this message translates to:
  /// **'Contracts'**
  String get contracts;

  /// No description provided for @payslips.
  ///
  /// In en, this message translates to:
  /// **'Payslips'**
  String get payslips;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @leavereqs.
  ///
  /// In en, this message translates to:
  /// **'Leave Requests'**
  String get leavereqs;

  /// No description provided for @activitylogs.
  ///
  /// In en, this message translates to:
  /// **'Activity logs'**
  String get activitylogs;

  /// No description provided for @manageprojects.
  ///
  /// In en, this message translates to:
  /// **'Manage Projects'**
  String get manageprojects;

  /// No description provided for @favouriterojects.
  ///
  /// In en, this message translates to:
  /// **'Favorite Projects'**
  String get favouriterojects;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @managecontracts.
  ///
  /// In en, this message translates to:
  /// **'Manage Contracts'**
  String get managecontracts;

  /// No description provided for @contractstypes.
  ///
  /// In en, this message translates to:
  /// **'Contracts Types'**
  String get contractstypes;

  /// No description provided for @managepayslips.
  ///
  /// In en, this message translates to:
  /// **'Manage Payslips'**
  String get managepayslips;

  /// No description provided for @allowances.
  ///
  /// In en, this message translates to:
  /// **'Allowances'**
  String get allowances;

  /// No description provided for @deductions.
  ///
  /// In en, this message translates to:
  /// **'Deductions'**
  String get deductions;

  /// No description provided for @deduction.
  ///
  /// In en, this message translates to:
  /// **'Deduction'**
  String get deduction;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @estimatesinvoices.
  ///
  /// In en, this message translates to:
  /// **'Estimates/Invoices'**
  String get estimatesinvoices;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @paymentmethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentmethods;

  /// No description provided for @taxes.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get taxes;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'Days Left'**
  String get daysLeft;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @slowInternet.
  ///
  /// In en, this message translates to:
  /// **'Slow or no internet connections. Please check your internet settings'**
  String get slowInternet;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @logInToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Login To Your Account'**
  String get logInToYourAccount;

  /// No description provided for @loginWithSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Login with Social Media'**
  String get loginWithSocialMedia;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'required'**
  String get required;

  /// No description provided for @firstname.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstname;

  /// No description provided for @lastname.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastname;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @conPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get conPassword;

  /// No description provided for @pleaseenterpassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseenterpassword;

  /// No description provided for @pleaseenteremail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseenteremail;

  /// No description provided for @pleaseenterconpassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter confirm password'**
  String get pleaseenterconpassword;

  /// No description provided for @pleaseenterrole.
  ///
  /// In en, this message translates to:
  /// **'Please enter role'**
  String get pleaseenterrole;

  /// No description provided for @requireEmailVerification.
  ///
  /// In en, this message translates to:
  /// **'REQUIRE EMAIL VERIFICATION?'**
  String get requireEmailVerification;

  /// No description provided for @profilePicture.
  ///
  /// In en, this message translates to:
  /// **'Profile picture'**
  String get profilePicture;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @isInternamPurpose.
  ///
  /// In en, this message translates to:
  /// **'Is this a client for internal purpose only?'**
  String get isInternamPurpose;

  /// No description provided for @isInternamPurposeOnly.
  ///
  /// In en, this message translates to:
  /// **'Internal purpose status'**
  String get isInternamPurposeOnly;

  /// No description provided for @ifDeactivate.
  ///
  /// In en, this message translates to:
  /// **'(IF DEACTIVATED, THE USER WON\'T BE ABLE TO LOG IN THEIR ACCOUNT)'**
  String get ifDeactivate;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @dontHaveanAccount.
  ///
  /// In en, this message translates to:
  /// **'Dont have an account? '**
  String get dontHaveanAccount;

  /// No description provided for @emailVerification.
  ///
  /// In en, this message translates to:
  /// **'Pending Email Verification. Please Check Verification Mail Sent To You!'**
  String get emailVerification;

  /// No description provided for @helloSignIn.
  ///
  /// In en, this message translates to:
  /// **'Hello \\nSign in !'**
  String get helloSignIn;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @chooseLang.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLang;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @passwordtooshort.
  ///
  /// In en, this message translates to:
  /// **'Password too short'**
  String get passwordtooshort;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pleaseenterfirstrname.
  ///
  /// In en, this message translates to:
  /// **'Please enter First Name'**
  String get pleaseenterfirstrname;

  /// No description provided for @pleaseenterlastrname.
  ///
  /// In en, this message translates to:
  /// **'Please enter Last Name'**
  String get pleaseenterlastrname;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @nofilechosen.
  ///
  /// In en, this message translates to:
  /// **'No file chosen'**
  String get nofilechosen;

  /// No description provided for @choosefile.
  ///
  /// In en, this message translates to:
  /// **'chosen file'**
  String get choosefile;

  /// No description provided for @allowedjpgandpng.
  ///
  /// In en, this message translates to:
  /// **'Allowed jpg and png'**
  String get allowedjpgandpng;

  /// No description provided for @pleasecheckyouremail.
  ///
  /// In en, this message translates to:
  /// **'Please check your email to change password !'**
  String get pleasecheckyouremail;

  /// No description provided for @starts.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get starts;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @ends.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get ends;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @viewtask.
  ///
  /// In en, this message translates to:
  /// **'View Task'**
  String get viewtask;

  /// No description provided for @darkmode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkmode;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @noclient.
  ///
  /// In en, this message translates to:
  /// **'no client'**
  String get noclient;

  /// No description provided for @selectstartenddate.
  ///
  /// In en, this message translates to:
  /// **'( Select start and end date from here )'**
  String get selectstartenddate;

  /// No description provided for @emailverified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get emailverified;

  /// No description provided for @addressinfo.
  ///
  /// In en, this message translates to:
  /// **'Address information'**
  String get addressinfo;

  /// No description provided for @pleasefilltherequiredfield.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the required fields (*)'**
  String get pleasefilltherequiredfield;

  /// No description provided for @pleasefilltime.
  ///
  /// In en, this message translates to:
  /// **'Please select time (*)'**
  String get pleasefilltime;

  /// No description provided for @registeredsuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Registered successfully!'**
  String get registeredsuccessfully;

  /// No description provided for @activityLog.
  ///
  /// In en, this message translates to:
  /// **'Activity log'**
  String get activityLog;

  /// No description provided for @pasconpassnotcorrect.
  ///
  /// In en, this message translates to:
  /// **'Password and confirm password do not match.'**
  String get pasconpassnotcorrect;

  /// No description provided for @entervalidemail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get entervalidemail;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete'**
  String get confirmDelete;

  /// No description provided for @forgetpassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgetpassword;

  /// No description provided for @nodata.
  ///
  /// In en, this message translates to:
  /// **'Sorry! No data!'**
  String get nodata;

  /// No description provided for @areyousure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get areyousure;

  /// No description provided for @areyousureyouwanttodeleteaccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?\nOnce deleted, you will not be able to recover it. Please consider carefully.'**
  String get areyousureyouwanttodeleteaccount;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deletedsuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully!'**
  String get deletedsuccessfully;

  /// No description provided for @pleaseenteravalidemail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseenteravalidemail;

  /// No description provided for @createdsuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Created successfully!'**
  String get createdsuccessfully;

  /// No description provided for @updatedsuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully!'**
  String get updatedsuccessfully;

  /// No description provided for @nochoosenfile.
  ///
  /// In en, this message translates to:
  /// **'No file chosen'**
  String get nochoosenfile;

  /// No description provided for @enterdate.
  ///
  /// In en, this message translates to:
  /// **'Enter date'**
  String get enterdate;

  /// No description provided for @signout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signout;

  /// No description provided for @noitems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get noitems;

  /// No description provided for @activitydetails.
  ///
  /// In en, this message translates to:
  /// **'Activity details'**
  String get activitydetails;

  /// No description provided for @emailpassreq.
  ///
  /// In en, this message translates to:
  /// **'Email and password required'**
  String get emailpassreq;

  /// No description provided for @successfullyloggedIn.
  ///
  /// In en, this message translates to:
  /// **'Successfully logged in!'**
  String get successfullyloggedIn;

  /// No description provided for @emailreq.
  ///
  /// In en, this message translates to:
  /// **'Email required'**
  String get emailreq;

  /// No description provided for @pasreq.
  ///
  /// In en, this message translates to:
  /// **'Password required'**
  String get pasreq;

  /// No description provided for @passworddomntmatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passworddomntmatch;

  /// No description provided for @asaclient.
  ///
  /// In en, this message translates to:
  /// **'As a client'**
  String get asaclient;

  /// No description provided for @asateammember.
  ///
  /// In en, this message translates to:
  /// **'As a team member'**
  String get asateammember;

  /// No description provided for @selectrole.
  ///
  /// In en, this message translates to:
  /// **'Select role'**
  String get selectrole;

  /// No description provided for @selectworkspace.
  ///
  /// In en, this message translates to:
  /// **'Select workspace'**
  String get selectworkspace;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @clientdetails.
  ///
  /// In en, this message translates to:
  /// **'Client details'**
  String get clientdetails;

  /// No description provided for @pleaseenteraddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter an address'**
  String get pleaseenteraddress;

  /// No description provided for @pleaseentercountry.
  ///
  /// In en, this message translates to:
  /// **'Please enter a country'**
  String get pleaseentercountry;

  /// No description provided for @pleaseenterphonenumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number'**
  String get pleaseenterphonenumber;

  /// No description provided for @pleaseenterzipcode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a ZIP code'**
  String get pleaseenterzipcode;

  /// No description provided for @pleaseenterstate.
  ///
  /// In en, this message translates to:
  /// **'Please enter a state'**
  String get pleaseenterstate;

  /// No description provided for @pleaseentercity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a city'**
  String get pleaseentercity;

  /// No description provided for @pleaseentercompanyname.
  ///
  /// In en, this message translates to:
  /// **'Please enter a company name'**
  String get pleaseentercompanyname;

  /// No description provided for @pleaseenterreason.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason'**
  String get pleaseenterreason;

  /// No description provided for @pleaseenterbudget.
  ///
  /// In en, this message translates to:
  /// **'Please enter a budget'**
  String get pleaseenterbudget;

  /// No description provided for @pleaseentertitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseentertitle;

  /// No description provided for @pleaseenternotes.
  ///
  /// In en, this message translates to:
  /// **'Please enter notes'**
  String get pleaseenternotes;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get evening;

  /// No description provided for @pleaseenterdescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get pleaseenterdescription;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @zipcode.
  ///
  /// In en, this message translates to:
  /// **'ZIP code'**
  String get zipcode;

  /// No description provided for @createclient.
  ///
  /// In en, this message translates to:
  /// **'Create client'**
  String get createclient;

  /// No description provided for @editclient.
  ///
  /// In en, this message translates to:
  /// **'Edit client'**
  String get editclient;

  /// No description provided for @phonenumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phonenumber;

  /// No description provided for @selectdate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectdate;

  /// No description provided for @editleaverequest.
  ///
  /// In en, this message translates to:
  /// **'Edit leave request'**
  String get editleaverequest;

  /// No description provided for @cretaeleaverequest.
  ///
  /// In en, this message translates to:
  /// **'Create leave request'**
  String get cretaeleaverequest;

  /// No description provided for @partialleave.
  ///
  /// In en, this message translates to:
  /// **'Partial leave'**
  String get partialleave;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @visibletoall.
  ///
  /// In en, this message translates to:
  /// **'Visible to all?'**
  String get visibletoall;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @fromtime.
  ///
  /// In en, this message translates to:
  /// **'From time'**
  String get fromtime;

  /// No description provided for @totime.
  ///
  /// In en, this message translates to:
  /// **'To time'**
  String get totime;

  /// No description provided for @projectdetails.
  ///
  /// In en, this message translates to:
  /// **'Project details'**
  String get projectdetails;

  /// No description provided for @duedate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get duedate;

  /// No description provided for @assignedto.
  ///
  /// In en, this message translates to:
  /// **'Assigned to'**
  String get assignedto;

  /// No description provided for @leaverequests.
  ///
  /// In en, this message translates to:
  /// **'Leave requests 💌'**
  String get leaverequests;

  /// No description provided for @leaverequestsDrawer.
  ///
  /// In en, this message translates to:
  /// **'Leave requests'**
  String get leaverequestsDrawer;

  /// No description provided for @fullday.
  ///
  /// In en, this message translates to:
  /// **'Full day'**
  String get fullday;

  /// No description provided for @createmeeting.
  ///
  /// In en, this message translates to:
  /// **'Create meeting'**
  String get createmeeting;

  /// No description provided for @editmeeting.
  ///
  /// In en, this message translates to:
  /// **'Edit meeting'**
  String get editmeeting;

  /// No description provided for @selectfilter.
  ///
  /// In en, this message translates to:
  /// **'Select filter'**
  String get selectfilter;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @allmeetings.
  ///
  /// In en, this message translates to:
  /// **'All meetings'**
  String get allmeetings;

  /// No description provided for @createdat.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get createdat;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @editnotes.
  ///
  /// In en, this message translates to:
  /// **'Edit notes'**
  String get editnotes;

  /// No description provided for @createnotes.
  ///
  /// In en, this message translates to:
  /// **'Create notes'**
  String get createnotes;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationdetail.
  ///
  /// In en, this message translates to:
  /// **'Notification detail'**
  String get notificationdetail;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @allnotifications.
  ///
  /// In en, this message translates to:
  /// **'All notifications'**
  String get allnotifications;

  /// No description provided for @slideforaction.
  ///
  /// In en, this message translates to:
  /// **'Slide for action'**
  String get slideforaction;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @editproject.
  ///
  /// In en, this message translates to:
  /// **'Edit project'**
  String get editproject;

  /// No description provided for @createproject.
  ///
  /// In en, this message translates to:
  /// **'Create project'**
  String get createproject;

  /// No description provided for @edittask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get edittask;

  /// No description provided for @createtask.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get createtask;

  /// No description provided for @alltasks.
  ///
  /// In en, this message translates to:
  /// **'All tasks'**
  String get alltasks;

  /// No description provided for @edittodo.
  ///
  /// In en, this message translates to:
  /// **'Edit to-do'**
  String get edittodo;

  /// No description provided for @edituser.
  ///
  /// In en, this message translates to:
  /// **'Edit user'**
  String get edituser;

  /// No description provided for @createuser.
  ///
  /// In en, this message translates to:
  /// **'Create user'**
  String get createuser;

  /// No description provided for @createtodo.
  ///
  /// In en, this message translates to:
  /// **'Create to-do'**
  String get createtodo;

  /// No description provided for @dateCreated.
  ///
  /// In en, this message translates to:
  /// **'Date created'**
  String get dateCreated;

  /// No description provided for @dob.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dob;

  /// No description provided for @doj.
  ///
  /// In en, this message translates to:
  /// **'Date of joining'**
  String get doj;

  /// No description provided for @requireemailveri.
  ///
  /// In en, this message translates to:
  /// **'Require email verification?'**
  String get requireemailveri;

  /// No description provided for @userdetails.
  ///
  /// In en, this message translates to:
  /// **'User details'**
  String get userdetails;

  /// No description provided for @dateofbirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateofbirth;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated at'**
  String get updatedAt;

  /// No description provided for @pleaseenterdateofbirth.
  ///
  /// In en, this message translates to:
  /// **'Please enter date of birth'**
  String get pleaseenterdateofbirth;

  /// No description provided for @pleaseenterdateofjoining.
  ///
  /// In en, this message translates to:
  /// **'Please enter date of joining'**
  String get pleaseenterdateofjoining;

  /// No description provided for @dateofjoining.
  ///
  /// In en, this message translates to:
  /// **'Date of joining'**
  String get dateofjoining;

  /// No description provided for @createworkspace.
  ///
  /// In en, this message translates to:
  /// **'Create workspace'**
  String get createworkspace;

  /// No description provided for @notificationclients.
  ///
  /// In en, this message translates to:
  /// **'Notification clients'**
  String get notificationclients;

  /// No description provided for @editworkspace.
  ///
  /// In en, this message translates to:
  /// **'Edit workspace'**
  String get editworkspace;

  /// No description provided for @primaryworkspcae.
  ///
  /// In en, this message translates to:
  /// **'Primary workspace?'**
  String get primaryworkspcae;

  /// No description provided for @defaultworkspcae.
  ///
  /// In en, this message translates to:
  /// **'Default workspace?'**
  String get defaultworkspcae;

  /// No description provided for @projectwithCounce.
  ///
  /// In en, this message translates to:
  /// **'Project(s)'**
  String get projectwithCounce;

  /// No description provided for @taskdetail.
  ///
  /// In en, this message translates to:
  /// **'Task detail'**
  String get taskdetail;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @selectuser.
  ///
  /// In en, this message translates to:
  /// **'Select user'**
  String get selectuser;

  /// No description provided for @selectclient.
  ///
  /// In en, this message translates to:
  /// **'Select client'**
  String get selectclient;

  /// No description provided for @selectDays.
  ///
  /// In en, this message translates to:
  /// **'Select days'**
  String get selectDays;

  /// No description provided for @manageworkspaces.
  ///
  /// In en, this message translates to:
  /// **'Manage workspaces'**
  String get manageworkspaces;

  /// No description provided for @createworkspaces.
  ///
  /// In en, this message translates to:
  /// **'Create workspaces'**
  String get createworkspaces;

  /// No description provided for @editworkspaces.
  ///
  /// In en, this message translates to:
  /// **'Edit workspaces'**
  String get editworkspaces;

  /// No description provided for @removemefromnworkspace.
  ///
  /// In en, this message translates to:
  /// **'Remove me from workspace'**
  String get removemefromnworkspace;

  /// No description provided for @meetings.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get meetings;

  /// No description provided for @deleteAcount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAcount;

  /// No description provided for @selectprojects.
  ///
  /// In en, this message translates to:
  /// **'Select projects'**
  String get selectprojects;

  /// No description provided for @unauthorised.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized!'**
  String get unauthorised;

  /// No description provided for @selectusers.
  ///
  /// In en, this message translates to:
  /// **'Select users'**
  String get selectusers;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @selectTags.
  ///
  /// In en, this message translates to:
  /// **'Select tags'**
  String get selectTags;

  /// No description provided for @selectAccess.
  ///
  /// In en, this message translates to:
  /// **'Select access'**
  String get selectAccess;

  /// No description provided for @taskaccessibility.
  ///
  /// In en, this message translates to:
  /// **'Task accessibility'**
  String get taskaccessibility;

  /// No description provided for @pleaseselect.
  ///
  /// In en, this message translates to:
  /// **'Please select'**
  String get pleaseselect;

  /// No description provided for @selectstatus.
  ///
  /// In en, this message translates to:
  /// **'Select Status'**
  String get selectstatus;

  /// No description provided for @selectpriority.
  ///
  /// In en, this message translates to:
  /// **'Select priority'**
  String get selectpriority;

  /// No description provided for @koio.
  ///
  /// In en, this message translates to:
  /// **'kmn'**
  String get koio;

  /// No description provided for @demo.
  ///
  /// In en, this message translates to:
  /// **'demo'**
  String get demo;

  /// No description provided for @birthdattoday.
  ///
  /// In en, this message translates to:
  /// **'BIRTHDAY '**
  String get birthdattoday;

  /// No description provided for @anniToday.
  ///
  /// In en, this message translates to:
  /// **'ANNIVERSARY'**
  String get anniToday;

  /// No description provided for @totalLeave.
  ///
  /// In en, this message translates to:
  /// **'Total Leave'**
  String get totalLeave;

  /// No description provided for @createstatus.
  ///
  /// In en, this message translates to:
  /// **'Create Status'**
  String get createstatus;

  /// No description provided for @editstatus.
  ///
  /// In en, this message translates to:
  /// **'Edit Status'**
  String get editstatus;

  /// No description provided for @rolesCanSettheStatus.
  ///
  /// In en, this message translates to:
  /// **'Roles Can Set the Status'**
  String get rolesCanSettheStatus;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @canclientdiscuss.
  ///
  /// In en, this message translates to:
  /// **'Can Client Discuss?'**
  String get canclientdiscuss;

  /// No description provided for @tasktimeentries.
  ///
  /// In en, this message translates to:
  /// **'TASK TIME ENTRIES'**
  String get tasktimeentries;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @favProject.
  ///
  /// In en, this message translates to:
  /// **'Favorite Projects'**
  String get favProject;

  /// No description provided for @milestone.
  ///
  /// In en, this message translates to:
  /// **'Milestone'**
  String get milestone;

  /// No description provided for @media.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get media;

  /// No description provided for @statustimeline.
  ///
  /// In en, this message translates to:
  /// **'Status Timeline'**
  String get statustimeline;

  /// No description provided for @projectdiscussion.
  ///
  /// In en, this message translates to:
  /// **'Project Discussion'**
  String get projectdiscussion;

  /// No description provided for @editmilestone.
  ///
  /// In en, this message translates to:
  /// **'Edit Milestone'**
  String get editmilestone;

  /// No description provided for @createmilestone.
  ///
  /// In en, this message translates to:
  /// **'Create Milestone'**
  String get createmilestone;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @pleaseentercost.
  ///
  /// In en, this message translates to:
  /// **'Please enter cost'**
  String get pleaseentercost;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'PROGRES'**
  String get progress;

  /// No description provided for @browsefile.
  ///
  /// In en, this message translates to:
  /// **'Browse File'**
  String get browsefile;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @chooseafileorclickbelow.
  ///
  /// In en, this message translates to:
  /// **'Click below to choose the file'**
  String get chooseafileorclickbelow;

  /// No description provided for @formatandsize.
  ///
  /// In en, this message translates to:
  /// **'pdf,doc,docx,png,jpg,xls,xlsx,zip,\nrar,txt formats, up to 1.95 GB \nMax files allowed: 10'**
  String get formatandsize;

  /// No description provided for @projectstats.
  ///
  /// In en, this message translates to:
  /// **'Project Statistics'**
  String get projectstats;

  /// No description provided for @taskectstats.
  ///
  /// In en, this message translates to:
  /// **'Task Statistics'**
  String get taskectstats;

  /// No description provided for @totdosstats.
  ///
  /// In en, this message translates to:
  /// **'Todos Statistics'**
  String get totdosstats;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @todosoverview.
  ///
  /// In en, this message translates to:
  /// **'Todos Overview'**
  String get todosoverview;

  /// No description provided for @appsettings.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get appsettings;

  /// No description provided for @entertitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter company title'**
  String get entertitle;

  /// No description provided for @companytitle.
  ///
  /// In en, this message translates to:
  /// **'COMPANY TITLE'**
  String get companytitle;

  /// No description provided for @siteurl.
  ///
  /// In en, this message translates to:
  /// **'SITE URL'**
  String get siteurl;

  /// No description provided for @site.
  ///
  /// In en, this message translates to:
  /// **'(Enter the site URL without a trailing slash, e.g., https://example.com)'**
  String get site;

  /// No description provided for @fulllogo.
  ///
  /// In en, this message translates to:
  /// **'FULL LOGO'**
  String get fulllogo;

  /// No description provided for @favicon.
  ///
  /// In en, this message translates to:
  /// **'FAVICON'**
  String get favicon;

  /// No description provided for @currencyfullform.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY FULL FORM'**
  String get currencyfullform;

  /// No description provided for @currencysymbol.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY SYMBOL'**
  String get currencysymbol;

  /// No description provided for @currencysymbolposition.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY SYMBOL POSITION'**
  String get currencysymbolposition;

  /// No description provided for @currencyformat.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY FORMAT'**
  String get currencyformat;

  /// No description provided for @systemtimezone.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM TIME ZONE'**
  String get systemtimezone;

  /// No description provided for @dateformat.
  ///
  /// In en, this message translates to:
  /// **'DATE FORMAT'**
  String get dateformat;

  /// No description provided for @timesystemwide.
  ///
  /// In en, this message translates to:
  /// **' (This Time Format Will Be Used SystemWide)'**
  String get timesystemwide;

  /// No description provided for @timeformat.
  ///
  /// In en, this message translates to:
  /// **'TIME FORMAT'**
  String get timeformat;

  /// No description provided for @datesystemwide.
  ///
  /// In en, this message translates to:
  /// **' (This Date Format Will  Be Used SystemWide)'**
  String get datesystemwide;

  /// No description provided for @upcomingbirthdaysection.
  ///
  /// In en, this message translates to:
  /// **'Upcoming birthdays section'**
  String get upcomingbirthdaysection;

  /// No description provided for @upcomingworkannisection.
  ///
  /// In en, this message translates to:
  /// **'Upcoming work anniversary section'**
  String get upcomingworkannisection;

  /// No description provided for @membersonleavesection.
  ///
  /// In en, this message translates to:
  /// **'Members on leave section'**
  String get membersonleavesection;

  /// No description provided for @uptodecimal.
  ///
  /// In en, this message translates to:
  /// **'DECIMAL POINTS IN CURRENCY'**
  String get uptodecimal;

  /// No description provided for @currencycode.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY CODE'**
  String get currencycode;

  /// No description provided for @commaseperated.
  ///
  /// In en, this message translates to:
  /// **'Comma Separated - 100,000'**
  String get commaseperated;

  /// No description provided for @dotseperated.
  ///
  /// In en, this message translates to:
  /// **'Dot Separated - 100.000'**
  String get dotseperated;

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'Before - '**
  String get before;

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'After - '**
  String get after;

  /// No description provided for @generalsetting.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalsetting;

  /// No description provided for @companyinformation.
  ///
  /// In en, this message translates to:
  /// **'Company Information'**
  String get companyinformation;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @comapnyinfo.
  ///
  /// In en, this message translates to:
  /// **'Company Information'**
  String get comapnyinfo;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @vatnumber.
  ///
  /// In en, this message translates to:
  /// **'VAT Number'**
  String get vatnumber;

  /// No description provided for @maxattemots.
  ///
  /// In en, this message translates to:
  /// **'Max Attempts'**
  String get maxattemots;

  /// No description provided for @setlimit.
  ///
  /// In en, this message translates to:
  /// **'(Fill in if you want to set a limit; otherwise, leave it blank)'**
  String get setlimit;

  /// No description provided for @locktime.
  ///
  /// In en, this message translates to:
  /// **'Lock Time (minutes)'**
  String get locktime;

  /// No description provided for @locttimesubtitle.
  ///
  /// In en, this message translates to:
  /// **'(This will not apply if Max Attempts is left blank)'**
  String get locttimesubtitle;

  /// No description provided for @maxupload.
  ///
  /// In en, this message translates to:
  /// **'Allowed Max Upload Size (MB) - Default: \n512'**
  String get maxupload;

  /// No description provided for @maxfilesallowed.
  ///
  /// In en, this message translates to:
  /// **'Max Files Allowed'**
  String get maxfilesallowed;

  /// No description provided for @allowedfiletypes.
  ///
  /// In en, this message translates to:
  /// **'Allowed File Types'**
  String get allowedfiletypes;

  /// No description provided for @enabledisablesignup.
  ///
  /// In en, this message translates to:
  /// **'Enable/Disable Signup'**
  String get enabledisablesignup;

  /// No description provided for @companyemail.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get companyemail;

  /// No description provided for @smtphost.
  ///
  /// In en, this message translates to:
  /// **'SMTP Host'**
  String get smtphost;

  /// No description provided for @smtpport.
  ///
  /// In en, this message translates to:
  /// **'SMTP Port'**
  String get smtpport;

  /// No description provided for @emailcontenttype.
  ///
  /// In en, this message translates to:
  /// **'Email Content Type'**
  String get emailcontenttype;

  /// No description provided for @smtpencryption.
  ///
  /// In en, this message translates to:
  /// **'SMTP Encryption'**
  String get smtpencryption;

  /// No description provided for @messagingintegration.
  ///
  /// In en, this message translates to:
  /// **'Messaging & Interation'**
  String get messagingintegration;

  /// No description provided for @smsgateway.
  ///
  /// In en, this message translates to:
  /// **'SMS Gateway'**
  String get smsgateway;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'Whatsapp'**
  String get whatsapp;

  /// No description provided for @slack.
  ///
  /// In en, this message translates to:
  /// **'Slack'**
  String get slack;

  /// No description provided for @baseurl.
  ///
  /// In en, this message translates to:
  /// **'Base Url'**
  String get baseurl;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @createauthorizationtoken.
  ///
  /// In en, this message translates to:
  /// **'Create Authorization Token'**
  String get createauthorizationtoken;

  /// No description provided for @accountsid.
  ///
  /// In en, this message translates to:
  /// **'Account SID'**
  String get accountsid;

  /// No description provided for @authtoken.
  ///
  /// In en, this message translates to:
  /// **'Auth Token'**
  String get authtoken;

  /// No description provided for @header.
  ///
  /// In en, this message translates to:
  /// **'Header'**
  String get header;

  /// No description provided for @body.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get body;

  /// No description provided for @params.
  ///
  /// In en, this message translates to:
  /// **'Params'**
  String get params;

  /// No description provided for @addheaderdata.
  ///
  /// In en, this message translates to:
  /// **'Add Header Data'**
  String get addheaderdata;

  /// No description provided for @key.
  ///
  /// In en, this message translates to:
  /// **'KEY'**
  String get key;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @availablplaceholder.
  ///
  /// In en, this message translates to:
  /// **'Available Placeholders'**
  String get availablplaceholder;

  /// No description provided for @authorization.
  ///
  /// In en, this message translates to:
  /// **'Authorization'**
  String get authorization;

  /// No description provided for @availableplaceholder.
  ///
  /// In en, this message translates to:
  /// **'Available Placeholders'**
  String get availableplaceholder;

  /// No description provided for @placeholder.
  ///
  /// In en, this message translates to:
  /// **'PLACEHOLDER'**
  String get placeholder;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'ACTION'**
  String get action;

  /// No description provided for @pleaseenterkeyvalue.
  ///
  /// In en, this message translates to:
  /// **'Please enter both key and value'**
  String get pleaseenterkeyvalue;

  /// No description provided for @pleaseprovidebothaccoundsidandauthtoken.
  ///
  /// In en, this message translates to:
  /// **'Please provide both Account SID and Auth Token'**
  String get pleaseprovidebothaccoundsidandauthtoken;

  /// No description provided for @textjson.
  ///
  /// In en, this message translates to:
  /// **'Text/JSON'**
  String get textjson;

  /// No description provided for @formdata.
  ///
  /// In en, this message translates to:
  /// **'FormData'**
  String get formdata;

  /// No description provided for @addbodydataparamvalue.
  ///
  /// In en, this message translates to:
  /// **'Add Body Data Parameters and Values'**
  String get addbodydataparamvalue;

  /// No description provided for @addparams.
  ///
  /// In en, this message translates to:
  /// **'Add Params'**
  String get addparams;

  /// No description provided for @whatsAppaccesstoken.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Access Token'**
  String get whatsAppaccesstoken;

  /// No description provided for @whatsAppphonenumberid.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Phone Number ID'**
  String get whatsAppphonenumberid;

  /// No description provided for @slackbottoken.
  ///
  /// In en, this message translates to:
  /// **'Slack bot token'**
  String get slackbottoken;

  /// No description provided for @mediastoragetype.
  ///
  /// In en, this message translates to:
  /// **'Media Storage Type'**
  String get mediastoragetype;

  /// No description provided for @mediastorage.
  ///
  /// In en, this message translates to:
  /// **'Media Storage'**
  String get mediastorage;

  /// No description provided for @selectmediastorage.
  ///
  /// In en, this message translates to:
  /// **'Select Media Storage'**
  String get selectmediastorage;

  /// No description provided for @selectall.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectall;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @expandall.
  ///
  /// In en, this message translates to:
  /// **'Expand all'**
  String get expandall;

  /// No description provided for @updatepermissions.
  ///
  /// In en, this message translates to:
  /// **'Update Permissions'**
  String get updatepermissions;

  /// No description provided for @favTask.
  ///
  /// In en, this message translates to:
  /// **'Favorite Task'**
  String get favTask;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @createpermissions.
  ///
  /// In en, this message translates to:
  /// **'Create Permissions'**
  String get createpermissions;

  /// No description provided for @pleaseentercompanytitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter Title'**
  String get pleaseentercompanytitle;

  /// No description provided for @pleaseentercompanysiteurl.
  ///
  /// In en, this message translates to:
  /// **'Please enter Site URL'**
  String get pleaseentercompanysiteurl;

  /// No description provided for @pleaseentercompanycurrencyfullform.
  ///
  /// In en, this message translates to:
  /// **'Please enter currency full form'**
  String get pleaseentercompanycurrencyfullform;

  /// No description provided for @pleaseentercompanycurrencysymbol.
  ///
  /// In en, this message translates to:
  /// **'Please enter Currency Symbol'**
  String get pleaseentercompanycurrencysymbol;

  /// No description provided for @pleaseentercompanycurrencycode.
  ///
  /// In en, this message translates to:
  /// **'Please enter Currency Code'**
  String get pleaseentercompanycurrencycode;

  /// No description provided for @pleaseentercompanycurrencysymbolpos.
  ///
  /// In en, this message translates to:
  /// **'Please enter Currency Symbol Position'**
  String get pleaseentercompanycurrencysymbolpos;

  /// No description provided for @pleaseenterdecimalpoints.
  ///
  /// In en, this message translates to:
  /// **'Please enter Decimal Points in Currency'**
  String get pleaseenterdecimalpoints;

  /// No description provided for @pleaseentercompanyemail.
  ///
  /// In en, this message translates to:
  /// **'Please enter Company Email'**
  String get pleaseentercompanyemail;

  /// No description provided for @pleaseentercompanyphone.
  ///
  /// In en, this message translates to:
  /// **'Please enter Company Phone Number'**
  String get pleaseentercompanyphone;

  /// No description provided for @pleaseentercompanyaddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter Company Address'**
  String get pleaseentercompanyaddress;

  /// No description provided for @pleaseentercompanycity.
  ///
  /// In en, this message translates to:
  /// **'Please enter Company City'**
  String get pleaseentercompanycity;

  /// No description provided for @pleaseentercompanystate.
  ///
  /// In en, this message translates to:
  /// **'Please enter Company State'**
  String get pleaseentercompanystate;

  /// No description provided for @pleaseentercompanycountry.
  ///
  /// In en, this message translates to:
  /// **'Please enter Company Country'**
  String get pleaseentercompanycountry;

  /// No description provided for @pleaseentercompanyzipcode.
  ///
  /// In en, this message translates to:
  /// **'Please enter Company Zipcode'**
  String get pleaseentercompanyzipcode;

  /// No description provided for @pleaseentercompanywebsite.
  ///
  /// In en, this message translates to:
  /// **'Please enter Company Website'**
  String get pleaseentercompanywebsite;

  /// No description provided for @pleaseentercompanyvatnumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter VAT Number'**
  String get pleaseentercompanyvatnumber;

  /// No description provided for @emaildoesntcontain.
  ///
  /// In en, this message translates to:
  /// **'Email does not contain @ '**
  String get emaildoesntcontain;

  /// No description provided for @pleasefilldetails.
  ///
  /// In en, this message translates to:
  /// **'Please fill the details'**
  String get pleasefilldetails;

  /// No description provided for @pleaseentermaxattempts.
  ///
  /// In en, this message translates to:
  /// **'Please enter Max Attempts'**
  String get pleaseentermaxattempts;

  /// No description provided for @pleaseenterlocktime.
  ///
  /// In en, this message translates to:
  /// **'Please enter Lock Time'**
  String get pleaseenterlocktime;

  /// No description provided for @pleaseenterallowedmaxuploadfiles.
  ///
  /// In en, this message translates to:
  /// **'Please enter Allowed Max Upload Files'**
  String get pleaseenterallowedmaxuploadfiles;

  /// No description provided for @pleaseentermaxfilesallowed.
  ///
  /// In en, this message translates to:
  /// **'Please enter Allowed Max Upload Files'**
  String get pleaseentermaxfilesallowed;

  /// No description provided for @pleaseenterallowedfiletype.
  ///
  /// In en, this message translates to:
  /// **'Please enter Allowed types'**
  String get pleaseenterallowedfiletype;

  /// No description provided for @pleaseentersmtpport.
  ///
  /// In en, this message translates to:
  /// **'Please enter SMTP Port'**
  String get pleaseentersmtpport;

  /// No description provided for @pleaseentersmtphost.
  ///
  /// In en, this message translates to:
  /// **'Please enter SMTP Host'**
  String get pleaseentersmtphost;

  /// No description provided for @pleaseenteremailcontenttype.
  ///
  /// In en, this message translates to:
  /// **'Please enter Email Content Type'**
  String get pleaseenteremailcontenttype;

  /// No description provided for @awsaccesskey.
  ///
  /// In en, this message translates to:
  /// **'AWS S3 Access Key'**
  String get awsaccesskey;

  /// No description provided for @awssecretkey.
  ///
  /// In en, this message translates to:
  /// **'AWS S3 Secret Key'**
  String get awssecretkey;

  /// No description provided for @awsregion.
  ///
  /// In en, this message translates to:
  /// **'AWS S3 Region'**
  String get awsregion;

  /// No description provided for @awsbucket.
  ///
  /// In en, this message translates to:
  /// **'AWS S3 Bucket'**
  String get awsbucket;

  /// No description provided for @pleaseenterawsaccesskey.
  ///
  /// In en, this message translates to:
  /// **'Please enter AWS S3 Access Key'**
  String get pleaseenterawsaccesskey;

  /// No description provided for @pleaseenterawssecretkey.
  ///
  /// In en, this message translates to:
  /// **'Please enter AWS S3 Secret Key'**
  String get pleaseenterawssecretkey;

  /// No description provided for @pleaseenterawsregion.
  ///
  /// In en, this message translates to:
  /// **'Please enter AWS S3 Region'**
  String get pleaseenterawsregion;

  /// No description provided for @pleaseenterawsbucket.
  ///
  /// In en, this message translates to:
  /// **'Please enter AWS S3 Bucket'**
  String get pleaseenterawsbucket;

  /// No description provided for @subtask.
  ///
  /// In en, this message translates to:
  /// **'Sub Task'**
  String get subtask;

  /// No description provided for @completionpercentage.
  ///
  /// In en, this message translates to:
  /// **'Completion Percentage (%)'**
  String get completionpercentage;

  /// No description provided for @enabletaskreminder.
  ///
  /// In en, this message translates to:
  /// **'Enable Task Reminder'**
  String get enabletaskreminder;

  /// No description provided for @enablerecurringtask.
  ///
  /// In en, this message translates to:
  /// **'Enable Recurring Task'**
  String get enablerecurringtask;

  /// No description provided for @enablereminder.
  ///
  /// In en, this message translates to:
  /// **'Enable Reminder'**
  String get enablereminder;

  /// No description provided for @billingtype.
  ///
  /// In en, this message translates to:
  /// **'Billing Type'**
  String get billingtype;

  /// No description provided for @dayofweek.
  ///
  /// In en, this message translates to:
  /// **'Day of the Week'**
  String get dayofweek;

  /// No description provided for @frequencttype.
  ///
  /// In en, this message translates to:
  /// **'Frequency Type'**
  String get frequencttype;

  /// No description provided for @timeofday.
  ///
  /// In en, this message translates to:
  /// **'Time of Day'**
  String get timeofday;

  /// No description provided for @recurrencefrequency.
  ///
  /// In en, this message translates to:
  /// **'Recurrence Frequency'**
  String get recurrencefrequency;

  /// No description provided for @dayofthemonth.
  ///
  /// In en, this message translates to:
  /// **'Day of the Month'**
  String get dayofthemonth;

  /// No description provided for @monthofyear.
  ///
  /// In en, this message translates to:
  /// **'Month of the Year'**
  String get monthofyear;

  /// No description provided for @startsfrom.
  ///
  /// In en, this message translates to:
  /// **'Starts From'**
  String get startsfrom;

  /// No description provided for @numberofoccurence.
  ///
  /// In en, this message translates to:
  /// **'Number of Occurrences'**
  String get numberofoccurence;

  /// No description provided for @remindersdetails.
  ///
  /// In en, this message translates to:
  /// **'Reminders Details'**
  String get remindersdetails;

  /// No description provided for @recurrencedetails.
  ///
  /// In en, this message translates to:
  /// **'Recurrence Details'**
  String get recurrencedetails;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @lastupdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastupdated;

  /// No description provided for @createdon.
  ///
  /// In en, this message translates to:
  /// **'Created On'**
  String get createdon;

  /// No description provided for @completedoccurrences.
  ///
  /// In en, this message translates to:
  /// **'Completed Occurrences'**
  String get completedoccurrences;

  /// No description provided for @numberofoccurrences.
  ///
  /// In en, this message translates to:
  /// **'Number of Occurrences'**
  String get numberofoccurrences;

  /// No description provided for @expensetype.
  ///
  /// In en, this message translates to:
  /// **'Expense Type'**
  String get expensetype;

  /// No description provided for @astimateinvoice.
  ///
  /// In en, this message translates to:
  /// **'Estimates/Invoices'**
  String get astimateinvoice;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get tax;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get unit;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @drawingnotes.
  ///
  /// In en, this message translates to:
  /// **'Drawing Notes'**
  String get drawingnotes;

  /// No description provided for @notetype.
  ///
  /// In en, this message translates to:
  /// **'Note Type'**
  String get notetype;

  /// No description provided for @mindmapview.
  ///
  /// In en, this message translates to:
  /// **'Mind Map View'**
  String get mindmapview;

  /// No description provided for @holidaycalendar.
  ///
  /// In en, this message translates to:
  /// **'Holiday Calendar'**
  String get holidaycalendar;

  /// No description provided for @publicholidays.
  ///
  /// In en, this message translates to:
  /// **'Public \nHolidays'**
  String get publicholidays;

  /// No description provided for @leaveaccepted.
  ///
  /// In en, this message translates to:
  /// **'Leave \nAccepted'**
  String get leaveaccepted;

  /// No description provided for @leavepending.
  ///
  /// In en, this message translates to:
  /// **'Leave \nPending'**
  String get leavepending;

  /// No description provided for @leaverejected.
  ///
  /// In en, this message translates to:
  /// **'Leave \nRejected'**
  String get leaverejected;

  /// No description provided for @biometricactive.
  ///
  /// In en, this message translates to:
  /// **'Biometric'**
  String get biometricactive;

  /// No description provided for @pleasefillfrequencyandtime.
  ///
  /// In en, this message translates to:
  /// **'Please fill the frequency and time of reminder'**
  String get pleasefillfrequencyandtime;

  /// No description provided for @pleasefillrecurringfields.
  ///
  /// In en, this message translates to:
  /// **'Please fill the recurring task fields'**
  String get pleasefillrecurringfields;

  /// No description provided for @createdby.
  ///
  /// In en, this message translates to:
  /// **'Created by '**
  String get createdby;

  /// No description provided for @createexpense.
  ///
  /// In en, this message translates to:
  /// **'Create Expense'**
  String get createexpense;

  /// No description provided for @editexpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editexpense;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @pleaseenteramount.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount'**
  String get pleaseenteramount;

  /// No description provided for @pleaseenterprice.
  ///
  /// In en, this message translates to:
  /// **'Please enter price'**
  String get pleaseenterprice;

  /// No description provided for @expenssedate.
  ///
  /// In en, this message translates to:
  /// **'Expense date'**
  String get expenssedate;

  /// No description provided for @selectExpenseType.
  ///
  /// In en, this message translates to:
  /// **'Select Expense Type'**
  String get selectExpenseType;

  /// No description provided for @editItems.
  ///
  /// In en, this message translates to:
  /// **'Edit Items'**
  String get editItems;

  /// No description provided for @createItems.
  ///
  /// In en, this message translates to:
  /// **'Create items'**
  String get createItems;

  /// No description provided for @edittax.
  ///
  /// In en, this message translates to:
  /// **'Edit Tax'**
  String get edittax;

  /// No description provided for @createtax.
  ///
  /// In en, this message translates to:
  /// **'Create Tax'**
  String get createtax;

  /// No description provided for @editunits.
  ///
  /// In en, this message translates to:
  /// **'Edit Units'**
  String get editunits;

  /// No description provided for @createunits.
  ///
  /// In en, this message translates to:
  /// **'Create Units'**
  String get createunits;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @percntage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percntage;

  /// No description provided for @editpaymentmethod.
  ///
  /// In en, this message translates to:
  /// **'Edit Payment Method'**
  String get editpaymentmethod;

  /// No description provided for @createpaymentmethod.
  ///
  /// In en, this message translates to:
  /// **'Create Payment Method'**
  String get createpaymentmethod;

  /// No description provided for @editestimateinvoice.
  ///
  /// In en, this message translates to:
  /// **'Edit Estimate/Invoice'**
  String get editestimateinvoice;

  /// No description provided for @createestimateinvoice.
  ///
  /// In en, this message translates to:
  /// **'Create Estimate/Invoice'**
  String get createestimateinvoice;

  /// No description provided for @editpayment.
  ///
  /// In en, this message translates to:
  /// **'Edit Payment'**
  String get editpayment;

  /// No description provided for @createpayment.
  ///
  /// In en, this message translates to:
  /// **'Create Payment'**
  String get createpayment;

  /// No description provided for @paymentdate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentdate;

  /// No description provided for @selectpayments.
  ///
  /// In en, this message translates to:
  /// **'Select Payment'**
  String get selectpayments;

  /// No description provided for @selectinvoice.
  ///
  /// In en, this message translates to:
  /// **'Select Invoice'**
  String get selectinvoice;

  /// No description provided for @selecttax.
  ///
  /// In en, this message translates to:
  /// **'Select Tax'**
  String get selecttax;

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// No description provided for @estinateinvoices.
  ///
  /// In en, this message translates to:
  /// **'Estimates/Invoices'**
  String get estinateinvoices;

  /// No description provided for @enterpersonalnote.
  ///
  /// In en, this message translates to:
  /// **'Enter personal note'**
  String get enterpersonalnote;

  /// No description provided for @personalnote.
  ///
  /// In en, this message translates to:
  /// **'Personal note'**
  String get personalnote;

  /// No description provided for @updatebillingdetails.
  ///
  /// In en, this message translates to:
  /// **'Update Billing Details'**
  String get updatebillingdetails;

  /// No description provided for @pleaseentername.
  ///
  /// In en, this message translates to:
  /// **'Please enter name'**
  String get pleaseentername;

  /// No description provided for @pleaseentercontact.
  ///
  /// In en, this message translates to:
  /// **'Please enter contact'**
  String get pleaseentercontact;

  /// No description provided for @pleaseenterrate.
  ///
  /// In en, this message translates to:
  /// **'Please enter rate'**
  String get pleaseenterrate;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @selectitem.
  ///
  /// In en, this message translates to:
  /// **'Select Items'**
  String get selectitem;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @itemalreadyadded.
  ///
  /// In en, this message translates to:
  /// **'Item already added'**
  String get itemalreadyadded;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Sub Total'**
  String get subtotal;

  /// No description provided for @finaltotal.
  ///
  /// In en, this message translates to:
  /// **'Final Total'**
  String get finaltotal;

  /// No description provided for @updateitem.
  ///
  /// In en, this message translates to:
  /// **'Update Item'**
  String get updateitem;

  /// No description provided for @pleaseaddatleastoneitem.
  ///
  /// In en, this message translates to:
  /// **'Please add atlead one item'**
  String get pleaseaddatleastoneitem;

  /// No description provided for @leadsmanagement.
  ///
  /// In en, this message translates to:
  /// **'Leads Management'**
  String get leadsmanagement;

  /// No description provided for @leadsource.
  ///
  /// In en, this message translates to:
  /// **'Lead Source'**
  String get leadsource;

  /// No description provided for @createlead.
  ///
  /// In en, this message translates to:
  /// **'Create Lead'**
  String get createlead;

  /// No description provided for @editlead.
  ///
  /// In en, this message translates to:
  /// **'Edit Lead'**
  String get editlead;

  /// No description provided for @hrms.
  ///
  /// In en, this message translates to:
  /// **'HRMS'**
  String get hrms;

  /// No description provided for @candidates.
  ///
  /// In en, this message translates to:
  /// **'Candidates'**
  String get candidates;

  /// No description provided for @candidatestatus.
  ///
  /// In en, this message translates to:
  /// **'Candidate Status'**
  String get candidatestatus;

  /// No description provided for @interviews.
  ///
  /// In en, this message translates to:
  /// **'Interviews'**
  String get interviews;

  /// No description provided for @fullname.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullname;

  /// No description provided for @pleaseenterfullname.
  ///
  /// In en, this message translates to:
  /// **'Please enter full name'**
  String get pleaseenterfullname;

  /// No description provided for @pleaseenterround.
  ///
  /// In en, this message translates to:
  /// **'e.g. Technical,HR etc'**
  String get pleaseenterround;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachment;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get optional;

  /// No description provided for @acceptedfile.
  ///
  /// In en, this message translates to:
  /// **'Accepted file types: pdf, doc, docx, jpg, png'**
  String get acceptedfile;

  /// No description provided for @addnewcandidate.
  ///
  /// In en, this message translates to:
  /// **'Add New Candidate'**
  String get addnewcandidate;

  /// No description provided for @updatecandidate.
  ///
  /// In en, this message translates to:
  /// **'Update Candidate'**
  String get updatecandidate;

  /// No description provided for @formatfile.
  ///
  /// In en, this message translates to:
  /// **'pdf,doc,png,jpg,jpeg(Max size: 524288KB)'**
  String get formatfile;

  /// No description provided for @createcandidatestatus.
  ///
  /// In en, this message translates to:
  /// **'Create Candidate Status'**
  String get createcandidatestatus;

  /// No description provided for @editcandidatestatus.
  ///
  /// In en, this message translates to:
  /// **'Edit Candidate Status'**
  String get editcandidatestatus;

  /// No description provided for @selectcandidatestatus.
  ///
  /// In en, this message translates to:
  /// **'Select Candidate Status'**
  String get selectcandidatestatus;

  /// No description provided for @round.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get round;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @interviewer.
  ///
  /// In en, this message translates to:
  /// **'Interviewer'**
  String get interviewer;

  /// No description provided for @createinterview.
  ///
  /// In en, this message translates to:
  /// **'Create Interview'**
  String get createinterview;

  /// No description provided for @updateinterview.
  ///
  /// In en, this message translates to:
  /// **'Update Interview'**
  String get updateinterview;

  /// No description provided for @candidate.
  ///
  /// In en, this message translates to:
  /// **'Candidate'**
  String get candidate;

  /// No description provided for @candidatedetail.
  ///
  /// In en, this message translates to:
  /// **'Candidate Details'**
  String get candidatedetail;

  /// No description provided for @leadstages.
  ///
  /// In en, this message translates to:
  /// **'Lead Stages'**
  String get leadstages;

  /// No description provided for @leads.
  ///
  /// In en, this message translates to:
  /// **'Leads'**
  String get leads;

  /// No description provided for @bulkuploads.
  ///
  /// In en, this message translates to:
  /// **'Bulk Uploads'**
  String get bulkuploads;

  /// No description provided for @personaldetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personaldetails;

  /// No description provided for @professiondetails.
  ///
  /// In en, this message translates to:
  /// **'Professional Details'**
  String get professiondetails;

  /// No description provided for @jobtitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobtitle;

  /// No description provided for @industry.
  ///
  /// In en, this message translates to:
  /// **'Industry'**
  String get industry;

  /// No description provided for @linkedin.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get linkedin;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @pinterest.
  ///
  /// In en, this message translates to:
  /// **'Pinterest'**
  String get pinterest;

  /// No description provided for @sociallinks.
  ///
  /// In en, this message translates to:
  /// **'Social Links'**
  String get sociallinks;

  /// No description provided for @selectleads.
  ///
  /// In en, this message translates to:
  /// **'Select Leads'**
  String get selectleads;

  /// No description provided for @assignto.
  ///
  /// In en, this message translates to:
  /// **'Assign to'**
  String get assignto;

  /// No description provided for @customfields.
  ///
  /// In en, this message translates to:
  /// **'Custom Fields'**
  String get customfields;

  /// No description provided for @fieldlabel.
  ///
  /// In en, this message translates to:
  /// **'Field Label'**
  String get fieldlabel;

  /// No description provided for @fieldtype.
  ///
  /// In en, this message translates to:
  /// **'Field Type'**
  String get fieldtype;

  /// No description provided for @module.
  ///
  /// In en, this message translates to:
  /// **'Module'**
  String get module;

  /// No description provided for @isrequired.
  ///
  /// In en, this message translates to:
  /// **'IS REQUIRED'**
  String get isrequired;

  /// No description provided for @showintableview.
  ///
  /// In en, this message translates to:
  /// **'SHOW IN TABLE VIEW'**
  String get showintableview;

  /// No description provided for @createcustomfield.
  ///
  /// In en, this message translates to:
  /// **'Create Custom Field'**
  String get createcustomfield;

  /// No description provided for @editcustomfield.
  ///
  /// In en, this message translates to:
  /// **'Edit Custom Field'**
  String get editcustomfield;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'options'**
  String get options;

  /// No description provided for @addoptions.
  ///
  /// In en, this message translates to:
  /// **'Add Option'**
  String get addoptions;

  /// No description provided for @enter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enter;

  /// No description provided for @createtag.
  ///
  /// In en, this message translates to:
  /// **'Create tag'**
  String get createtag;

  /// No description provided for @edittag.
  ///
  /// In en, this message translates to:
  /// **'Edit tag'**
  String get edittag;

  /// No description provided for @createcontract.
  ///
  /// In en, this message translates to:
  /// **'Create Contract'**
  String get createcontract;

  /// No description provided for @editcontract.
  ///
  /// In en, this message translates to:
  /// **'Edit contract'**
  String get editcontract;

  /// No description provided for @managecontract.
  ///
  /// In en, this message translates to:
  /// **'Manage Contracts'**
  String get managecontract;

  /// No description provided for @contracttype.
  ///
  /// In en, this message translates to:
  /// **'Contract Types'**
  String get contracttype;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @enddate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get enddate;

  /// No description provided for @promisorsign.
  ///
  /// In en, this message translates to:
  /// **'Promisor Sign'**
  String get promisorsign;

  /// No description provided for @promiseesign.
  ///
  /// In en, this message translates to:
  /// **'Promisee Sign'**
  String get promiseesign;

  /// No description provided for @notsigned.
  ///
  /// In en, this message translates to:
  /// **'Not Signed'**
  String get notsigned;

  /// No description provided for @leaddetails.
  ///
  /// In en, this message translates to:
  /// **'Lead Details'**
  String get leaddetails;

  /// No description provided for @leadstage.
  ///
  /// In en, this message translates to:
  /// **'Lead Stage'**
  String get leadstage;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @selectcontracttype.
  ///
  /// In en, this message translates to:
  /// **'Select Contract Type'**
  String get selectcontracttype;

  /// No description provided for @startsat.
  ///
  /// In en, this message translates to:
  /// **'Starts At'**
  String get startsat;

  /// No description provided for @endsat.
  ///
  /// In en, this message translates to:
  /// **'Ends At'**
  String get endsat;

  /// No description provided for @contractpdf.
  ///
  /// In en, this message translates to:
  /// **'Contract PDF'**
  String get contractpdf;

  /// No description provided for @leaveitblankifnochange.
  ///
  /// In en, this message translates to:
  /// **'(Leave it blank if no change)'**
  String get leaveitblankifnochange;

  /// No description provided for @updatecontract.
  ///
  /// In en, this message translates to:
  /// **'Update Contract'**
  String get updatecontract;

  /// No description provided for @createleadfollowups.
  ///
  /// In en, this message translates to:
  /// **'Create Lead Follow Up'**
  String get createleadfollowups;

  /// No description provided for @updateleadfollowups.
  ///
  /// In en, this message translates to:
  /// **'Update Lead Follow Up'**
  String get updateleadfollowups;

  /// No description provided for @contractdetail.
  ///
  /// In en, this message translates to:
  /// **'Contract Details'**
  String get contractdetail;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @followups.
  ///
  /// In en, this message translates to:
  /// **'Follow Ups'**
  String get followups;

  /// No description provided for @contactinfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactinfo;

  /// No description provided for @companyinfo.
  ///
  /// In en, this message translates to:
  /// **'Company Information'**
  String get companyinfo;

  /// No description provided for @followupon.
  ///
  /// In en, this message translates to:
  /// **'FOLLOW-UP ON :'**
  String get followupon;

  /// No description provided for @followupdate.
  ///
  /// In en, this message translates to:
  /// **'Follow up date'**
  String get followupdate;

  /// No description provided for @followupdatedetail.
  ///
  /// In en, this message translates to:
  /// **'This date will help you record when the follow-up is taken.'**
  String get followupdatedetail;

  /// No description provided for @followupdatedetailcategories.
  ///
  /// In en, this message translates to:
  /// **'Categorize the follow-up, for example: call, email, etc.'**
  String get followupdatedetailcategories;

  /// No description provided for @notesdetail.
  ///
  /// In en, this message translates to:
  /// **'Add any notes that you want to keep for this follow-up.'**
  String get notesdetail;

  /// No description provided for @followupType.
  ///
  /// In en, this message translates to:
  /// **'Follow Up Type'**
  String get followupType;

  /// No description provided for @createallowances.
  ///
  /// In en, this message translates to:
  /// **'Create Allowance'**
  String get createallowances;

  /// No description provided for @editallowances.
  ///
  /// In en, this message translates to:
  /// **'Edit Allowance'**
  String get editallowances;

  /// No description provided for @managepayslip.
  ///
  /// In en, this message translates to:
  /// **'Manage Payslip'**
  String get managepayslip;

  /// No description provided for @editdeduction.
  ///
  /// In en, this message translates to:
  /// **'Edit Deduction'**
  String get editdeduction;

  /// No description provided for @creatededuction.
  ///
  /// In en, this message translates to:
  /// **'Create Deduction'**
  String get creatededuction;

  /// No description provided for @payslip.
  ///
  /// In en, this message translates to:
  /// **'Payslips'**
  String get payslip;

  /// No description provided for @basicsalary.
  ///
  /// In en, this message translates to:
  /// **'Basic Salary'**
  String get basicsalary;

  /// No description provided for @netpay.
  ///
  /// In en, this message translates to:
  /// **'Net Pay'**
  String get netpay;

  /// No description provided for @payslipmonth.
  ///
  /// In en, this message translates to:
  /// **'Payslip Month'**
  String get payslipmonth;

  /// No description provided for @selectyear.
  ///
  /// In en, this message translates to:
  /// **'Select Month & Year'**
  String get selectyear;

  /// No description provided for @workingdays.
  ///
  /// In en, this message translates to:
  /// **'Working Days'**
  String get workingdays;

  /// No description provided for @lossofpaydays.
  ///
  /// In en, this message translates to:
  /// **'Loss of pay days'**
  String get lossofpaydays;

  /// No description provided for @paiddays.
  ///
  /// In en, this message translates to:
  /// **'Paid Days'**
  String get paiddays;

  /// No description provided for @bonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get bonus;

  /// No description provided for @incentives.
  ///
  /// In en, this message translates to:
  /// **'Incentives'**
  String get incentives;

  /// No description provided for @leavededuction.
  ///
  /// In en, this message translates to:
  /// **'Leave Deduction'**
  String get leavededuction;

  /// No description provided for @overtimehours.
  ///
  /// In en, this message translates to:
  /// **'Over Time Hours'**
  String get overtimehours;

  /// No description provided for @overtimerate.
  ///
  /// In en, this message translates to:
  /// **'Over Time Rate'**
  String get overtimerate;

  /// No description provided for @overtimepayment.
  ///
  /// In en, this message translates to:
  /// **'Over Time Payment'**
  String get overtimepayment;

  /// No description provided for @paymentstatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentstatus;

  /// No description provided for @allowance.
  ///
  /// In en, this message translates to:
  /// **'Allowance'**
  String get allowance;

  /// No description provided for @totalallowances.
  ///
  /// In en, this message translates to:
  /// **'Total Allowances'**
  String get totalallowances;

  /// No description provided for @totaldeductions.
  ///
  /// In en, this message translates to:
  /// **'Total Deductions'**
  String get totaldeductions;

  /// No description provided for @totalallowancedeductions.
  ///
  /// In en, this message translates to:
  /// **'Total Allowances and Deduction'**
  String get totalallowancedeductions;

  /// No description provided for @netpayable.
  ///
  /// In en, this message translates to:
  /// **'Payable'**
  String get netpayable;

  /// No description provided for @selectallownances.
  ///
  /// In en, this message translates to:
  /// **'Select Allowance'**
  String get selectallownances;

  /// No description provided for @selectdeduction.
  ///
  /// In en, this message translates to:
  /// **'Select Deduction'**
  String get selectdeduction;

  /// No description provided for @payslipdetail.
  ///
  /// In en, this message translates to:
  /// **'Payslip Detail'**
  String get payslipdetail;

  /// No description provided for @updatedafterbonusrevisions.
  ///
  /// In en, this message translates to:
  /// **'Updated after bonus revision'**
  String get updatedafterbonusrevisions;

  /// No description provided for @editpayslip.
  ///
  /// In en, this message translates to:
  /// **'Edit Payslip'**
  String get editpayslip;

  /// No description provided for @createpayslip.
  ///
  /// In en, this message translates to:
  /// **'Create payslip'**
  String get createpayslip;

  /// No description provided for @pleasefillpaymentdateandpaymentmethod.
  ///
  /// In en, this message translates to:
  /// **'Please fill payment date and payment method'**
  String get pleasefillpaymentdateandpaymentmethod;

  /// No description provided for @selectleadource.
  ///
  /// In en, this message translates to:
  /// **'Select Leads Source'**
  String get selectleadource;

  /// No description provided for @selectleadstage.
  ///
  /// In en, this message translates to:
  /// **'Select Lead Stage'**
  String get selectleadstage;

  /// No description provided for @createpriorities.
  ///
  /// In en, this message translates to:
  /// **'Create Priority'**
  String get createpriorities;

  /// No description provided for @editpriorities.
  ///
  /// In en, this message translates to:
  /// **'Edit Priority'**
  String get editpriorities;

  /// No description provided for @negativeValueNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Negative Value is not allowed'**
  String get negativeValueNotAllowed;

  /// No description provided for @invalidNumberFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid number format'**
  String get invalidNumberFormat;

  /// No description provided for @incomevsexpense.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expense'**
  String get incomevsexpense;

  /// No description provided for @commaNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Comma is not allowed'**
  String get commaNotAllowed;

  /// No description provided for @startsandends.
  ///
  /// In en, this message translates to:
  /// **'Start and End Date'**
  String get startsandends;

  /// No description provided for @discussion.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get discussion;

  /// No description provided for @commentdeletedsuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Comment deleted successfully'**
  String get commentdeletedsuccessfully;

  /// No description provided for @failedtoaddorupdatecomment.
  ///
  /// In en, this message translates to:
  /// **'Failed to add or update comment'**
  String get failedtoaddorupdatecomment;

  /// No description provided for @chatisempty.
  ///
  /// In en, this message translates to:
  /// **'Chat is Empty'**
  String get chatisempty;

  /// No description provided for @betheonetobreaktheice.
  ///
  /// In en, this message translates to:
  /// **'Be the one to break the ice..'**
  String get betheonetobreaktheice;

  /// No description provided for @areyousurewanttodeletethiscomment.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment?'**
  String get areyousurewanttodeletethiscomment;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @hidereplies.
  ///
  /// In en, this message translates to:
  /// **'Hide replies'**
  String get hidereplies;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @morereplies.
  ///
  /// In en, this message translates to:
  /// **'more replies'**
  String get morereplies;

  /// No description provided for @commentcannotbeempty.
  ///
  /// In en, this message translates to:
  /// **'Comment cannot be empty'**
  String get commentcannotbeempty;

  /// No description provided for @replyingto.
  ///
  /// In en, this message translates to:
  /// **'Replying to'**
  String get replyingto;

  /// No description provided for @areyousureyouwanttodeletethisimage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this image?'**
  String get areyousureyouwanttodeletethisimage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'en',
        'hi',
        'ko',
        'pt',
        'vi'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
