import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/data/model/finance/payment_model.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../../bloc/estimate_invoice/estimateInvoice_bloc.dart';
import '../../../bloc/estimate_invoice/estimateInvoice_event.dart';
import '../../../bloc/payment/payment_bloc.dart';
import '../../../bloc/payment/payment_event.dart';
import '../../../bloc/payment/payment_state.dart';
import '../../../bloc/setting/settings_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../config/constants.dart';
import '../../../config/internet_connectivity.dart';
import '../../../data/GlobalVariable/globalvariable.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../leave_request/widgets/single_userfield.dart';
import '../../widgets/custom_textfields/custom_textfield.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../widgets/custom_date.dart';
import '../widgets/invoice_list.dart';
import '../widgets/payment_method_list.dart';
import '../../../../src/generated/i18n/app_localizations.dart';

class CreateUpdatePaymentScreen extends StatefulWidget {
  final bool? isCreate;
  final PaymentModel? paymentModel;
  CreateUpdatePaymentScreen({super.key, this.isCreate, this.paymentModel});

  @override
  State<CreateUpdatePaymentScreen> createState() =>
      _CreateUpdatePaymentScreenState();
}

class _CreateUpdatePaymentScreenState extends State<CreateUpdatePaymentScreen> {
  TextEditingController amountController = TextEditingController();
  TextEditingController startsController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  TextEditingController noteController = TextEditingController();

  String selectedUser = '';
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  List<int>? selectedClientId;
  List<String>? selectedClient;
  List<String>? usersName;
  List<int>? selectedusersNameId;
  String? fromDate;
  String? toDate;
  String? strtTime;
  String? endTime;
  String? formattedTimeStart;
  String? formattedTimeEnd;
  DateTime? selectedDateStarts;
  DateTime? selectedDateEnds;
  TimeOfDay? _timestart;
  TimeOfDay? _timeend;
  String? singleUsersName;
  int? selectedSingleusersNameId;
  String? selectedPaymentType;
  int? selectedPaymentTypeId;
  String formatTimeOfDay(TimeOfDay timeOfDay) {
    // Convert TimeOfDay to DateTime
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);

    // Format to 12-hour time (hh:mm AM/PM)
    return DateFormat('hh:mm a').format(dateTime);
  }

  void handleSingleUsersSelected(
      String category, int catId, String email, String profile) {
    setState(() {
      singleUsersName = category;
      selectedSingleusersNameId = catId;
    });
  }

  void _handlePaymentmethodSelected(String category, int catID) {
    setState(() {
      selectedCategory = category;
      selectedID = catID;
    });
  }

  void _handleInvoiceSelected(String category, int catID) {
    setState(() {
      selectedInvoiceCategory = category;
      selectedInvoiceID = catID;
    });
  }

  void _selectstartTime() async {
    // Show the time picker dialog
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _timestart ??
          TimeOfDay.now(), // Use current time if _timestart is null
    );

    // If the user picks a valid time
    if (newTime != null) {
      setState(() {
        _timestart = newTime; // Update _timestart with the selected time
        // Format time as HH:MM
        formattedTimeStart =
            '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _selectendTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _timeend ?? TimeOfDay.now(),
    );

    if (newTime != null) {
      setState(() {
        _timeend = newTime;

        // Format as HH:MM
        formattedTimeEnd =
            '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void handleUsersSelected(List<String> category, List<int> catId) {
    setState(() {
      usersName = category;
      selectedusersNameId = catId;
    });
  }

  void handleClientSelected(List<String> category, List<int> catId) {
    setState(() {
      selectedClient = category;
      selectedClientId = catId;
    });
  }

  String selectedCategory = '';
  String selectedInvoiceCategory = '';
  int? selectedID;
  int? selectedInvoiceID;
  String currency = '';

  List<int>? listOfuserId = [];
  List<int>? listOfclientId = [];
  void onCreatePayment(BuildContext context) {
    if (fromDate != null &&
        fromDate!.isNotEmpty &&
        amountController.text.isNotEmpty) {
      final Payment = BlocProvider.of<PaymentBloc>(context);
      Payment.add(AddPayments(PaymentModel(
          paymentDate: fromDate,
          invoice: selectedInvoiceCategory.toLowerCase(),
          invoiceId: selectedInvoiceID,
          paymentMethod: selectedCategory.toLowerCase(),
          paymentMethodId: selectedID,
          userId: selectedSingleusersNameId,
          amount: amountController.text,
          note: noteController.text)));
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void onUpdatePayment(context, id) {
    // Print all parameters
    debugPrint('Parameter: context = $context');
    debugPrint('Parameter: id = $id');
    debugPrint('Parameter: amountController.text = ${amountController.text}');
    debugPrint('Parameter: selectedInvoiceCategory = $selectedInvoiceCategory');
    debugPrint('Parameter: selectedInvoiceID = $selectedInvoiceID');
    debugPrint('Parameter: selectedCategory = $selectedCategory');
    debugPrint('Parameter: selectedID = $selectedID');
    debugPrint(
        'Parameter: selectedSingleusersNameId = $selectedSingleusersNameId');
    debugPrint('Parameter: widget.paymentModel = ${widget.paymentModel}');
    debugPrint('Parameter: fromDate = $fromDate');
    debugPrint('Parameter: noteController.text = ${noteController.text}');

    final Payment = BlocProvider.of<PaymentBloc>(context);
    if (amountController.text.isNotEmpty) {
      Payment.add(PaymentUpdateds(PaymentModel(
        invoice: selectedInvoiceCategory.toLowerCase(),
        invoiceId: selectedInvoiceID ?? widget.paymentModel!.invoiceId,
        paymentMethod: selectedCategory.toLowerCase(),
        paymentMethodId: selectedID ?? widget.paymentModel!.paymentMethodId,
        id: id!,
        userId: selectedSingleusersNameId ?? widget.paymentModel!.user!.id!,
        amount: amountController.text.isNotEmpty
            ? amountController.text
            : widget.paymentModel!.amount,
        paymentDate: fromDate ?? widget.paymentModel!.paymentDate!,
        note: noteController.text.isNotEmpty
            ? noteController.text
            : widget.paymentModel!.note,
      )));

      Payment.stream.listen((state) {
        if (state is PaymentEditSuccess) {
          BlocProvider.of<PaymentBloc>(context).add(const PaymentLists(
              userIds: [],
              invoiceIds: [],
              paymentMethodIds: [],
              fromDate: '',
              toDate: ''));
          Navigator.pop(context);
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.updatedsuccessfully,
              color: AppColors.primary);
        }
        if (state is PaymentEditError) {
          flutterToastCustom(msg: state.errorMessage);
          BlocProvider.of<PaymentBloc>(context).add(const PaymentLists(
              userIds: [],
              invoiceIds: [],
              paymentMethodIds: [],
              fromDate: '',
              toDate: ''));
        }
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  String formatDate(String date) {
    // Parse the input date string
    DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(date);

    // Format it to the desired output
    return DateFormat('dd, MMM yyyy').format(parsedDate);
  }

  @override
  void initState() {
    currency = context.read<SettingsBloc>().currencySymbol!;
    print("fhrffih");
    print("fbdsfk ${widget.paymentModel!.id}");
// Initialize currentUser
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<EstinateInvoiceBloc>(context)
          .add(EstinateInvoiceLists([], [], [], [], "", ""));
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
    if (widget.isCreate == false) {
      String? formattedstart;
      // titleController.text = widget.paymentModel!.title!;
      // selectedPaymentType = widget.paymentModel!.PaymentType!;
      singleUsersName = widget.paymentModel!.user!.firstName;
      selectedCategory = widget.paymentModel!.paymentMethod ?? "";
      selectedInvoiceCategory = "INV- ${widget.paymentModel!.invoiceId}";
      amountController.text = widget.paymentModel!.amount!;
      if (widget.paymentModel!.paymentDate != null &&
          widget.paymentModel!.paymentDate!.isNotEmpty &&
          widget.paymentModel!.paymentDate != "") {
        DateTime parsedDate =
            parseDateStringFromApi(widget.paymentModel!.paymentDate!);
        formattedstart = dateFormatConfirmed(parsedDate, context);
        selectedDateStarts =
            parseDateStringFromApi(widget.paymentModel!.paymentDate!);
        print("jkrngfmv $selectedDateStarts");
      }
      startsController = TextEditingController(text: "$formattedstart");

      noteController.text = widget.paymentModel!.note ?? "";
    } else {}
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  appbar(isLightTheme),
                  SizedBox(height: 30.h),
                  body(isLightTheme)
                ],
              ),
            ),
          );
  }

  Widget appbar(isLightTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 0.h),
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(boxShadow: [
                    isLightTheme
                        ? MyThemes.lightThemeShadow
                        : MyThemes.darkThemeShadow,
                  ]),
                  // color: Colors.red,
                  // width: 300.w,
                  child: BackArrow(
                    title: widget.isCreate == true
                        ? AppLocalizations.of(context)!.createpayment
                        : AppLocalizations.of(context)!.editpayment,
                  )),
            ],
          ),
        )
      ],
    );
  }

  Widget body(isLightTheme) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleUserField(
            isEditLeaveReq: widget.isCreate,
            userId: [widget.paymentModel!.user!.id!],
            isCreate: widget.isCreate!,
            name: singleUsersName,
            from: false,
            index: 0,
            onSelected: handleSingleUsersSelected,
          ),
          SizedBox(
            height: 10.h,
          ),
          PaymentMethodList(
            isRequired: false,
            isCreate: widget.isCreate!,
            payment: widget.paymentModel!.paymentMethodId != null
                ? widget.paymentModel!.paymentMethodId!
                : 0,
            name: selectedCategory,
            onSelected: _handlePaymentmethodSelected,
          ),
          SizedBox(
            height: 10.h,
          ),
          InvoiceList(
            isRequired: false,
            isCreate: widget.isCreate!,
            invoice: widget.paymentModel!.invoiceId != null
                ? widget.paymentModel!.invoiceId!
                : 0,
            name: selectedInvoiceCategory,
            onSelected: _handleInvoiceSelected,
          ),
          SizedBox(
            height: 10.h,
          ),
          CustomTextFields(
            currency: true,
            title: AppLocalizations.of(context)!.amount,
            keyboardType: TextInputType.number,
            hinttext: AppLocalizations.of(context)!.pleaseentertitle,
            controller: amountController,
            onSaved: (value) {},
            onFieldSubmitted: (value) {},
            isLightTheme: isLightTheme,
            isRequired: true,
          ),
          SizedBox(
            height: 10.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: DatePickerWidget(
              star: true,
              dateController: startsController, // Use only one controller
              title: AppLocalizations.of(context)!.paymentdate,
              titlestartend: "",
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(9999),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        dialogTheme: DialogThemeData(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor),
                      ),
                      child: child!,
                    );
                  },
                );

                if (picked != null) {
                  setState(() {
                    selectedDateStarts = picked;
                    startsController.text =
                        dateFormatConfirmed(picked, context);
                    fromDate = dateFormatConfirmedToApi(picked);
                  });
                }
              },

              isLightTheme: isLightTheme,
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          CustomTextFields(
              height: 112.h,
              keyboardType: TextInputType.multiline,
              title: AppLocalizations.of(context)!.note,
              hinttext: AppLocalizations.of(context)!.pleaseenternotes,
              controller: noteController,
              onSaved: (value) {},
              onFieldSubmitted: (value) {},
              isLightTheme: isLightTheme,
              isRequired: false),
          SizedBox(
            height: 15.h,
          ),
          BlocBuilder<PaymentBloc, PaymentState>(builder: (context, state) {
            if (state is PaymentCreateSuccess) {
              context.read<PaymentBloc>().add(const PaymentLists(
                  userIds: [],
                  invoiceIds: [],
                  paymentMethodIds: [],
                  fromDate: '',
                  toDate: ''));
              router.pop(context);
              flutterToastCustom(
                  msg: AppLocalizations.of(navigatorKey.currentContext!)!
                      .createdsuccessfully,
                  color: AppColors.primary);
            }
            if (state is PaymentCreateError) {
              flutterToastCustom(msg: state.errorMessage);
            }
            if (state is PaymentEditSuccessLoading) {
              return CreateCancelButtom(
                isLoading: true,
                isCreate: widget.isCreate,
                onpressCreate: widget.isCreate == true
                    ? () async {
                        onCreatePayment(context);
                        // context.read<LeaveRequestBloc>().add(LeaveRequestList());
                      }
                    : () {
                        onUpdatePayment(context, widget.paymentModel!.id);
                        // context.read<LeaveRequestBloc>().add(LeaveRequestList());

                        // Navigator.pop(context);
                      },
                onpressCancel: () {
                  Navigator.pop(context);
                },
              );
            }
            if (state is PaymentCreateSuccessLoading) {}
            return CreateCancelButtom(
              isCreate: widget.isCreate,
              onpressCreate: widget.isCreate == true
                  ? () async {
                      onCreatePayment(context);
                      // context.read<LeaveRequestBloc>().add(LeaveRequestList());
                    }
                  : () {
                      onUpdatePayment(context, widget.paymentModel!.id);
                      // context.read<LeaveRequestBloc>().add(LeaveRequestList());

                      // Navigator.pop(context);
                    },
              onpressCancel: () {
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget startsField(isLightTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.starts,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              const CustomText(
                text: " *",
                // text: getTranslated(context, 'myweeklyTask'),
                color: AppColors.red,
                size: 15,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0.w),
          height: 40.h,
          width: double.infinity,
          // margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.textClrChange,
            ),
            readOnly: true,
            onTap: () {
              // Call the date picker here when tapped
              // // showCustomDateRangePicker(
              // //   context,
              // //   dismissible: true,
              // //   minimumDate: DateTime.now().subtract(const Duration(days: 30)),
              // //   maximumDate: DateTime.now().add(const Duration(days: 30)),
              // //   endDate: selectedDateEnds,
              // //   startDate: selectedDateStarts,
              // //   backgroundColor: Theme.of(context).colorScheme.containerDark,
              // //   primaryColor: AppColors.primary,
              // //   onApplyClick: (start, end) {
              // //     setState(() {
              // //       if (start.isBefore(DateTime.now())) {
              // //         start = DateTime
              // //             .now(); // Reset the start date to today if earlier
              // //       }
              // //
              // //       // If the end date is not selected or is null, set it to the start date
              // //       if (end.isBefore(start) || selectedDateEnds == null) {
              // //         end =
              // //             start; // Set the end date to the start date if not selected
              // //       }
              // //       selectedDateEnds = end;
              // //       selectedDateStarts = start;
              // //
              // //       startsController.text = dateFormatConfirmed(selectedDateStarts!, context);
              // //       fromDate = dateFormatConfirmed(start, context);
              // //       toDate = dateFormatConfirmed(end, context);
              // //     });
              //   },
              //   onCancelClick: () {
              //     setState(() {
              //       // Handle cancellation if necessary
              //     });
              //   },
              // );
            },
            controller: startsController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.selectdate,
              hintStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: AppColors.greyForgetColor,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: (50.h - 20.sp) / 2,
                horizontal: 10.w,
              ),
              // contentPadding: EdgeInsets.only(
              //     bottom: 15.h, left: 10.w,right: 10.w
              // ),
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  Widget endsField(isLightTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomText(
              text: AppLocalizations.of(context)!.ends,
              // text: getTranslated(context, 'myweeklyTask'),
              color: Theme.of(context).colorScheme.textClrChange,
              size: 16,
              fontWeight: FontWeight.w700,
            ),
            const CustomText(
              text: " *",
              // text: getTranslated(context, 'myweeklyTask'),
              color: AppColors.red,
              size: 15,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ],
    );
  }

  Widget startTime(isLightTheme) {
    return Expanded(
        child: Container(
            // margin: EdgeInsets.only(left: 20.w, right: 10.w),
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            height: 40.h,
            // margin: EdgeInsets.only(left: 20, right: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyColor),
              borderRadius: BorderRadius.circular(12),
            ),
            // decoration: DesignConfiguration.shadow(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: InkWell(
                highlightColor: Colors.transparent, // No highlight on tap
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    _selectstartTime();
                  });
                },
                child: Row(
                  children: [
                    const HeroIcon(
                        size: 20,
                        HeroIcons.clock,
                        style: HeroIconStyle.outline,
                        color: AppColors.greyForgetColor),
                    SizedBox(
                      width: 10.w,
                    ),
                    CustomText(
                      text: widget.isCreate == true
                          ? (_timestart != null
                              ? _timestart!.format(context)
                              : "Select Time") // Check for null before calling `format`
                          : formattedTimeStart ?? "",
                      fontWeight: FontWeight.w400,
                      size: 14.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                    )
                  ],
                ),
              ),
            )));
  }

  Widget endTimeOfPayment(isLightTheme) {
    return Expanded(
        child: Container(
            // margin: EdgeInsets.only(right: 20.w, left: 10.w),
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            height: 40.h,
            // margin: EdgeInsets.only(left: 20, right: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyColor),
              borderRadius: BorderRadius.circular(12),
            ),
            // decoration: DesignConfiguration.shadow(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: InkWell(
                highlightColor: Colors.transparent, // No highlight on tap
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    _selectendTime();
                  });
                },
                child: Row(
                  children: [
                    const HeroIcon(
                        size: 20,
                        HeroIcons.clock,
                        style: HeroIconStyle.outline,
                        color: AppColors.greyForgetColor),
                    SizedBox(
                      width: 10.w,
                    ),
                    CustomText(
                      text: widget.isCreate == true
                          ? (_timeend != null
                              ? _timeend!.format(context)
                              : "Select Time")
                          : formattedTimeEnd ?? "",
                      fontWeight: FontWeight.w400,
                      size: 14.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                  ],
                ),
              ),
            )));
  }
}
