import 'package:flutter/material.dart';

import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:taskify/bloc/payslip/payslip/payslip/payslip_bloc.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../bloc/payslip/payslip/payslip/payslip_event.dart';
import '../../../bloc/payslip/payslip/payslip/payslip_state.dart';
import '../../../bloc/setting/settings_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../config/constants.dart';
import '../../../config/internet_connectivity.dart';
import '../../../data/model/payslip/payslip_model.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../finance/widgets/payment_method_list.dart';
import '../../leave_request/widgets/single_userfield.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../widgets/custom_date.dart';
import '../../widgets/custom_textfields/custom_textfield.dart';
import '../../widgets/spinbox.dart';
import '../widgets/allowance_list.dart';
import '../widgets/deduction_list.dart';
import '../../../routes/routes.dart';
class CreateEditPayslipScreen extends StatefulWidget {
  final bool? isCreate;
  final PayslipModel payslipModel;
  const CreateEditPayslipScreen(
      {super.key, this.isCreate, required this.payslipModel});

  @override
  State<CreateEditPayslipScreen> createState() =>
      _CreateEditPayslipScreenState();
}

class _CreateEditPayslipScreenState extends State<CreateEditPayslipScreen> {
  // State variables
  PayslipModel? currentPayslip;

  bool? isLoading;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool? hasPermission;
  bool? hasAllDataAccess;
  String? role;

  TextEditingController basicSalaryController = TextEditingController();

  // Separate controllers for allowance title and amount
  List<TextEditingController> allowanceTitleControllers = [];
  List<TextEditingController> allowanceAmountControllers = [];
  List<TextEditingController> deductionTitleControllers = [];
  List<TextEditingController> deductionAmountControllers = [];
  TextEditingController deductionController = TextEditingController();
  TextEditingController leaveDeductionController =
      TextEditingController(text: "0.00");
  TextEditingController deductionAmountController = TextEditingController();
  TextEditingController paidDaysController = TextEditingController();
  TextEditingController overtimePaymentController =
      TextEditingController(text: "0.00");
  TextEditingController descController = TextEditingController();
  String selectedUsersName = '';
  int? selectedUsersNameID;
  String selectedDeductionName = '';
  int? selectedDeductionNameID;
  int? stateSelectedIndex = 1;
  String? selectedLabel;
  final TextEditingController dayController = TextEditingController();
  final TextEditingController paymentDateController = TextEditingController();
  DateTime? selectedDateStarts;
  DateTime? parsedDate;
  String? fromDate;
  String selectedCategory = '';
  int? selectedID;
  double totalAllowancesAmount = 0.0;
  double totalDeductionAmount = 0.0;
  double totalNetPayAmount = 0.0;
  final ValueNotifier<double> workingDaysNumber = ValueNotifier<double>(31);
  final ValueNotifier<double> lossOfPaidDays = ValueNotifier<double>(0);
  final ValueNotifier<double> bonus = ValueNotifier<double>(0);
  final ValueNotifier<double> incentives = ValueNotifier<double>(0);
  final ValueNotifier<double> overTimeHours = ValueNotifier<double>(0);
  final ValueNotifier<double> overTimeRate = ValueNotifier<double>(0);

  final ValueNotifier<double> paidDays = ValueNotifier<double>(0);
  final ValueNotifier<double> overTimePayment = ValueNotifier<double>(0);

  // Connectivity
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  List<TextEditingController> additionalAllowanceTitleControllers = [];
  List<TextEditingController> additionalAllowanceAmountControllers = [];
  // List<String> totalAllowances = [];
  List<Map<String, dynamic>> totalAllowances = [];
  List<Map<String, dynamic>> totalDeductions = [];
  List<int> newlyAddedAllowanceIds = [];
  List<int> newlyAddedDeductionIds = [];
  List<int> allowanceIds = [];
  List<int> deductionsIds = [];

  int? selectedRoleId;
  bool isAllowanceSelected = false;
  bool isDeductionSelected = false;
  String? currency;
  String? singleUsersName;
  int? selectedSingleUsersNameId;
  String? allowanceName;
  int? selectedAllowanceNameId;
  String? deductionName;
  int? selectedDeductionNameId;
  Map<int, String> allowanceMap = {};
  Map<int, String> deductionMap = {};
  List<Allowance> selectedAllowances = [];
  List<Allowance> selectedDeductions = [];
  List<Allowance> additionalAllowances = [];
  DateTime? selectedMonthYear;
  int daysInMonth = 0;

  @override
  void initState() {
    super.initState();

    _initializeConnectivity();
    _initializePayslipData();
  }

  void handleSingleUsersSelected(
      String category, int catId, String email, String profile) {
    setState(() {
      singleUsersName = category;
      selectedSingleUsersNameId = catId;
    });
  }

  void getPaidDays() {
    setState(() {
      paidDays.value = workingDaysNumber.value - lossOfPaidDays.value;
      double result = workingDaysNumber.value - lossOfPaidDays.value;
      paidDaysController.text =
          result % 1 == 0 ? result.toInt().toString() : result.toString();
    });
  }

  void getOvertimePayment() {
    setState(() {
      // overTimePayment.value = overTimeRate.value * overTimeHours.value;
      double result = overTimeRate.value * overTimeHours.value;
      overtimePaymentController.text =
          result % 1 == 0 ? result.toInt().toString() : result.toString();
    });
  }

  void handleSingleAllowanceSelected(
      String category, int catID, String amount) {
    setState(() {
      allowanceName = category;
      selectedAllowanceNameId = catID;
      if (!allowanceMap.containsKey(catID)) {
        // Create new allowance
        Allowance newAllowance =
            Allowance(id: catID, name: category, amount: amount);

        // Insert at the beginning of lists
        selectedAllowances.insert(0, newAllowance); // Add to top
        allowanceMap[catID] = amount;
        allowanceTitleControllers.insert(
            0, TextEditingController(text: category)); // Add to top
        allowanceAmountControllers.insert(
            0, TextEditingController(text: amount)); // Add to top
        newlyAddedAllowanceIds.insert(0, catID); // Add to top

        // Add listener to update amount in real-time
        allowanceAmountControllers[0].addListener(() {
          setState(() {
            selectedAllowances[0].amount = allowanceAmountControllers[0].text;
            allowanceMap[catID] = allowanceAmountControllers[0].text;
            // Update totalAllowances if the allowance exists
            var allowanceIndex =
                totalAllowances.indexWhere((item) => item['id'] == catID);
            if (allowanceIndex != -1) {
              totalAllowances[allowanceIndex]['amount'] =
                  allowanceAmountControllers[0]
                      .text
                      .replaceAll(RegExp(r'[^\d.]'), '');
              calculateTotalAllowances();
              totalNetPay();
            }
          });
        });

        isAllowanceSelected = true;
      }
    });
  }

  void handleSingleDeductionSelected(
      String category, int catID, String amount) {
    setState(() {
      deductionName = category;
      selectedDeductionNameId = catID;
      if (!deductionMap.containsKey(catID)) {
        selectedDeductions.insert(
            0, Allowance(id: catID, name: category, amount: amount));
        deductionMap[catID] = amount;
        deductionTitleControllers.insert(
            0, TextEditingController(text: category));
        deductionAmountControllers.insert(
            0, TextEditingController(text: amount));
        newlyAddedDeductionIds.insert(0, catID);
        deductionAmountControllers[0].addListener(() {
          setState(() {
            selectedDeductions[0].amount = deductionAmountControllers[0].text;
            deductionMap[catID] = deductionAmountControllers[0].text;
            var deductionIndex =
                totalDeductions.indexWhere((item) => item['id'] == catID);
            if (deductionIndex != -1) {
              totalDeductions[deductionIndex]['amount'] =
                  deductionAmountControllers[0]
                      .text
                      .replaceAll(RegExp(r'[^\d.]'), '');
              calculateTotalDeduction();
              totalNetPay();
            }
          });
        });
        isDeductionSelected = true;
        deductionName = '';
        selectedDeductionNameId = null;
      }
    });
  }

  void _handlePaymentmethodSelected(String category, int catID) {
    setState(() {
      selectedCategory = category;
      selectedID = catID;
      print("selectedCategory$selectedCategory");
      print("selectedID$selectedID");
    });
  }

  void _initializeConnectivity() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() => _connectionStatus = results);
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() => _connectionStatus = value);
        });
      }
    });
  }

  void _initializePayslipData() {
    currency = context.read<SettingsBloc>().currencySymbol;

    if (widget.isCreate == false && widget.payslipModel != "") {
      _setupEditMode();
    } else {
      paidDaysController.text = workingDaysNumber.value.toString();
    }
  }

  void _setupEditMode() {
    currentPayslip = widget.payslipModel;
    singleUsersName = currentPayslip!.user!.name!;
    selectedSingleUsersNameId = currentPayslip!.user!.id!;
    fromDate = currentPayslip!.paymentDate!.split(' ').first;

    // Parse month and set daysInMonth
    final format = DateFormat("yyyy-MM");
    selectedMonthYear = currentPayslip!.month != null
        ? format.parse(currentPayslip!.month!)
        : DateTime.now();
    daysInMonth = DateUtils.getDaysInMonth(
        selectedMonthYear!.year, selectedMonthYear!.month);
    print("Days in month: $daysInMonth");

    // Initialize working days
    workingDaysNumber.value = currentPayslip!.workingDays!.toDouble();
    lossOfPaidDays.value = currentPayslip!.lopDays!.toDouble();
    paidDaysController.text = currentPayslip!.workingDays!.toString();
    basicSalaryController.text =
        currentPayslip!.basicSalary.toString().replaceAll(RegExp(r'\.0$'), '');
    leaveDeductionController.text = currentPayslip!.leaveDeduction.toString();
    bonus.value = currentPayslip!.bonus!.toDouble();
    incentives.value = currentPayslip!.incentives!.toDouble();
    overTimeHours.value = currentPayslip!.otHours!.toDouble();
    overTimeRate.value = currentPayslip!.otRate!.toDouble();
    overtimePaymentController.text = currentPayslip!.otPayment.toString();
    stateSelectedIndex = currentPayslip!.status == 0 ? 0 : 1;
    DateTime parsedDate = parseDateStringFromApi(currentPayslip!.paymentDate!);

    paymentDateController.text = dateFormatConfirmed(parsedDate, context);
    paymentDateController.text = currentPayslip!.paymentDate!.split(' ').first;
    selectedCategory = currentPayslip!.paymentMethod!;
    selectedID = currentPayslip!.paymentMethodId ?? 0;
    descController.text = currentPayslip!.note ?? '';

    // Initialize allowances
    if (currentPayslip!.allowances != null &&
        currentPayslip!.allowances!.isNotEmpty) {
      for (var allowance in currentPayslip!.allowances!) {
        selectedAllowances.add(Allowance(
          id: allowance.id ?? 0,
          name: allowance.title ?? "",
          amount: allowance.amount.toString(),
        ));
        allowanceMap[allowance.id ?? 0] = allowance.amount.toString();
        allowanceTitleControllers
            .add(TextEditingController(text: allowance.title));
        allowanceAmountControllers
            .add(TextEditingController(text: allowance.amount.toString()));
        totalAllowances
            .add({'id': allowance.id, 'amount': allowance.amount.toString()});
        allowanceIds.add(allowance.id ?? 0);
        allowanceAmountControllers.last.addListener(() {
          setState(() {
            selectedAllowances[allowanceAmountControllers.length - 1].amount =
                allowanceAmountControllers.last.text;
            allowanceMap[allowance.id ?? 0] =
                allowanceAmountControllers.last.text;
            totalAllowances[allowanceAmountControllers.length - 1]['amount'] =
                allowanceAmountControllers.last.text
                    .replaceAll(RegExp(r'[^\d.]'), '');
            calculateTotalAllowances();
            totalNetPay();
          });
        });
      }
      isAllowanceSelected = true;
      calculateLeaveDeduction(lossOfPaidDays.value, workingDaysNumber.value,
          basicSalaryController.text);
      calculateTotalAllowances();
    }

    // Initialize deductions
    if (currentPayslip!.deduction != null &&
        currentPayslip!.deduction!.isNotEmpty) {
      for (var deduction in currentPayslip!.deduction!) {
        selectedDeductions.add(Allowance(
          id: deduction.id ?? 0,
          name: deduction.title ?? "",
          amount: deduction.amount.toString(),
        ));
        deductionMap[deduction.id ?? 0] = deduction.amount.toString();
        deductionTitleControllers
            .add(TextEditingController(text: deduction.title));
        deductionAmountControllers
            .add(TextEditingController(text: deduction.amount.toString()));
        totalDeductions
            .add({'id': deduction.id, 'amount': deduction.amount.toString()});
        deductionsIds.add(deduction.id ?? 0);
        deductionAmountControllers.last.addListener(() {
          setState(() {
            selectedDeductions[deductionAmountControllers.length - 1].amount =
                deductionAmountControllers.last.text;
            deductionMap[deduction.id ?? 0] =
                deductionAmountControllers.last.text;
            totalDeductions[deductionAmountControllers.length - 1]['amount'] =
                deductionAmountControllers.last.text
                    .replaceAll(RegExp(r'[^\d.]'), '');
            calculateTotalDeduction();
            totalNetPay();
          });
        });
      }
      isDeductionSelected = true;
      calculateTotalDeduction();
    }

    // Update dependent fields
    getPaidDays();
    // if() calculateLeaveDeduction(workingDaysNumber.value, workingDaysNumber.value,
    //      basicSalaryController.text);
    totalNetPay();
  }

  // void _initializeDates() {
  //   basicSalaryController.text = currentPayslip!.basicSalary.toString();
  //   daysInMonth = DateUtils.getDaysInMonth(
  //     DateTime.now().year,
  //     DateTime.now().month,
  //   ); // Sync initial text
  //   calculateLeaveDeduction(workingDaysNumber.value, workingDaysNumber.value,
  //       basicSalaryController.text);
  //
  //
  // }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    for (var controller in allowanceTitleControllers) {
      controller.dispose();
    }
    for (var controller in allowanceAmountControllers) {
      controller.dispose();
    }
    for (var controller in deductionTitleControllers) {
      controller.dispose();
    }
    for (var controller in deductionAmountControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  double calculateTotalAllowances() {
    double total = 0;
    for (var allowance in totalAllowances) {
      String amount = allowance['amount'] ?? '0';
      String cleanAmount = amount.replaceAll(RegExp(r'[^\d.]'), '');
      total += double.tryParse(cleanAmount) ?? 0;
    }
    setState(() {
      totalAllowancesAmount = total;
    });
    return total;
  }

  double calculateTotalDeduction() {
    double total = 0;
    for (var deduction in totalDeductions) {
      String amount = deduction['amount'] ?? '0';
      String cleanAmount = amount.replaceAll(RegExp(r'[^\d.]'), '');
      double parsedAmount = double.tryParse(cleanAmount) ?? 0;
      print("Deduction ID: ${deduction['id']}, Amount: $parsedAmount");
      total += parsedAmount;
    }
    setState(() {
      totalDeductionAmount = total;
    });
    print("Calculated total deduction: $total");
    print("Calculated total deduction: $totalDeductionAmount");
    return total;
  }

  void calculateLeaveDeduction(
      double lopDays, double daysInMonth, String basicSalary) {
    setState(() {
      // Directly parse without stripping decimals
      double? salary = double.tryParse(basicSalary.trim());

      if (salary == null || selectedMonthYear == null) {
        leaveDeductionController.text = "0.00";
        return;
      }

      double perDaySalary = salary / daysInMonth;
      double deduction = perDaySalary * lopDays;
      print("✅ deduction deduction: $deduction");
      leaveDeductionController.text = deduction.toStringAsFixed(2);

      print("✅ Salary: $salary");
      print("📅 Days in Month: $daysInMonth");
      print("💸 Per Day Salary: $perDaySalary");
      print("🧾 LOP Days: $lopDays");
      print("🧮 Deduction: $deduction");
      print("🧮 leaveDeductionController: ${leaveDeductionController.text}");
    });
  }

  double totalNetPay() {
    // Clean & parse numeric inputs
    double basicSalary =
        double.tryParse(basicSalaryController.text.trim()) ?? 0.0;
    print("Basic Salary: $basicSalary");

    double leaveDeduction =
        double.tryParse(leaveDeductionController.text.trim()) ?? 0.0;
    print("Leave Deduction: $leaveDeduction");

    double overtimePayment =
        double.tryParse(overtimePaymentController.text.trim()) ?? 0.0;

    // Sum of earnings
    double totalEarnings = basicSalary +
        totalAllowancesAmount +
        (bonus.value) +
        (incentives.value) +
        overtimePayment;
    print("bhhb $totalEarnings");
    print("leaveDeduction $leaveDeduction");
    // Total deduction
    double totalDeductions = leaveDeduction + totalDeductionAmount;
    print("totalDeductions $totalDeductions");
    // Net pay calculation
    double netPay = totalEarnings - totalDeductions;
    print("bhhb $netPay");
    // Update the state
    setState(() {
      totalNetPayAmount = netPay;
    });

    return netPay;
  }



  void _validateAndSubmitForm() {
    if (widget.isCreate == true) {
      onCreatePayslip();
    } else {
      onUpdatePayslip(currentPayslip!);
    }
  }

  void onCreatePayslip() {
    isLoading = true;
    print("ghjjk ${fromDate} $selectedID");
    if (selectedSingleUsersNameId != null &&
        selectedMonthYear != null &&
        basicSalaryController.text.isNotEmpty &&
        // workingDaysNumber.value != null &&
        // lossOfPaidDays.value != null &&
        paidDaysController.text.isNotEmpty &&
        // bonus != null &&
        // incentives != null &&
        leaveDeductionController.text.isNotEmpty &&
        // overTimeRate.value != null &&
        overtimePaymentController.text.isNotEmpty) {
      if (stateSelectedIndex == 1) {
        if (fromDate == null && selectedID == null) {
          print("ghjjkwe w ${fromDate} $selectedID");
          flutterToastCustom(
            msg: AppLocalizations.of(context)!
                .pleasefillpaymentdateandpaymentmethod,
          );
        }
      } else {
        context.read<PayslipBloc>().add(PayslipCreated(
            userId: selectedSingleUsersNameId ?? 0,
            month: DateFormat('yyyy-MM').format(selectedMonthYear!),
            basicSalary: double.parse(basicSalaryController.text),
            workingDays: workingDaysNumber.value.toInt(),
            lopDays: lossOfPaidDays.value.toInt(),
            paidDays: double.parse(paidDaysController.text).toInt(),
            bonus: bonus.value.toDouble(),
            incentives: incentives.value.toDouble(),
            leaveDeduction: double.parse(leaveDeductionController.text).toInt(),
            otHours: overTimeHours.value.toInt(),
            otRate: overTimeRate.value.toDouble(),
            otPayment: double.parse(overtimePaymentController.text),
            totalAllowance: totalAllowancesAmount.toInt(),
            totalDeductions: totalDeductionAmount.toInt(),
            totalEarnings: 0.0,
            netPay: totalNetPayAmount,
            paymentMethodId: selectedID != null ? selectedID! : null,
            paymentDate: fromDate != null
                ? DateFormat('yyyy-MM-dd').format(DateTime.parse(fromDate!))
                : null,
            note: descController.text,
            allowances: allowanceIds,
            deductions: deductionsIds,
            status: stateSelectedIndex ?? 0));
        _listenToPayslipBloc(context.read<PayslipBloc>());
      }
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void _listenToPayslipBloc(PayslipBloc bloc) {
    bloc.stream.listen((state) {
      print("gbhjnmk $state");
      if (state is PayslipCreateSuccess) {
        _handlePayslipSuccess();
      } else if (state is PayslipCreateError) {
        _handlePayslipError(state.errorMessage);
      } else if (state is PayslipEditSuccess) {
        _handlePayslipEditSuccess();
      } else if (state is PayslipEditError) {
        _handlePayslipError(state.errorMessage);
      }
    });
  }

  void _handlePayslipSuccess() {
    isLoading = false;
    if (mounted) {
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.createdsuccessfully,
          color: AppColors.primary);
      context.read<PayslipBloc>().add(AllPayslipList());
      Navigator.pop(context);
    }
  }

  void _handlePayslipEditSuccess() {
    if (mounted) {
      isLoading = false;
      context.read<PayslipBloc>().add(AllPayslipList());
      Navigator.pop(context);
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.updatedsuccessfully,
          color: AppColors.primary);
    }
  }

  void onUpdatePayslip(PayslipModel currentPayslip) {
    isLoading = true;
    print("📤 Submitting Payslip Update:");
    print("➡ ID: ${currentPayslip.id}");
    print("➡ User ID: $selectedSingleUsersNameId");
    print("➡ Month: ${DateFormat('yyyy-MM').format(selectedMonthYear!)}");
    print("➡ Basic Salary: ${basicSalaryController.text}");
    print("➡ Working Days: ${workingDaysNumber.value.toInt()}");
    print("➡ LOP Days: ${lossOfPaidDays.value.toInt()}");
    print("➡ Paid Days: ${paidDaysController.text}");
    print("➡ Bonus: ${bonus.value.toDouble()}");
    print("➡ Incentives: ${incentives.value.toDouble()}");
    print("➡ Leave Deduction: ${leaveDeductionController.text}");
    print("➡ OT Hours: ${overTimeHours.value.toInt()}");
    print("➡ OT Rate: ${overTimeRate.value.toDouble()}");
    print("➡ OT Payment: ${overtimePaymentController.text}");
    print("➡ Total Allowance: $totalAllowancesAmount");
    print("➡ Total Deductions: $totalDeductionAmount");
    print("➡ Net Pay: $totalNetPayAmount");
    print("➡ Payment Method ID: $selectedID");
    print(
        "➡ Payment Date: ${fromDate != "" ? DateFormat('yyyy-MM-dd').format(DateTime.parse(fromDate!)) : null}");
    print("➡ Note: ${descController.text}");
    print("➡ Allowances: $allowanceIds");
    print("➡ Deductions: $deductionsIds");
    print("➡ Status: $stateSelectedIndex");

    if (selectedSingleUsersNameId != null &&
        selectedMonthYear != null &&
        basicSalaryController.text.isNotEmpty &&
        // workingDaysNumber.value != null &&
        // lossOfPaidDays.value != null &&
        paidDaysController.text.isNotEmpty &&
        // bonus != null &&
        // incentives != null &&
        leaveDeductionController.text.isNotEmpty &&
        // overTimeRate.value != null &&
        overtimePaymentController.text.isNotEmpty &&
        stateSelectedIndex != null) {
      print("ghjjk ${fromDate} $selectedID");
      print("ghjjk ${stateSelectedIndex} $selectedID");
      if (stateSelectedIndex == 1 &&
          (fromDate == null || fromDate == "" || selectedID == 0)) {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!
              .pleasefillpaymentdateandpaymentmethod,
        );
        return; // Stop further execution
      } else {
        context.read<PayslipBloc>().add(UpdatePayslip(
            id: currentPayslip.id!,
            userId: selectedSingleUsersNameId ?? 0,
            month: DateFormat('yyyy-MM').format(selectedMonthYear!),
            basicSalary: double.parse(basicSalaryController.text),
            workingDays: workingDaysNumber.value.toInt(),
            lopDays: lossOfPaidDays.value.toInt(),
            paidDays: double.parse(paidDaysController.text).toInt(),
            bonus: bonus.value.toDouble(),
            incentives: incentives.value.toDouble(),
            leaveDeduction: double.parse(leaveDeductionController.text).toInt(),
            otHours: overTimeHours.value.toInt(),
            otRate: overTimeRate.value.toDouble(),
            otPayment: double.parse(overtimePaymentController.text),
            totalAllowance: totalAllowancesAmount.toInt(),
            totalDeductions: totalDeductionAmount.toInt(),
            totalEarnings: 0.0,
            netPay: totalNetPayAmount,
            paymentMethodId: selectedID ?? 0,
            paymentDate: fromDate != ""
                ? DateFormat('yyyy-MM-dd').format(DateTime.parse(fromDate!))
                : null,
            // Safely passes null
            // <-- Conditionally null
            //   status: stateSelectedIndex ?? 0,
            note: descController.text,
            allowances: allowanceIds,
            deductions: deductionsIds,
            status: stateSelectedIndex ?? 0));

        _listenToPayslipBloc(context.read<PayslipBloc>());
      }
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void _handlePayslipError(String errorMessage) {
    isLoading = false;
    flutterToastCustom(msg: errorMessage);
    BlocProvider.of<PayslipBloc>(context).add(AllPayslipList());
  }

  void _pickMonthYear(BuildContext context) async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: selectedMonthYear ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedMonthYear = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    bool isLightTheme = currentTheme is LightThemeState;
    double additionalTotal = 0.0;

    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, Object? result) async {
              if (!didPop) {
                router.pop();
              }
            },
            child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.backGroundColor,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(isLightTheme),
                    SizedBox(height: 30.h),
                    _buildForm(isLightTheme, additionalTotal),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildHeader(bool isLightTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 0.h),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    isLightTheme
                        ? MyThemes.lightThemeShadow
                        : MyThemes.darkThemeShadow,
                  ],
                ),
                child: BackArrow(
                  onTap: () {
                    router.pop(context);
                  },
                  title: widget.isCreate == true
                      ? AppLocalizations.of(context)!.createpayslip
                      : AppLocalizations.of(context)!.editpayslip,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isLightTheme, additionalTotal) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15.h),
            _buildFormFields(isLightTheme, additionalTotal),
            _buildActionButtons(),
            SizedBox(
              height: 50.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(bool isLightTheme, additionalTotal) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleUserField(
          title: AppLocalizations.of(context)!.selectuser,
          isRequired: true,
          isEditLeaveReq: widget.isCreate,
          userId: [selectedSingleUsersNameId ?? 0],
          isCreate: widget.isCreate!,
          name: singleUsersName,
          from: true,
          index: 0,
          onSelected: handleSingleUsersSelected,
        ),
        SizedBox(
          height: 15.h,
        ),
        payslipMonth(),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          currency: true,
          onchange: (value) {
            setState(() {
              calculateLeaveDeduction(
                  lossOfPaidDays.value, workingDaysNumber.value, value!);
            });
          },
          keyboardType: TextInputType.number,
          title: AppLocalizations.of(context)!.basicsalary,
          hinttext: AppLocalizations.of(context)!.pleaseenteramount,
          controller: basicSalaryController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: true,
        ),
        SizedBox(
          height: 15.h,
        ),
        // NumDays(AppLocalizations.of(context)!.basicsalary, "basicsalary", true),
        // SizedBox(
        //   height: 15.h,
        // ),
        NumDays(AppLocalizations.of(context)!.workingdays, "workingDays", true),
        SizedBox(
          height: 15.h,
        ),
        NumDays(
            AppLocalizations.of(context)!.lossofpaydays, "lossOfPayDays", true),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          isDetails: true,
          keyboardType: TextInputType.number,
          title: AppLocalizations.of(context)!.paiddays,
          hinttext: AppLocalizations.of(context)!.pleaseenteramount,
          controller: paidDaysController,
          onSaved: (value) {},
          readonly: true,
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: true,
        ),
        SizedBox(
          height: 15.h,
        ),
        NumDays(AppLocalizations.of(context)!.bonus, "bonus", true),
        SizedBox(
          height: 15.h,
        ),
        NumDays(AppLocalizations.of(context)!.incentives, "incentives", true),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          currency: true,
          readonly: true,
          isDetails: true,
          keyboardType: TextInputType.number,
          title: AppLocalizations.of(context)!.leavededuction,
          hinttext: AppLocalizations.of(context)!.pleaseenteramount,
          controller: leaveDeductionController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: true,
        ),
        SizedBox(
          height: 15.h,
        ),
        NumDays(AppLocalizations.of(context)!.overtimehours, "overtimehours",
            false),
        SizedBox(
          height: 15.h,
        ),
        NumDays(
            AppLocalizations.of(context)!.overtimerate, "overtimerate", true),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          currency: true,
          keyboardType: TextInputType.number,
          title: AppLocalizations.of(context)!.overtimepayment,
          hinttext: AppLocalizations.of(context)!.pleaseenteramount,
          controller: overtimePaymentController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: true,
        ),
        SizedBox(
          height: 15.h,
        ),
        paymentStatus(),
        SizedBox(
          height: 15.h,
        ),
        paymentDate(isLightTheme),
        SizedBox(
          height: 15.h,
        ),
        PaymentMethodList(
          isRequired: false,
          isCreate: widget.isCreate!,
          payment: 0,
          name: selectedCategory,
          onSelected: _handlePaymentmethodSelected,
        ),
        SizedBox(
          height: 15.h,
        ),
        AllowanceField(
          isRequired: false,
          isEditLeaveReq: widget.isCreate,
          allowanceId: [selectedAllowanceNameId ?? 0],
          isCreate: widget.isCreate!,
          name: allowanceName,
          from: true,
          index: 0,
          onSelected: handleSingleAllowanceSelected,
        ),
        SizedBox(
          height: 15.h,
        ),
        allowances(isLightTheme),
        SizedBox(
          height: 15.h,
        ),
        deduction(isLightTheme),
        SizedBox(
          height: 20.h,
        ),
        netPayable(),
        SizedBox(
          height: 20.h,
        ),
        CustomTextFields(
          height: 112.h,
          keyboardType: TextInputType.multiline,
          title: AppLocalizations.of(context)!.note,
          hinttext: AppLocalizations.of(context)!.note,
          controller: descController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: false,
        ),
        SizedBox(
          height: 50.h,
        ),
      ],
    );
  }

  Widget netPayable() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Row(
        children: [
          CustomText(
            text: "${AppLocalizations.of(context)!.netpayable} ($currency) : ",
            fontWeight: FontWeight.w500,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            size: 15.sp,
            color: Theme.of(context).colorScheme.textClrChange,
          ),
          CustomText(
            text: totalNetPayAmount.toString(),
            fontWeight: FontWeight.w500,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            size: 13.sp,
            color: Theme.of(context).colorScheme.textClrChange,
          ),
        ],
      ),
    );
  }

  Widget allowances(isLightTheme) {
    return Column(
      children: [
        if (isAllowanceSelected)
          Column(
            children: selectedAllowances.asMap().entries.map((entry) {
              int index = entry.key;
              Allowance allowance = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Allowance Name
                    Expanded(
                      flex: 4,
                      child: CustomTextFields(
                        currency: false,
                        keyboardType: TextInputType.text,
                        title: AppLocalizations.of(context)!.allowance,
                        hinttext:
                            AppLocalizations.of(context)!.pleaseenteramount,
                        controller: allowanceTitleControllers[index],
                        onSaved: (value) {
                          setState(() {
                            selectedAllowances[index].name = value ?? '';
                          });
                        },
                        onFieldSubmitted: (value) {
                          setState(() {
                            selectedAllowances[index].name = value;
                          });
                        },
                        isLightTheme: isLightTheme,
                        isRequired: true,
                      ),
                    ),

                    // Allowance Amount
                    Expanded(
                      flex: 4,
                      child: CustomTextFields(
                        currency: true,
                        keyboardType: TextInputType.number,
                        title: AppLocalizations.of(context)!.amount,
                        hinttext: AppLocalizations.of(context)!.amount,
                        controller: allowanceAmountControllers[index],
                        onSaved: (value) {
                          setState(() {
                            allowanceMap[allowance.id] = value ?? '';
                            selectedAllowances[index].amount = value ?? '';
                          });
                        },
                        onFieldSubmitted: (value) {
                          setState(() {
                            allowanceMap[allowance.id] = value;
                            selectedAllowances[index].amount = value;
                          });
                        },
                        isLightTheme: isLightTheme,
                        isRequired: true,
                      ),
                    ),

                    // Remove Button
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          int id = selectedAllowances[index].id;

                          // Remove from all related lists/maps
                          allowanceMap.remove(id);
                          selectedAllowances.removeAt(index);
                          allowanceTitleControllers.removeAt(index);
                          allowanceAmountControllers.removeAt(index);
                          isAllowanceSelected = selectedAllowances.isNotEmpty;
                          totalAllowances
                              .removeWhere((item) => item['id'] == id);
                          allowanceIds.remove(id);
                          newlyAddedAllowanceIds.remove(id);

                          calculateTotalAllowances();
                          totalNetPay();

                          flutterToastCustom(
                            msg: "Allowance removed successfully.",
                            color: AppColors.primary,
                          );
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 6.h, right: 18.w),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: HeroIcon(
                            HeroIcons.minus,
                            style: HeroIconStyle.solid,
                            color: AppColors.whiteColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    // Add Button (only if not already added)
                    if (!totalAllowances
                        .any((item) => item['id'] == allowance.id))
                      Padding(
                        padding: EdgeInsets.only(bottom: 6.h, right: 18.w),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            String amount = selectedAllowances[index].amount;
                            int id = selectedAllowances[index].id;

                            if (amount.isNotEmpty) {
                              setState(() {
                                final cleanAmount =
                                    amount.replaceAll(RegExp(r'[^\d.]'), '');
                                totalAllowances
                                    .add({'id': id, 'amount': cleanAmount});
                                allowanceIds.add(id);

                                calculateTotalAllowances();
                                totalNetPay();

                                print("Current allowance IDs: $allowanceIds");
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: HeroIcon(
                              HeroIcons.plus,
                              style: HeroIconStyle.solid,
                              color: AppColors.whiteColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),

        if (isAllowanceSelected) SizedBox(height: 15.h),

        // Total Allowances Display
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Row(
            children: [
              CustomText(
                text:
                    "${AppLocalizations.of(context)!.totalallowances} ($currency) : ",
                fontWeight: FontWeight.w500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                size: 15.sp,
                color: Theme.of(context).colorScheme.textClrChange,
              ),
              CustomText(
                text: "${totalAllowancesAmount}",
                fontWeight: FontWeight.w500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                size: 13.sp,
                color: Theme.of(context).colorScheme.textClrChange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget deduction(isLightTheme) {
    return Column(
      children: [
        DeductionField(
          isRequired: false,
          isEditLeaveReq: widget.isCreate,
          deductionId: [selectedDeductionNameId ?? 0],
          isCreate: widget.isCreate!,
          name: deductionName,
          from: true,
          index: 0,
          onSelected: handleSingleDeductionSelected,
        ),
        SizedBox(
          height: 15.h,
        ),
        if (isDeductionSelected)
          Column(
            children: selectedDeductions.asMap().entries.map((entry) {
              int index = entry.key;
              Allowance deduction = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 4,
                      child: CustomTextFields(
                        currency: false,
                        keyboardType: TextInputType.text,
                        title: AppLocalizations.of(context)!.deductions,
                        hinttext:
                            AppLocalizations.of(context)!.pleaseenteramount,
                        controller: deductionTitleControllers[index],
                        onSaved: (value) {
                          setState(() {
                            selectedDeductions[index].name = value ?? '';
                          });
                        },
                        onFieldSubmitted: (value) {
                          setState(() {
                            selectedDeductions[index].name = value;
                          });
                        },
                        isLightTheme: isLightTheme,
                        isRequired: true,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: CustomTextFields(
                        currency: true,
                        keyboardType: TextInputType.number,
                        title: AppLocalizations.of(context)!.amount,
                        hinttext: AppLocalizations.of(context)!.amount,
                        controller: deductionAmountControllers[index],
                        onSaved: (value) {
                          setState(() {
                            deductionMap[deduction.id] = value ?? '';
                            selectedDeductions[index].amount = value ?? '';
                            if (deductionsIds.contains(deduction.id)) {
                              totalDeductions[index]['amount'] = value ?? '0';
                              calculateTotalDeduction();
                              totalNetPay();
                            }
                          });
                        },
                        onFieldSubmitted: (value) {
                          setState(() {
                            deductionMap[deduction.id] = value;
                            selectedDeductions[index].amount = value;
                            if (deductionsIds.contains(deduction.id)) {
                              totalDeductions[index]['amount'] = value;
                              calculateTotalDeduction();
                              totalNetPay();
                            }
                          });
                        },
                        isLightTheme: isLightTheme,
                        isRequired: true,
                      ),
                    ),

                    // Only show remove for non-first item
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          int id = selectedDeductions[index].id;

                          totalDeductions
                              .removeWhere((item) => item['id'] == id);
                          deductionMap.remove(id);
                          selectedDeductions.removeAt(index);
                          deductionTitleControllers.removeAt(index);
                          deductionAmountControllers.removeAt(index);
                          isDeductionSelected = selectedDeductions.isNotEmpty;
                          calculateTotalDeduction();
                          deductionsIds = totalDeductions
                              .map<int>((item) => item['id'] as int)
                              .toList();

                          flutterToastCustom(
                            msg: "Deduction removed successfully.",
                            color: AppColors.primary,
                          );
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 6.h, right: 18.w),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: HeroIcon(
                            HeroIcons.minus,
                            style: HeroIconStyle.solid,
                            color: AppColors.whiteColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    if (!totalDeductions
                        .any((item) => item['id'] == deduction.id))
                      Padding(
                        padding: EdgeInsets.only(bottom: 6.h, right: 18.w),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            String amount = selectedDeductions[index].amount;
                            int id = selectedDeductions[index].id;

                            if (amount.isNotEmpty) {
                              setState(() {
                                final cleanAmount =
                                    amount.replaceAll(RegExp(r'[^\d.]'), '');
                                totalDeductions
                                    .add({'id': id, 'amount': cleanAmount});
                                calculateTotalDeduction();
                                deductionsIds = totalDeductions
                                    .map<int>((item) => item['id'] as int)
                                    .toList();
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: HeroIcon(
                              HeroIcons.plus,
                              style: HeroIconStyle.solid,
                              color: AppColors.whiteColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        if (isDeductionSelected)
          SizedBox(
            height: 15.h,
          ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Row(
            children: [
              CustomText(
                text:
                    "${AppLocalizations.of(context)!.totaldeductions} ($currency) : ",
                fontWeight: FontWeight.w500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                size: 15.sp,
                color: Theme.of(context).colorScheme.textClrChange,
              ),
              CustomText(
                text: totalDeductionAmount.toString(),
                fontWeight: FontWeight.w500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                size: 13.sp,
                color: Theme.of(context).colorScheme.textClrChange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget paymentStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.paymentstatus,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16.sp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w700,
              ),
              CustomText(
                text: " *",
                color: AppColors.red,
                size: 15,
                fontWeight: FontWeight.w400,
              )
            ],
          ),
        ),
        SizedBox(height: 5.h),
        Container(
            height: 40.h,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ToggleSwitch(
              cornerRadius: 11.r,
              activeBgColor: const [AppColors.primary],
              inactiveBgColor: Colors.transparent,
              minHeight: 40.h,
              minWidth: double.infinity,
              initialLabelIndex: stateSelectedIndex,
              totalSwitches: 2,
              labels: const ['UnPaid', 'Paid'],
              onToggle: (index) {
                setState(() {
                  if (hasPermission == false) {
                    stateSelectedIndex == 0;
                  } else {
                    stateSelectedIndex = index ?? 0;
                    selectedLabel = index == 0 ? 'UnPaid' : 'Paid';
                  }
                });
              },
            )),
      ],
    );
  }

  Widget paymentDate(isLightTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: DatePickerWidget(
        width: true,
        size: 12.sp,
        star: stateSelectedIndex == 0 ? false : true,
        dateController: paymentDateController,
        title: AppLocalizations.of(context)!.paymentdate,
        onTap: () async {
          final DateTime? dateTime = await showOmniDateTimePicker(
              firstDate: DateTime(1910),
              context: context,
              type: OmniDateTimePickerType.date,
              initialDate: parsedDate ?? DateTime.now(),
              isShowSeconds: false,
              barrierColor: Theme.of(context).colorScheme.containerDark);
          setState(() {
            selectedDateStarts = dateTime!;
            fromDate = dateFormatConfirmedToApi(selectedDateStarts!);
            paymentDateController.text =
                dateFormatConfirmed(selectedDateStarts!, context);
          });
        },
        isLightTheme: isLightTheme,
      ),
    );
  }

  Widget _buildActionButtons() {
    return BlocBuilder<PayslipBloc, PayslipState>(
      builder: (context, state) {
        final isLoading = state is PayslipCreateSuccessLoading ||
            state is PayslipEditSuccessLoading;
        return CreateCancelButtom(
          isLoading: isLoading,
          isCreate: widget.isCreate,
          onpressCancel: () => Navigator.pop(context),
          onpressCreate: () => _validateAndSubmitForm(),
        );
      },
    );
  }

  Widget NumDays(String title, String label, bool isRequired) {
    print("esdfgbv ${workingDaysNumber.value}");
    print("esdfgbv ${daysInMonth}");
    double min = 0;
    double max = 0;
    double initial = 0;
    double step = 1;
    print("initial $initial");
    switch (label) {
      case "workingDays":
        min = 0;
        max = 31.0;
        initial = widget.isCreate == true
            ? daysInMonth.toDouble()
            : workingDaysNumber.value;
        step = 0.5; // Allow half-day increments
        break;
      case "basicsalary":
        min = 0;
        max = double.infinity;
        initial = 0;
        step = 1;
        break;

      case "lossOfPayDays":
        min = 0;
        max = 31;
        initial = widget.isCreate == true ? 0 : lossOfPaidDays.value;
        step = 0.5;
        break;
      case "overtimehours":
        min = 0;
        max = 100;
        initial = widget.isCreate == true ? 0 : overTimeHours.value;
        step = 0.5;
        break;
      case "overtimerate":
        min = 0;
        max = 100000;
        initial = widget.isCreate == true ? 0 : overTimeRate.value;
        step = 1;
        break;
      case "bonus":
        min = 0;
        max = 100000;
        initial = widget.isCreate == true ? 0 : bonus.value;
        step = 1;
        break;
      case "incentives":
        min = 0;
        max = 100000;
        initial = widget.isCreate == true ? 0 : incentives.value;
        step = 1;
        break;
      default:
        min = 0;
        max = 100;
        initial = 0;
        step = 0.5;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Row(
            children: [
              CustomText(
                text: title,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              isRequired == true
                  ? CustomText(
                      text: " *",
                      color: AppColors.red,
                      size: 15,
                      fontWeight: FontWeight.w400,
                    )
                  : SizedBox.shrink()
            ],
          ),
        ),
        SizedBox(height: 5.h),
        ValueListenableBuilder<double>(
          valueListenable: label == "workingDays"
              ? workingDaysNumber
              : label == "lossOfPayDays"
                  ? lossOfPaidDays
                  : label == "overtimehours"
                      ? overTimeHours
                      : label == "overtimerate"
                          ? overTimeRate
                          : label == "bonus"
                              ? bonus
                              : incentives,
          builder: (context, value, child) {
            return NumberSpinner(
              initialValue: value,
              min: min,
              max: max,
              step: step,
              isDaysField: label == "workingDays" ||
                  label == "lossOfPayDays", // Add this line
              onChanged: (newValue) {
                switch (label) {
                  case "workingDays":
                    workingDaysNumber.value = newValue;
                    getPaidDays();
                    calculateLeaveDeduction(lossOfPaidDays.value,
                        workingDaysNumber.value, basicSalaryController.text);
                    break;
                  case "lossOfPayDays":
                    lossOfPaidDays.value = newValue;
                    getPaidDays();
                    calculateLeaveDeduction(lossOfPaidDays.value,
                        workingDaysNumber.value, basicSalaryController.text);
                    break;
                  case "overtimehours":
                    overTimeHours.value = newValue;
                    getOvertimePayment();
                    break;
                  case "overtimerate":
                    overTimeRate.value = newValue;
                    getOvertimePayment();
                    break;
                  case "bonus":
                    bonus.value = newValue;
                    totalNetPay();
                    break;
                  case "incentives":
                    incentives.value = newValue;
                    totalNetPay();
                    break;
                }
                print("Selected $label: $newValue");
              },
            );
          },
        ),
      ],
    );
  }

  Widget payslipMonth() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.payslipmonth,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              CustomText(
                text: " *",
                color: AppColors.red,
                size: 15,
                fontWeight: FontWeight.w400,
              )
            ],
          ),
          SizedBox(height: 5.h),
          InkWell(
              onTap: () => _pickMonthYear(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                height: 40.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.greyColor),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    text: selectedMonthYear != null
                        ? DateFormat('MMMM, yyyy').format(selectedMonthYear!)
                        : AppLocalizations.of(context)!.selectyear,
                    fontWeight: FontWeight.w400,
                    size: 14.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                  ),
                ),
              ))
        ],
      ),
    );
  }
}

class Allowance {
  int id;
  String name;
  String amount;

  Allowance({required this.id, required this.name, this.amount = ''});
}
