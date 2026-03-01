import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/permissions/permissions_event.dart';
import 'package:taskify/bloc/setting/settings_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/no_permission_screen.dart';
import 'package:taskify/utils/widgets/shake_widget.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../bloc/estimate_invoice/estimateInvoice_bloc.dart';
import '../../../bloc/estimate_invoice/estimateInvoice_event.dart';
import '../../../bloc/estimate_invoice/estimateInvoice_state.dart';
import '../../../bloc/payment/payment_state.dart';
import '../../../bloc/payment/payment_event.dart';
import '../../../bloc/payment/payment_bloc.dart';
import '../../../bloc/payment_filter/payment_filter_bloc.dart';
import '../../../bloc/payment_filter/payment_filter_event.dart';
import '../../../bloc/payment_filter/payment_filter_state.dart';
import '../../../bloc/payment_method/payment_method_bloc.dart';
import '../../../bloc/payment_method/payment_method_event.dart';
import '../../../bloc/payment_method/payment_method_state.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/user/user_bloc.dart';
import '../../../bloc/user/user_event.dart';
import '../../../bloc/user/user_state.dart';
import '../../../config/app_images.dart';
import '../../../config/constants.dart';
import '../../../data/localStorage/hive.dart';
import '../../../data/model/finance/payment_model.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/custom_dimissible.dart';
import '../../../utils/widgets/custom_text.dart';
import 'package:heroicons/heroicons.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../../config/internet_connectivity.dart';
import '../../../utils/widgets/circularprogress_indicator.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../../utils/widgets/search_pop_up.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';
import '../../widgets/custom_date.dart';
import '../../widgets/no_data.dart';
import '../../widgets/search_field.dart';
import '../../widgets/side_bar.dart';
import '../../widgets/speech_to_text.dart';
import '../../../../src/generated/i18n/app_localizations.dart';

class PaymentScreen extends StatefulWidget {
  final bool? fromNoti;
  const PaymentScreen({super.key, this.fromNoti});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  TextEditingController searchController = TextEditingController();
  String searchWord = "";
  bool shouldDisableEdit = true;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  bool isListening =
      false; // Flag to track if speech recognition is in progress
  bool dialogShown = false;

  double level = 0.0;
  String? fromDate;
  String? toDate;
  List<String> paymentsname = [];
  String? name;
  List<int> paymentsId = [];
  final List<String> filter = ['Users', 'Invoice', 'Payment Method', 'Date'];
  TextEditingController startsController = TextEditingController();
  TextEditingController endController = TextEditingController();

  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _invoiceSearchController =
      TextEditingController();
  final TextEditingController _paymentMethodSearchController =
      TextEditingController();
  final ValueNotifier<String> filterNameNotifier =
      ValueNotifier<String>('Users'); // Initialize with default value

  String filterName = 'Users';
  List<int> userSelectedId = [];
  List<int> userSelectedIdS = [];
  int filterSelectedId = 0;
  String filterSelectedName = "";
  bool? userDisSelected = false;
  bool? userSelected = false;
  bool? invoiceDisSelected = false;
  bool? invoiceSelected = false;
  bool? paymentDisSelected = false;
  bool? payentSelected = false;

  List<String> userSelectedname = [];
  List<int> invoicesIdFilter = [];
  List<String> invoicesnameFilter = [];
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late SpeechToTextHelper speechHelper;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  bool isLoadingMore = false;
  String currency = "";
  DateTime selectedDateStarts = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);

  @override
  void dispose() {
    // Add this cleanup
    if (mounted) {
      context.read<PaymentFilterCountBloc>().add(PaymentResetFilterCount());
    }

    _connectivitySubscription.cancel();
    super.dispose();
  }
  @override
  void initState() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          final filterState = context.read<PaymentFilterCountBloc>().state;

          // Optionally trigger the search event with an empty string
          context.read<PaymentBloc>().add(SearchPayments(
              searchQuery: result,
              userIds: filterState.selectedUserIds,
              invoiceIds: filterState.selectedInvoiceIds,
              paymentMethodIds: filterState.selectedPaymentMethodIds,
              fromDate: filterState.fromDate,
              toDate: filterState.toDate));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentFilterCountBloc>().add(PaymentResetFilterCount());
      context.read<PaymentBloc>().add(PaymentLists(
          userIds: [],
          invoiceIds: [],
          paymentMethodIds: [],
          fromDate: '',
          toDate: ''));
      context.read<PermissionsBloc>().add(GetPermissions());
      currency = context.read<SettingsBloc>().currencySymbol!;
    });
  }

  bool? isLoading = true;
  void onDeletePayment(int Payment) {
    context.read<PaymentBloc>().add(DeletePayments(Payment));
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<PaymentBloc>(context).add(PaymentLists(
        userIds: [],
        invoiceIds: [],
        paymentMethodIds: [],
        fromDate: '',
        toDate: ''));

    setState(() {
      isLoading = false;
    });
  }

  String convertTo12HourFormat(String timeString) {
    // Parse the string to a DateTime object
    DateTime dateTime = DateFormat("HH:mm:ss").parse(timeString);

    // Format the DateTime object to 12-hour format
    String formattedTime = DateFormat("h a").format(dateTime);

    return formattedTime;
  }

  Future<void> _launchUrl(url) async {
    var token = await HiveStorage.getToken();
    if (!await launchUrl(Uri.parse("$url?token=$token"),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // context.read<PermissionsBloc>().iscreatePayment;
    // context.read<PermissionsBloc>().iseditPayment;
    // context.read<PermissionsBloc>().isdeletePayment;

    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;

    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : PopScope(
            canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop && mounted) {
          context.read<PaymentFilterCountBloc>().add(PaymentResetFilterCount());
          router.pop();
        }
      },
            child: Scaffold(
                backgroundColor: Theme.of(context).colorScheme.backGroundColor,
                body: SideBar(
                  context: context,
                  controller: sideBarController,
                  underWidget: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: BackArrow(
                          onTap: () {
                            if (mounted) {
                              context
                                  .read<PaymentFilterCountBloc>()
                                  .add(PaymentResetFilterCount());
                            }
                            router.pop();
                          },
                          iscreatePermission:
                              context.read<PermissionsBloc>().iscreatePayment,
                          isFromNotification: widget.fromNoti,
                          fromNoti: "Payment",
                          iSBackArrow: true,
                          title: AppLocalizations.of(context)!.payments,
                          isAdd:
                              context.read<PermissionsBloc>().iscreatePayment,
                          onPress: () {
                            UserPayment userModel = UserPayment(
                                id: 0,
                                email: "",
                                photo: "",
                                firstName: "",
                                lastName: "");
                            PaymentModel model = PaymentModel(
                                id: 0,
                                userId: 0,
                                user: userModel,
                                amount: "",
                                note: "");
                            router.push(
                              '/createupdatepayment',
                              extra: {'isCreate': true, "paymentModel": model},
                            );

                            // createEditNotes(isLightTheme: isLightTheme, isCreate: true);
                          },
                        ),
                      ),
                      SizedBox(height: 20.h),
                      CustomSearchField(
                        isLightTheme: isLightTheme,
                        controller: searchController,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (searchController.text.isNotEmpty)
                              SizedBox(
                                width: 20.w,
                                // color: AppColors.red,
                                child: IconButton(
                                  highlightColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.clear,
                                    size: 20.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textFieldColor,
                                  ),
                                  onPressed: () {
                                    // Clear the search field
                                    setState(() {
                                      searchController.clear();
                                    });
                                    final filterState = context
                                        .read<PaymentFilterCountBloc>()
                                        .state;

                                    // Optionally trigger the search event with an empty string
                                    context.read<PaymentBloc>().add(
                                        SearchPayments(
                                            searchQuery: "",
                                            userIds:
                                                filterState.selectedUserIds,
                                            invoiceIds:
                                                filterState.selectedInvoiceIds,
                                            paymentMethodIds: filterState
                                                .selectedPaymentMethodIds,
                                            fromDate: filterState.fromDate,
                                            toDate: filterState.toDate));
                                    // Optionally trigger the search event with an empty string
                                  },
                                ),
                              ),
                            IconButton(
                              icon: Icon(
                                !speechHelper.isListening
                                    ? Icons.mic_off
                                    : Icons.mic,
                                size: 20.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .textFieldColor,
                              ),
                              onPressed: () {
                                if (speechHelper.isListening) {
                                  speechHelper.stopListening();
                                } else {
                                  speechHelper.startListening(
                                      context, searchController, SearchPopUp());
                                }
                              },
                            ),
                            BlocBuilder<PaymentFilterCountBloc,
                                PaymentFilterCountState>(
                              builder: (context, state) {
                                return SizedBox(
                                  width: 35.w,
                                  child: Stack(
                                    children: [
                                      IconButton(
                                        icon: HeroIcon(
                                          HeroIcons.adjustmentsHorizontal,
                                          style: HeroIconStyle.solid,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .textFieldColor,
                                          size: 30.sp,
                                        ),
                                        onPressed: () {
                                          print("fkdFLKJk  ${state.count}");

                                          // Your existing filter dialog logic
                                          _filterDialog(context, isLightTheme);
                                        },
                                      ),
                                      if (state.count > 0)
                                        Positioned(
                                          right: 5.w,
                                          top: 7.h,
                                          child: Container(
                                            padding: EdgeInsets.zero,
                                            alignment: Alignment.center,
                                            height: 12.h,
                                            width: 10.w,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: CustomText(
                                              text: state.count.toString(),
                                              color: Colors.white,
                                              size: 6,
                                              textAlign: TextAlign.center,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                        onChanged: (value) {
                          searchWord = value;
                          final filterState =
                              context.read<PaymentFilterCountBloc>().state;

                          // Optionally trigger the search event with an empty string
                          context.read<PaymentBloc>().add(SearchPayments(
                              searchQuery: value,
                              userIds: filterState.selectedUserIds,
                              invoiceIds: filterState.selectedInvoiceIds,
                              paymentMethodIds:
                                  filterState.selectedPaymentMethodIds,
                              fromDate: filterState.fromDate,
                              toDate: filterState.toDate));
                        },
                      ),
                      SizedBox(height: 20.h),
                      Expanded(
                        child: RefreshIndicator(
                            color: AppColors.primary, // Spinner color
                            backgroundColor:
                                Theme.of(context).colorScheme.backGroundColor,
                            onRefresh: _onRefresh,
                            child: _PaymentBloc(isLightTheme)),
                      ),
                    ],
                  ),
                )),
          );
  }

  Widget _PaymentBloc(isLightTheme) {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        print("udhrghkd $state");
        if (state is PaymentDeleteSuccess) {
          Navigator.pop(context);
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
        if (state is PaymentDeleteError) {
          flutterToastCustom(msg: state.errorMessage);
          context.read<PaymentBloc>().add(const PaymentLists(
              userIds: [],
              invoiceIds: [],
              paymentMethodIds: [],
              fromDate: '',
              toDate: ''));
        }
        if (state is PaymentLoading) {
          return NotesShimmer(
            height: 190.h,
            count: 4,
          );
        } else if (state is PaymentPaginated) {
          // Show Payment list with pagination
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              // Check if the user has scrolled to the end and load more Payment if needed
              if (!state.hasReachedMax &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                final filterState =
                    context.read<PaymentFilterCountBloc>().state;

                // Optionally trigger the search event with an empty string
                context.read<PaymentBloc>().add(LoadMorePayments(
                    searchQuery: "",
                    userIds: filterState.selectedUserIds,
                    invoiceIds: filterState.selectedInvoiceIds,
                    paymentMethodIds: filterState.selectedPaymentMethodIds,
                    fromDate: filterState.fromDate,
                    toDate: filterState.toDate));
              }
              return false;
            },
            child: context.read<PermissionsBloc>().isManagePayment == true
                ? state.Payment.isNotEmpty
                    ? _PaymentList(
                        isLightTheme, state.hasReachedMax, state.Payment)
                    : NoData(
                        isImage: true,
                      )
                : NoPermission(),
          );
        } else if (state is PaymentError) {
          // Show error message
          return Center(
            child: Text(
              state.errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return const Text("");
      },
    );
  }

  Widget _PaymentList(isLightTheme, hasReachedMax, PaymentList) {
    return ListView.builder(
      padding: EdgeInsets.only(
          left: 18.w,
          right: 18.w,
          bottom: 70.h,
          top: 0),
      // shrinkWrap: true,
      itemCount: hasReachedMax
          ? PaymentList.length // No extra item if all data is loaded
          : PaymentList.length + 1, // Add 1 for the loading indicator
      itemBuilder: (context, index) {
        if (index < PaymentList.length) {
          final Payment = PaymentList[index];
          return index == 0
              ? ShakeWidget(
                  child: _PaymentCard(
                  isLightTheme: isLightTheme,
                  PaymentModel: Payment,
                  PaymentList: PaymentList,
                  index: index,
                ))
              : _PaymentCard(
                  isLightTheme: isLightTheme,
                  PaymentModel: Payment,
                  PaymentList: PaymentList,
                  index: index);
        } else {
          // Show a loading indicator when more Payment are being loaded
          return CircularProgressIndicatorCustom(
            hasReachedMax: hasReachedMax,
          );
        }
      },
    );
  }

  Widget _PaymentCard(
      {isLightTheme,
      required PaymentModel PaymentModel,
      required List<PaymentModel> PaymentList,
      required int index}) {
    final PaymentDate = formatDateFromApi(PaymentModel.paymentDate!, context);

    return DismissibleCard(
      title: PaymentModel.id.toString(),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.endToStart) {
          // Right to left swipe (Delete action)
          try {
            final result = await showDialog<bool>(
              context: context,
              barrierDismissible:
                  false, // Prevent dismissing by tapping outside
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  backgroundColor:
                      Theme.of(context).colorScheme.alertBoxBackGroundColor,
                  title: Text(
                    AppLocalizations.of(context)!.confirmDelete,
                  ),
                  content: Text(
                    AppLocalizations.of(context)!.areyousure,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        print(
                            "User confirmed deletion - about to pop with true");
                        Navigator.of(context).pop(true); // Confirm deletion
                      },
                      child: Text(
                        AppLocalizations.of(context)!.ok,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        print(
                            "User cancelled deletion - about to pop with false");
                        Navigator.of(context).pop(false); // Cancel deletion
                      },
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                      ),
                    ),
                  ],
                );
              },
            );

            print("Dialog result received: $result");
            print("About to return from confirmDismiss: ${result ?? false}");

            // If user confirmed deletion, handle it here instead of in onDismissed
            if (result == true) {
              print("Handling deletion directly in confirmDismiss");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  PaymentList.removeAt(index);
                });
                context.read<PaymentBloc>().add(DeletePayments(PaymentModel.id!));

              });
              // Return false to prevent the dismissible from animating
              return false;
            }

            return false; // Always return false since we handle deletion manually
          } catch (e) {
            print("Error in dialog: $e");
            return false;
          } // Return the result of the dialog
        } else if (direction == DismissDirection.startToEnd) {
          router.push(
            '/createupdatepayment',
            extra: {'isCreate': false, "paymentModel": PaymentModel},
          );

          return false; // Prevent dismiss
        }

        return false;
      },
      dismissWidget: Container(
        // height: 250.h,
        decoration: BoxDecoration(
            boxShadow: [
              isLightTheme
                  ? MyThemes.lightThemeShadow
                  : MyThemes.darkThemeShadow,
            ],
            // color: AppColors.red,
            color: Theme.of(context).colorScheme.containerDark,
            borderRadius: BorderRadius.circular(12)),
        width: double.infinity,
        // color: Colors.yellow,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: ID and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "#${PaymentModel.id.toString()}",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  // Text(
                  //   "${PaymentModel.invoiceId.toString()}",
                  //   style: TextStyle(color: Colors.grey, fontSize: 14),
                  // ),
                  Tooltip(
                    message: 'Invoice Download INV-${PaymentModel.invoiceId}',
                    child: InkWell(
                      onTap: () {
                        _launchUrl(
                          Uri.parse(
                              "${url}estimates-invoices/pdf-api/${PaymentModel.invoiceId}"),
                        );
                      },
                      child: Container(
                        child: Image.asset(
                          AppImages.downlaodInvoiceImage,
                          height: 30.h,
                          width: 30.w,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 12.h),
              // Title
              PaymentModel.paymentMethod != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: CustomText(
                        text: PaymentModel.paymentMethod ?? "",
                        color: AppColors.pureWhiteColor,
                        size: 16,
                        fontWeight: FontWeight.w700,
                      ))
                  : SizedBox(),

              SizedBox(height: 8.h),
              // Payment Type

              // User & Amount
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 23.r,
                    backgroundColor: AppColors.greyColor,
                    child: CircleAvatar(
                      radius: 22.r,
                      backgroundColor: Colors.blue,
                      backgroundImage:
                          NetworkImage(PaymentModel.user!.photo!),
                    ),
                  ),
                  SizedBox(width: 12.h),
                  // User details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text:
                            "${PaymentModel.user?.firstName ?? ""} ${PaymentModel.user?.lastName ?? ""}",
                        color: Theme.of(context).colorScheme.textClrChange,
                        size: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      CustomText(
                        text: PaymentModel.user!.email ?? "",
                        color: AppColors.greyColor,
                        size: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Amount
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "$currency ${PaymentModel.amount ?? ""}",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.createdby,
                    style: TextStyle(
                      color: AppColors.greyColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                  Text(
                    PaymentModel.createdBy ?? "",
                    style: TextStyle(
                      color: AppColors.blueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5.h,
              ),
              // Action Icons
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.paymentdate,
                    style: TextStyle(
                      color: AppColors.greyColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                  Text(
                    " ${PaymentDate}",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      direction: context.read<PermissionsBloc>().isdeletePayment == true &&
              context.read<PermissionsBloc>().iseditPayment == true
          ? DismissDirection.horizontal // Allow both directions
          : context.read<PermissionsBloc>().isdeletePayment == true
              ? DismissDirection.endToStart // Allow delete
              : context.read<PermissionsBloc>().iseditPayment == true
                  ? DismissDirection.startToEnd // Allow edit
                  : DismissDirection.none,
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.endToStart &&
            context.read<PermissionsBloc>().isdeleteProject == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              PaymentList.removeAt(index);
            });
            context.read<PaymentBloc>().add(DeletePayments(PaymentModel.id!));
          });
        } else if (direction == DismissDirection.startToEnd &&
            context.read<PermissionsBloc>().iseditProject == true) {
          // Perform edit action
        }
      },
    );
  }

  void _filterDialog(BuildContext context, isLightTheme) {
    final filterBlocState = context.read<PaymentFilterCountBloc>().state;

    // Access selected user IDs from the state
    paymentsId = List<int>.from(filterBlocState.selectedPaymentMethodIds);
    invoicesIdFilter = List<int>.from(filterBlocState.selectedInvoiceIds);
    userSelectedIdS = List<int>.from(filterBlocState.selectedUserIds);

    // Access and set dates from state
    if (filterBlocState.fromDate.isNotEmpty) {
      fromDate = filterBlocState.fromDate;
      toDate = filterBlocState.toDate;

      try {
        selectedDateStarts = DateTime.parse(fromDate!);
        startsController.text =
            DateFormat('MMMM dd, yyyy').format(selectedDateStarts);

        if (toDate != "") {
          selectedDateEnds = DateTime.parse(toDate!);
          endController.text =
              DateFormat('MMMM dd, yyyy').format(selectedDateEnds!);
        }
      } catch (e) {
        print('Date parsing failed: $e');
      }
    }

    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.containerDark,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 800.h, // max height you want
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // <-- important to minimize size
                    children: <Widget>[
                      SizedBox(height: 10),
                      // Title
                      CustomText(
                        text: AppLocalizations.of(context)!.selectfilter,
                        color: AppColors.primary,
                        size: 30.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 20), // Spacing

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                              // color: Colors.red,
                              height: 400.h, // Set a specific height if needed
                              child: ListView.builder(
                                itemCount: filter.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        filterNameNotifier.value =
                                            filter[index];
                                        filterName = filter[index];
                                      });
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.h),
                                      child: Container(
                                        height: 50.h,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            isLightTheme
                                                ? MyThemesFilter
                                                    .lightThemeShadow
                                                : MyThemesFilter
                                                    .darkThemeShadow,
                                          ],
                                          color: Theme.of(context)
                                              .colorScheme
                                              .containerDark,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ValueListenableBuilder<String>(
                                              valueListenable:
                                                  filterNameNotifier,
                                              builder:
                                                  (context, filterName, child) {
                                                return filterName ==
                                                        filter[index]
                                                    ? Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          width: 2,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                      )
                                                    : SizedBox.shrink();
                                              },
                                            ),
                                            Expanded(
                                              flex: 35,
                                              child: Center(
                                                child: Container(
                                                  // color: AppColors.yellow,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.w,
                                                      vertical: 4
                                                          .h), // Optional padding
                                                  child: Text(
                                                    filter[index],
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .textClrChange,
                                                      fontSize: 15,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Vertical Divider

                          // Second Column (Placeholder for future content)
                          Expanded(
                            flex: 4,
                            child: ValueListenableBuilder<String>(
                              valueListenable: filterNameNotifier,
                              builder: (context, filterName, child) {
                                return _getFilteredWidget(
                                    filterName, isLightTheme);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: 5.h), // Spacing between content and buttons

                      // Actions (Buttons)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 18.w, vertical: 10.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            // Apply Button
                            InkWell(
                              onTap: () {
                                // Calculate and update filter count based on selections

                                if (userSelectedIdS.isNotEmpty) {
                                  context.read<PaymentFilterCountBloc>().add(
                                        PaymentUpdateFilterCount(
                                            filterType: 'users',
                                            isSelected: true),
                                      );
                                }
                                if (invoicesIdFilter.isNotEmpty) {
                                  context.read<PaymentFilterCountBloc>().add(
                                        PaymentUpdateFilterCount(
                                            filterType: 'invoice',
                                            isSelected: true),
                                      );
                                }
                                if (paymentsId.isNotEmpty) {
                                  context.read<PaymentFilterCountBloc>().add(
                                        PaymentUpdateFilterCount(
                                            filterType: 'Payment Method',
                                            isSelected: true),
                                      );
                                }
                                if (fromDate != null || toDate != null) {
                                  context.read<PaymentFilterCountBloc>().add(
                                        PaymentUpdateFilterCount(
                                            filterType: 'date',
                                            isSelected: true),
                                      );
                                }

                                final filterState = context
                                    .read<PaymentFilterCountBloc>()
                                    .state;

                                context.read<PaymentBloc>().add(
                                      PaymentLists(
                                        userIds: filterState.selectedUserIds,
                                        invoiceIds:
                                            filterState.selectedInvoiceIds,
                                        paymentMethodIds: filterState
                                            .selectedPaymentMethodIds,
                                        fromDate: filterState.fromDate,
                                        toDate: filterState.toDate,
                                      ),
                                    );

                                // Clear search controllers
                                _userSearchController.clear();
                                _invoiceSearchController.clear();
                                _paymentMethodSearchController.clear();

                                Navigator.of(context).pop();
                              },
                              child: Container(
                                height: 35.h,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15.w, vertical: 0.h),
                                  child: Center(
                                    child: CustomText(
                                      text: AppLocalizations.of(context)!.apply,
                                      size: 12.sp,
                                      color: AppColors.pureWhiteColor,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 30.w),
                            // Clear Button
                            InkWell(
                              onTap: () {
                                setState(() {
                                  // Reset all filter selections
                                  context
                                      .read<PaymentFilterCountBloc>()
                                      .add(PaymentResetFilterCount());

                                  // Clear all selected IDs
                                  invoicesIdFilter.clear();
                                  paymentsId.clear();
                                  userSelectedIdS.clear();

                                  // Reset date filters
                                  fromDate = "";
                                  toDate = "";
                                  startsController.text = "";
                                  endController.text = "";

                                  // Clear search controllers
                                  _invoiceSearchController.clear();
                                  _paymentMethodSearchController.clear();
                                  _userSearchController.clear();

                                  // Reset filter name
                                  filterNameNotifier.value = 'Clients';

                                  // // Reset project dashboard
                                  BlocProvider.of<PaymentBloc>(context).add(
                                      PaymentLists(
                                          userIds: [],
                                          invoiceIds: [],
                                          paymentMethodIds: [],
                                          fromDate: '',
                                          toDate: ''));

                                  Navigator.of(context).pop();
                                });
                              },
                              child: Container(
                                height: 35.h,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 15.w),
                                  child: Center(
                                    child: CustomText(
                                      text: AppLocalizations.of(context)!.clear,
                                      size: 12.sp,
                                      color: AppColors.pureWhiteColor,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )));
      },
    );
  }

  Widget _getFilteredWidget(filterName, isLightTheme) {
    switch (filterName.toLowerCase()) {
      // Show ClientList if filterName is "client"
      case 'users':
        return userLists(); // Show UserList if filterName is "user"
      case 'invoice':
        return invoiceLists();
      case 'Payment Method':
        return paymentMethodLists();
      case 'date':
        return dateList(isLightTheme); // Show TagsList if filterName is "tags"
      default:
        return userLists(); // Default view
    }
  }

  void _onFilterSelected(String selectedFilter) {
    setState(() {
      filterName = selectedFilter; // Update the filterName and rebuild UI
    });
  }

  Widget dateList(isLightTheme) {
    selectedDateStarts = parseDateStringFromApi(
        context.watch<PaymentFilterCountBloc>().state.fromDate);
    selectedDateEnds = parseDateStringFromApi(
        context.watch<PaymentFilterCountBloc>().state.toDate);

    return SizedBox(
      width: 200.w,
      height: 400.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: DateRangePickerWidget(
              dateController: startsController,
              title: AppLocalizations.of(context)!.starts,
              selectedDateEnds: selectedDateEnds,
                    selectedDateStarts: selectedDateStarts,
                    isLightTheme: isLightTheme,
                    onTap: (start, end) {
                      setState(() {
                        // if (start.isBefore(DateTime.now())) {
                        //   start = DateTime
                        //       .now(); // Reset the start date to today if earlier
                        // }

                        // If the end date is not selected or is null, set it to the start date
                        if (end!.isBefore(start!) || selectedDateEnds == null) {
                          end =
                              start; // Set the end date to the start date if not selected
                        }
                        selectedDateEnds = end;
                        selectedDateStarts = start;
                        startsController.text = DateFormat('MMMM dd, yyyy')
                            .format(selectedDateStarts);
                        endController.text =
                            DateFormat('MMMM dd, yyyy').format(selectedDateEnds!);
                        fromDate = DateFormat('yyyy-MM-dd').format(start);
                        toDate = DateFormat('yyyy-MM-dd').format(end!);
                        context.read<PaymentFilterCountBloc>().add(
                            SetPaymentDate(fromDate: fromDate!, toDate: toDate!));
                      });
                    },

            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: DateRangePickerWidget(
              dateController: endController,
              title: AppLocalizations.of(context)!.ends,
              isLightTheme: isLightTheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget userLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 35.h,
            child: TextField(
              cursorColor: AppColors.greyForgetColor,
              cursorWidth: 1,
              controller: _userSearchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: (35.h - 20.sp) / 2,
                  horizontal: 10.w,
                ),
                hintText: 'Search...',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors
                        .greyForgetColor, // Set your desired color here
                    width: 1.0, // Set the border width if needed
                  ),
                  borderRadius: BorderRadius.circular(
                      20.0), // Optional: adjust the border radius
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: AppColors
                        .purple, // Border color when TextField is focused
                    width: 1.0,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchWord = value;
                });
                context.read<UserBloc>().add(SearchUsers(value));
              },
            ),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        BlocBuilder<UserBloc, UserState>(builder: (context, state) {
          if (state is UserLoading || state is UserInitial) {
            return SpinKitFadingCircle(
              size: 40,
              color: AppColors.primary,
            );
          }
          if (state is UserPaginated) {
            ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.atEdge) {
                if (scrollController.position.pixels != 0 &&
                    !state.hasReachedMax) {
                  // We're at the bottom
                  BlocProvider.of<UserBloc>(context)
                      .add(UserLoadMore(searchWord));
                }
              }
            });

            return StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                constraints: BoxConstraints(maxHeight: 900.h),
                width: 200.w,
                height: 530,
                child: state.user.isNotEmpty
                    ? ListView.builder(
                        controller: scrollController,
                        // physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.user.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index < state.user.length) {
                            final userSelectedIdS = context
                                .watch<PaymentFilterCountBloc>()
                                .state
                                .selectedUserIds;

                            final isSelected =
                                userSelectedIdS.contains(state.user[index].id!);
                            // final isSelected = widget.userId?.contains(state.user[index].id);

                            return InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    userDisSelected = true;
                                    userSelectedIdS
                                        .remove(state.user[index].id!);
                                    userSelectedname
                                        .remove(state.user[index].firstName!);
                                    userSelected = false;

                                    // If no users are selected anymore, update filter count
                                    if (userSelectedIdS.isEmpty) {
                                      context
                                          .read<PaymentFilterCountBloc>()
                                          .add(
                                            PaymentUpdateFilterCount(
                                              filterType: 'users',
                                              isSelected: false,
                                            ),
                                          );
                                    }
                                  } else {
                                    userDisSelected = false;
                                    if (!userSelectedIdS
                                        .contains(state.user[index].id!)) {
                                      userSelectedIdS
                                          .add(state.user[index].id!);
                                      userSelectedname
                                          .add(state.user[index].firstName!);

                                      // Update filter count when first user is selected
                                      if (userSelectedIdS.length == 1) {
                                        context
                                            .read<PaymentFilterCountBloc>()
                                            .add(
                                              PaymentUpdateFilterCount(
                                                filterType: 'users',
                                                isSelected: true,
                                              ),
                                            );
                                      }
                                      context
                                          .read<PaymentFilterCountBloc>()
                                          .add(SetPaymentUsers(
                                              userIds: userSelectedIdS));
                                    }
                                    filterSelectedId = state.user[index].id!;
                                    filterSelectedName = "users";
                                  }

                                  _onFilterSelected('users');
                                });

                                BlocProvider.of<UserBloc>(context).add(
                                    SelectedUser(
                                        index, state.user[index].firstName!));

                                BlocProvider.of<UserBloc>(context).add(
                                    ToggleUserSelection(state.user[index].id!,
                                        state.user[index].firstName!));
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.purpleShade
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.transparent)),
                                  width: double.infinity,
                                  height: 55.h,
                                  child: Center(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5.w),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Column takes up maximum available space
                                            Expanded(
                                              child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 0.w),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 20,
                                                        backgroundImage:
                                                            NetworkImage(state
                                                                .user[index]
                                                                .profile!),
                                                      ),
                                                      SizedBox(
                                                        width: 5.w,
                                                      ), // Column takes up maximum available space
                                                      Expanded(
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      0.w),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Flexible(
                                                                    child:
                                                                        CustomText(
                                                                      text: state
                                                                          .user[
                                                                              index]
                                                                          .firstName!,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      size:
                                                                          18.sp,
                                                                      color: isSelected
                                                                          ? AppColors
                                                                              .primary
                                                                          : Theme.of(context)
                                                                              .colorScheme
                                                                              .textClrChange,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          5.w),
                                                                  Flexible(
                                                                    child:
                                                                        CustomText(
                                                                      text: state
                                                                          .user[
                                                                              index]
                                                                          .lastName!,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      size:
                                                                          18.sp,
                                                                      color: isSelected
                                                                          ? AppColors
                                                                              .primary
                                                                          : Theme.of(context)
                                                                              .colorScheme
                                                                              .textClrChange,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Flexible(
                                                                    child:
                                                                        CustomText(
                                                                      text: state
                                                                          .user[
                                                                              index]
                                                                          .email!,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      size:
                                                                          14.sp,
                                                                      color: isSelected
                                                                          ? AppColors
                                                                              .primary
                                                                          : Theme.of(context)
                                                                              .colorScheme
                                                                              .textClrChange,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // Spacer to push the icon to the far right
                                                      // if (isSelected) ...[
                                                      //   SizedBox(
                                                      //       width: 8
                                                      //           .w), // Optional spacing between text and icon
                                                      //   HeroIcon(
                                                      //     HeroIcons.checkCircle,
                                                      //     style: HeroIconStyle.solid,
                                                      //     color: AppColors.purple,
                                                      //   ),
                                                      // ]
                                                    ],
                                                  )),
                                            ),
                                            // Spacer to push the icon to the far right
                                            if (isSelected) ...[
                                              SizedBox(
                                                  width: 8
                                                      .w), // Optional spacing between text and icon
                                              HeroIcon(
                                                HeroIcons.checkCircle,
                                                style: HeroIconStyle.solid,
                                                color: AppColors.purple,
                                              ),
                                            ]
                                          ],
                                        )),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Show a loading indicator when more notes are being loaded
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Center(
                                child: state.hasReachedMax
                                    ? const Text('')
                                    : const SpinKitFadingCircle(
                                        color: AppColors.primary,
                                        size: 40.0,
                                      ),
                              ),
                            );
                          }
                        },
                      )
                    : NoData(),
              );
            });
          }
          return SizedBox();
        }),
      ],
    );
  }

  Widget invoiceLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 35.h,
            child: TextField(
              cursorColor: AppColors.greyForgetColor,
              cursorWidth: 1,
              controller: _invoiceSearchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: (35.h - 20.sp) / 2,
                  horizontal: 10.w,
                ),
                hintText: 'Search...',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors
                        .greyForgetColor, // Set your desired color here
                    width: 1.0, // Set the border width if needed
                  ),
                  borderRadius: BorderRadius.circular(
                      20.0), // Optional: adjust the border radius
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: AppColors
                        .purple, // Border color when TextField is focused
                    width: 1.0,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchWord = value;
                });
                context
                    .read<EstinateInvoiceBloc>()
                    .add(SearchEstimateInvoices(value, [], [], [], [], "", ""));
              },
            ),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        BlocConsumer<EstinateInvoiceBloc, EstinateInvoiceState>(
            listener: (context, state) {
          if (state is EstinateInvoiceSuccess) {
            isLoadingMore = false;
            setState(() {});
          }
        }, builder: (context, state) {
          if (state is EstinateInvoicePaginated) {
            ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.atEdge) {
                if (scrollController.position.pixels != 0 &&
                    !state.hasReachedMax) {
                  // We're at the bottom
                  BlocProvider.of<UserBloc>(context)
                      .add(UserLoadMore(searchWord));
                }
              }
            });

            return StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setState) {
              final filteredInvoices =
                  state.EstinateInvoice.where((item) => item.type != 'estimate')
                      .toList();
              return Container(
                constraints: BoxConstraints(maxHeight: 900.h),
                width: 200.w,
                height: 530,
                child: state.EstinateInvoice.isNotEmpty
                    ? ListView.builder(
                        // physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.hasReachedMax
                            ? filteredInvoices.length
                            : filteredInvoices.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index < filteredInvoices.length) {
                            print("fhefkhfrekrhih ${invoicesIdFilter}");
                            final invoice = filteredInvoices[index];
                            // final isSelected = invoicesIdFilter.contains(invoice.id);
                            final isSelected = invoicesIdFilter
                                .contains(state.EstinateInvoice[index].id);

                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 2.h, horizontal: 20.w),
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                // No highlight on tap
                                splashColor: Colors.transparent,
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      invoiceDisSelected = true;
                                      invoicesIdFilter.remove(
                                          state.EstinateInvoice[index].id!);
                                      invoicesnameFilter.remove(
                                          "INV-${state.EstinateInvoice[index].id}");
                                      invoiceSelected = false;

                                      // If no users are selected anymore, update filter count
                                      if (invoicesIdFilter.isEmpty) {
                                        context
                                            .read<PaymentFilterCountBloc>()
                                            .add(
                                              PaymentUpdateFilterCount(
                                                filterType: 'invoice',
                                                isSelected: false,
                                              ),
                                            );
                                      }
                                    } else {
                                      invoiceDisSelected = false;
                                      if (!invoicesIdFilter.contains(
                                          state.EstinateInvoice[index].id!)) {
                                        invoicesIdFilter.add(
                                            state.EstinateInvoice[index].id!);
                                        invoicesnameFilter.add(
                                            "INV-${state.EstinateInvoice[index].id}");

                                        // Update filter count when first user is selected
                                        if (invoicesIdFilter.length == 1) {
                                          context
                                              .read<PaymentFilterCountBloc>()
                                              .add(
                                                PaymentUpdateFilterCount(
                                                  filterType: 'invoice',
                                                  isSelected: true,
                                                ),
                                              );
                                        }
                                        context
                                            .read<PaymentFilterCountBloc>()
                                            .add(SetPaymentInvoices(
                                                invoiceIds: invoicesIdFilter));
                                      }
                                      filterSelectedId =
                                          state.EstinateInvoice[index].id!;
                                      filterSelectedName = "invoice";
                                    }

                                    _onFilterSelected('invoice');
                                  });
                                  // setState(() {
                                  //   if (isSelected) {
                                  //     invoicesIdFilter
                                  //         .remove(state.EstinateInvoice[index].id!);
                                  //     invoicesnameFilter.remove(
                                  //         "INV-${state.EstinateInvoice[index].id}");
                                  //     // If no clients are selected anymore, update filter count
                                  //     if (invoicesIdFilter.isEmpty) {
                                  //       context.read<PaymentFilterCountBloc>().add(
                                  //         PaymentUpdateFilterCount(
                                  //           filterType: 'invoice',
                                  //           isSelected: false,
                                  //         ),
                                  //       );
                                  //     }
                                  //   } else {
                                  //     if (!invoicesIdFilter
                                  //         .contains(state.EstinateInvoice[index].id!)) {
                                  //       invoicesIdFilter
                                  //           .add(state.EstinateInvoice[index].id!);
                                  //       invoicesnameFilter.add(
                                  //           "INV-${state.EstinateInvoice[index].id}");
                                  //       // Update filter count when first client is selected
                                  //       if (invoicesIdFilter.length == 1) {
                                  //         context.read<PaymentFilterCountBloc>().add(
                                  //           PaymentUpdateFilterCount(
                                  //             filterType: 'invoice',
                                  //             isSelected: true,
                                  //           ),
                                  //         );
                                  //       }
                                  //     }
                                  //   }
                                  //
                                  //   if (invoicesIdFilter.isNotEmpty) {
                                  //     context.read<PaymentFilterCountBloc>().add(
                                  //       PaymentUpdateFilterCount(
                                  //         filterType: 'invoice',
                                  //         isSelected: false,
                                  //       ),
                                  //     );
                                  //   }
                                  //   // BlocProvider.of<
                                  //   //     EstinateInvoiceBloc>(
                                  //   //     context)
                                  //   //     .add(SelectEstinateInvoice(
                                  //   //    selectedInvoice: null));
                                  // });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.purpleShade
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.transparent)),
                                  width: double.infinity,
                                  height: 40.h,
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            // width:200.w,
                                            child: CustomText(
                                              text: invoice.type == 'invoice'
                                                  ? "INV-${invoice.id}"
                                                  : invoice.name ?? '',
                                              fontWeight: FontWeight.w500,
                                              size: 18,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              color: isSelected
                                                  ? AppColors.purple
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .textClrChange,
                                            ),
                                          ),
                                          isSelected
                                              ? Expanded(
                                                  flex: 1,
                                                  child: const HeroIcon(
                                                    HeroIcons.checkCircle,
                                                    style: HeroIconStyle.solid,
                                                    color: AppColors.purple,
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Show a loading indicator when more notes are being loaded
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Center(
                                child: state.hasReachedMax
                                    ? const Text('')
                                    : const SpinKitFadingCircle(
                                        color: AppColors.primary,
                                        size: 40.0,
                                      ),
                              ),
                            );
                          }
                        },
                      )
                    : NoData(),
              );
            });
          }
          return SizedBox();
        }),
      ],
    );
  }

  Widget paymentMethodLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 35.h,
            child: TextField(
              cursorColor: AppColors.greyForgetColor,
              cursorWidth: 1,
              controller: _paymentMethodSearchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: (35.h - 20.sp) / 2,
                  horizontal: 10.w,
                ),
                hintText: 'Search...',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors
                        .greyForgetColor, // Set your desired color here
                    width: 1.0, // Set the border width if needed
                  ),
                  borderRadius: BorderRadius.circular(
                      20.0), // Optional: adjust the border radius
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: AppColors
                        .purple, // Border color when TextField is focused
                    width: 1.0,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchWord = value;
                });
                context
                    .read<PaymentMethodBloc>()
                    .add(SearchPaymentMethd(value));
              },
            ),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        BlocConsumer<PaymentMethodBloc, PaymentMethdState>(
            listener: (context, state) {
          if (state is PaymentMethdSuccess) {
            isLoadingMore = false;
            setState(() {});
          }
        }, builder: (context, state) {
          if (state is PaymentMethdSuccess) {
            ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.atEdge) {
                if (scrollController.position.pixels != 0 &&
                    !state.isLoadingMore) {
                  // We're at the bottom
                  // BlocProvider.of<PaymentMethodBloc>(context)
                  //     .add(UserLoadMore(searchWord));
                }
              }
            });

            return StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                constraints: BoxConstraints(maxHeight: 900.h),
                width: 200.w,
                height: 530,
                child: state.PaymentMethd.isNotEmpty
                    ? ListView.builder(
                        // physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.isLoadingMore
                            ? state.PaymentMethd.length
                            : state.PaymentMethd.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index < state.PaymentMethd.length) {
                            final isSelected = paymentsId
                                .contains(state.PaymentMethd[index].id);

                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 2.h, horizontal: 20.w),
                              child: InkWell(
                                highlightColor:
                                    Colors.transparent, // No highlight on tap
                                splashColor: Colors.transparent,
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      paymentDisSelected = true;
                                      paymentsId
                                          .remove(state.PaymentMethd[index].id);
                                      paymentsname.remove(
                                          state.PaymentMethd[index].title);
                                      payentSelected = false;
                                      if (paymentsId.isEmpty) {
                                        context
                                            .read<PaymentFilterCountBloc>()
                                            .add(
                                              PaymentUpdateFilterCount(
                                                filterType: 'Payment Method',
                                                isSelected: false,
                                              ),
                                            );
                                      }
                                    } else {
                                      paymentDisSelected = false;
                                      if (!paymentsname.contains(
                                          state.PaymentMethd[index].id)) {
                                        paymentsId
                                            .add(state.PaymentMethd[index].id!);
                                        paymentsname.add(
                                            state.PaymentMethd[index].title!);
                                        print(
                                            "f.hdsf. hfkd. ${paymentsId.length}");
                                        if (paymentsId.length == 1) {
                                          context
                                              .read<PaymentFilterCountBloc>()
                                              .add(
                                                PaymentUpdateFilterCount(
                                                  filterType: 'paymentmethod',
                                                  isSelected: true,
                                                ),
                                              );
                                        }
                                        context
                                            .read<PaymentFilterCountBloc>()
                                            .add(SetPaymentMethods(
                                                paymentMethodIds: paymentsId));
                                      }
                                    }

                                    _onFilterSelected('paymentmethod');

                                    // if (widget
                                    //     .isCreate ==
                                    //     true) {
                                    //   paymentsname =
                                    //   state
                                    //       .PaymentMethd[
                                    //   index]
                                    //       .title!;
                                    //   paymentsId = state
                                    //       .PaymentMethd[
                                    //   index]
                                    //       .id!;
                                    //
                                    // } else {
                                    //   name = state
                                    //       .PaymentMethd[
                                    //   index]
                                    //       .title!;
                                    //   paymentsname =
                                    //   state
                                    //       .PaymentMethd[
                                    //   index]
                                    //       .title!;
                                    //   paymentsId = state
                                    //       .PaymentMethd[
                                    //   index]
                                    //       .id!;
                                    //
                                    // }
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.purpleShade
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.transparent)),
                                  width: double.infinity,
                                  height: 40.h,
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            // width:200.w,
                                            child: CustomText(
                                              text: state
                                                  .PaymentMethd[index].title!,
                                              fontWeight: FontWeight.w500,
                                              size: 18,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              color: isSelected
                                                  ? AppColors.purple
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .textClrChange,
                                            ),
                                          ),
                                          isSelected
                                              ? Expanded(
                                                  flex: 1,
                                                  child: const HeroIcon(
                                                    HeroIcons.checkCircle,
                                                    style: HeroIconStyle.solid,
                                                    color: AppColors.purple,
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Show a loading indicator when more notes are being loaded
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Center(
                                child: state.isLoadingMore
                                    ? const Text('')
                                    : const SpinKitFadingCircle(
                                        color: AppColors.primary,
                                        size: 40.0,
                                      ),
                              ),
                            );
                          }
                        },
                      )
                    : NoData(),
              );
            });
          }
          return SizedBox();
        }),
      ],
    );
  }
}
