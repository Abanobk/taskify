import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/payslip/payslip_model.dart';
import '../../../bloc/payslip/payslip/payslip/payslip_bloc.dart';
import '../../../bloc/payslip/payslip/payslip/payslip_state.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/setting/settings_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/back_arrow.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';
import '../../widgets/custom_container.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import '../../../routes/routes.dart';
class PayslipDetailScreen extends StatefulWidget {
  final PayslipModel payslipModel;
  const PayslipDetailScreen({super.key, required this.payslipModel});

  @override
  State<PayslipDetailScreen> createState() => _PayslipDetailScreenState();
}

class _PayslipDetailScreenState extends State<PayslipDetailScreen> {
  // Define sideBarController (assumed to be a ScrollController)
  final ScrollController sideBarController = ScrollController();

  // Function to generate and print the PDF
  Future<void> _printPayslip() async {
    final pdf = pw.Document();

    // Load the logo image
    Uint8List? logo;
    try {
      logo = (await rootBundle.load('assets/images/png/splashlogo.png'))
          .buffer
          .asUint8List();
    } catch (e) {
      logo = null; // Handle missing logo gracefully
    }

    // Get currency symbol and translations from BuildContext before PDF generation
    final currency = context.read<SettingsBloc>().currencySymbol ?? "";
    final localizations = AppLocalizations.of(context)!;

    // Build the PDF content
    pdf.addPage(
      pw.Page(
        build: (pw.Context pdfContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo
              if (logo != null)
                pw.Container(
                  height: 50,
                  width: double.infinity,
                  child: pw.Image(pw.MemoryImage(logo)),
                ),
              pw.SizedBox(height: 20),

              // Payslip Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'PSL-${widget.payslipModel.id.toString()}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    '📅 ${widget.payslipModel.currentDate ?? ""} 🕒${widget.payslipModel.currentTime ?? ""}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Employee Details
              pw.Text(
                'Payslip For 👤${widget.payslipModel.user!.name ?? ""}',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '📧${widget.payslipModel.user!.email ?? ""}',
                style: pw.TextStyle(fontSize: 16, color: PdfColors.grey),
              ),
              pw.SizedBox(height: 20),

              // Payslip Details Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  _buildPdfTableRow(localizations.payslipmonth, widget.payslipModel.paidDays.toString()),
                  _buildPdfTableRow(localizations.basicsalary, '$currency ${widget.payslipModel.basicSalary}'),
                  _buildPdfTableRow(localizations.workingdays, widget.payslipModel.workingDays.toString()),
                  _buildPdfTableRow(localizations.lossofpaydays, widget.payslipModel.lopDays.toString()),
                  _buildPdfTableRow(localizations.paiddays, widget.payslipModel.paidDays.toString()),
                  _buildPdfTableRow(localizations.leavededuction, '$currency ${widget.payslipModel.leaveDeduction}'),
                  _buildPdfTableRow(localizations.bonus, '$currency ${widget.payslipModel.bonus}'),
                  _buildPdfTableRow(localizations.incentives, '$currency ${widget.payslipModel.incentives}'),
                  _buildPdfTableRow(localizations.overtimehours, '${widget.payslipModel.otHours}'),
                  _buildPdfTableRow(localizations.overtimerate, '${widget.payslipModel.otRate}'),
                  _buildPdfTableRow(localizations.overtimepayment, '$currency ${widget.payslipModel.otPayment}'),
                  _buildPdfTableRow(localizations.paymentmethods, '${widget.payslipModel.paymentMethod}'),
                  _buildPdfTableRow(localizations.paymentdate, '${widget.payslipModel.paymentDate}'),
                  _buildPdfTableRow(localizations.status, widget.payslipModel.status == 0 ? 'Unpaid' : 'Paid'),
                ],
              ),
              pw.SizedBox(height: 20),

              // Allowances
              if (widget.payslipModel.allowances != null) ...[
                pw.Text(
                  localizations.allowances,
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    _buildPdfTableRow('ALLOWANCE', 'AMOUNT', isHeader: true),
                    ...widget.payslipModel.allowances!.map(
                          (item) => _buildPdfTableRow(
                        item.title ?? '',
                        '$currency ${item.amount?.toStringAsFixed(2) ?? "0.00"}',
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],

              // Deductions
              if (widget.payslipModel.allowances != null) ...[
                pw.Text(
                  localizations.deductions,
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    _buildPdfTableRow('DEDUCTION', 'AMOUNT', isHeader: true),
                    ...widget.payslipModel.allowances!.map(
                          (item) => _buildPdfTableRow(
                        item.title ?? '',
                        '$currency ${item.amount?.toStringAsFixed(2) ?? "0.00"}',
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],

              // Total Allowances and Deductions
              pw.Text(
                localizations.totalallowancedeductions,
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  _buildPdfTableRow(
                    'TOTAL ALLOWANCES',
                    '$currency ${widget.payslipModel.totalDeductions!.toDouble().toStringAsFixed(2)}',
                  ),
                  _buildPdfTableRow(
                    'TOTAL DEDUCTIONS',
                    '$currency ${widget.payslipModel.totalDeductions!.toDouble().toStringAsFixed(2)}',
                  ),
                ],
              ),
              pw.SizedBox(height: 10),

              // Net Payable
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    '${localizations.netpayable} : ',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    '$currency ${widget.payslipModel.netPay}',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),

              // Note
              pw.Text(
                localizations.note,
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                localizations.updatedafterbonusrevisions,
                style: pw.TextStyle(fontSize: 15),
              ),
              pw.SizedBox(height: 20),

              // Created and Updated Dates
              pw.Text(
                '${localizations.createdat} : 📅 ${widget.payslipModel.createdAtDate ?? "-"} 🕒${widget.payslipModel.createdAtTime ?? "-"}',
                style: pw.TextStyle(fontSize: 13),
              ),
              pw.Text(
                '${localizations.updatedAt} : 📅 ${widget.payslipModel.updatedAtDate ?? "-"} 🕒${widget.payslipModel.updatedAtTime ?? "-"}',
                style: pw.TextStyle(fontSize: 13),
              ),
            ],
          );
        },
      ),
    );

    // Trigger the print dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Helper function to build table rows for PDF
  pw.TableRow _buildPdfTableRow(String label, String value, {bool isHeader = false}) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: isHeader ? PdfColors.grey200 : PdfColors.white),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text(value),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print("gdebfj ${widget.payslipModel.allowances !=null}");
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          router.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        body:  Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _appbar(isLightTheme),

                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  BlocConsumer<PayslipBloc, PayslipState>(
                    listener: (context, state) {
                      if (state is PayslipPaginated) {}
                    },
                    builder: (context, state) {
                      if (state is PayslipPaginated) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: _payslipCard(),
                            ),
                            SizedBox(height: 20.h),
                            SizedBox(height: 60.h),
                          ],
                        );
                      }
                      if (state is PayslipLoading) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              shimmerDetails(isLightTheme, context, 150.h),
                              const SizedBox(height: 20),
                              shimmerDetails(isLightTheme, context, 150.h),
                              const SizedBox(height: 20),
                              shimmerDetails(isLightTheme, context, 50.h),
                              const SizedBox(height: 20),
                              shimmerDetails(isLightTheme, context, 120.h),
                              const SizedBox(height: 20),
                              shimmerDetails(isLightTheme, context, 120.h),
                              const SizedBox(height: 20),
                            ],
                          ),
                        );
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            shimmerDetails(isLightTheme, context, 150.h),
                            const SizedBox(height: 20),
                            shimmerDetails(isLightTheme, context, 150.h),
                            const SizedBox(height: 20),
                            shimmerDetails(isLightTheme, context, 50.h),
                            const SizedBox(height: 20),
                            shimmerDetails(isLightTheme, context, 120.h),
                            const SizedBox(height: 20),
                            shimmerDetails(isLightTheme, context, 120.h),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

      ),
    );
  }

  Widget _appbar(bool isLightTheme) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
        ],
      ),
      child: BackArrow(
        onTap: () {
          router.pop();
        },
        isAdd: false,
        isDetailPage: true,
        isEditFromDetail: context.read<PermissionsBloc>().iseditPayslip,
        isDeleteFromDetail: context.read<PermissionsBloc>().isdeletePayslip,
        isEditCreate: true,
        fromNoti: "payslip",
        title: AppLocalizations.of(context)!.payslipdetail,
      ),
    );
  }

  Widget _payslipCard() {
    String? currency = context.read<SettingsBloc>().currencySymbol ?? "";

    return customContainer(
      width: double.infinity,
      context: context,
      addWidget: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: "PSL-${widget.payslipModel.id.toString()}",
                  fontWeight: FontWeight.w700,
                  size: 14,
                  color: AppColors.greyColor,
                ),
                CustomText(
                  text: "📅 ${widget.payslipModel.currentDate ?? ""} 🕒${widget.payslipModel.currentTime ?? ""}",
                  fontWeight: FontWeight.w700,
                  size: 14,
                  color: AppColors.greyColor,
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Container(
              height: 50.h,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/png/splashlogo.png"),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            CustomText(
              text: "Payslip For \n👤${widget.payslipModel.user!.name}",
              fontWeight: FontWeight.w700,
              size: 20,
              color: Theme.of(context).colorScheme.textChange,
            ),
            CustomText(
              text: "📧${widget.payslipModel.user!.email}",
              fontWeight: FontWeight.w500,
              size: 16,
              color: AppColors.greyColor,
              maxLines: 3,
              softwrap: true,
            ),
            SizedBox(height: 20.h),
            RowDesign(
              AppLocalizations.of(context)!.payslipmonth,
              widget.payslipModel.paidDays.toString(),
            ),
            Divider(color: Theme.of(context).colorScheme.dividerClrChange),
            RowDesign(
              AppLocalizations.of(context)!.basicsalary,
              "$currency ${widget.payslipModel.basicSalary}",
            ),
            Divider(color: Theme.of(context).colorScheme.dividerClrChange),
            RowDesign(
              AppLocalizations.of(context)!.workingdays,
              widget.payslipModel.workingDays.toString(),
            ),
            Divider(color: Theme.of(context).colorScheme.dividerClrChange),
            RowDesign(
              AppLocalizations.of(context)!.lossofpaydays,
              widget.payslipModel.lopDays.toString(),
            ),
            Divider(color: Theme.of(context).colorScheme.dividerClrChange),
            RowDesign(
              AppLocalizations.of(context)!.paiddays,
              widget.payslipModel.paidDays.toString(),
            ),
            Divider(color: Theme.of(context).colorScheme.dividerClrChange),
            RowDesign(
              AppLocalizations.of(context)!.leavededuction,
              "$currency ${widget.payslipModel.leaveDeduction}",
            ),
            Divider(color: Theme.of(context).colorScheme.dividerClrChange),
            RowDesign(
              AppLocalizations.of(context)!.bonus,
              "$currency ${widget.payslipModel.bonus}",
            ),
            RowDesign(
              AppLocalizations.of(context)!.incentives,
              "$currency ${widget.payslipModel.incentives}",
            ),
            Divider(color: Theme.of(context).colorScheme.dividerClrChange),
            RowDesign(
              AppLocalizations.of(context)!.overtimehours,
              "${widget.payslipModel.otHours}",
            ),
            Divider(color: Theme.of(context).colorScheme.dividerClrChange),
            RowDesign(
              AppLocalizations.of(context)!.overtimerate,
              "${widget.payslipModel.otRate}",
            ),
            Divider(color: Theme.of(context).colorScheme.dividerClrChange),
            RowDesign(
              AppLocalizations.of(context)!.overtimepayment,
              "$currency ${widget.payslipModel.otPayment}",
            ),
            Divider(color: Theme.of(context).colorScheme.dividerClrChange),
            RowDesign(
              AppLocalizations.of(context)!.paymentmethods,
              "${widget.payslipModel.paymentMethod}",
            ),
            RowDesign(
              AppLocalizations.of(context)!.paymentdate,
              "${widget.payslipModel.paymentDate}",
            ),
            Divider(color: Theme.of(context).colorScheme.dividerClrChange),
            RowDesign(
              AppLocalizations.of(context)!.status,
              widget.payslipModel.status == 0 ? "Unpaid" : "Paid",
              isStatus: true,
            ),
            Divider(color: Theme.of(context).colorScheme.dividerClrChange),
            allowances(currency),
            SizedBox(height: 20.h),
            deduction(currency),
            SizedBox(height: 20.h),
            totalAllowanceDeductionTable(
              currency: currency,
              totalAllowances: widget.payslipModel.totalDeductions!.toDouble(),
              totalDeductions: widget.payslipModel.totalDeductions!.toDouble(),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  text: "${AppLocalizations.of(context)!.netpayable} : ",
                  fontWeight: FontWeight.w700,
                  size: 18,
                  color: Theme.of(context).colorScheme.textChange,
                  maxLines: 3,
                  softwrap: true,
                ),
                CustomText(
                  text: "$currency ${widget.payslipModel.netPay}",
                  fontWeight: FontWeight.w700,
                  size: 18,
                  color: Theme.of(context).colorScheme.textChange,
                  maxLines: 3,
                  softwrap: true,
                ),
              ],
            ),
            SizedBox(height: 10.h),
            CustomText(
              text: "${AppLocalizations.of(context)!.note} ",
              fontWeight: FontWeight.w700,
              size: 18,
              color: Theme.of(context).colorScheme.textChange,
              maxLines: 3,
              softwrap: true,
            ),
            CustomText(
              text: AppLocalizations.of(context)!.updatedafterbonusrevisions,
              fontWeight: FontWeight.w700,
              size: 15,
              color: Theme.of(context).colorScheme.textChange,
              maxLines: 3,
              softwrap: true,
            ),
            SizedBox(height: 20.h),
            dates(
              true,
              widget.payslipModel.createdAtDate ?? "-",
              widget.payslipModel.createdAtTime ?? "-",
            ),
            dates(
              false,
              widget.payslipModel.updatedAtDate ?? "-",
              widget.payslipModel.updatedAtTime ?? "-",
            ),
SizedBox(height: 20.h,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _printPayslip,
                  icon: Icon(Icons.print,color: AppColors.pureWhiteColor,),
                  label: Text("Print Payslip"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h,),
          ],
        ),
      ),
    );
  }

  Widget RowDesign(String label, String value, {bool isStatus = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: "$label : ",
          fontWeight: FontWeight.w700,
          size: 18,
          color: Theme.of(context).colorScheme.textChange,
          maxLines: 3,
          softwrap: true,
        ),
        isStatus
            ? ConstrainedBox(
          constraints: BoxConstraints(maxWidth: double.infinity),
          child: IntrinsicWidth(
            child: Container(
              alignment: Alignment.center,
              height: 20.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue.shade800,
              ),
              child: CustomText(
                text: value == "0" ? "Unpaid" : "Paid",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                color: AppColors.whiteColor,
                size: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
            : Expanded(
          child: CustomText(
            text: value,
            fontWeight: FontWeight.w700,
            size: 17,
            color: isStatus ? AppColors.primary : AppColors.greyColor,
            maxLines: 3,
            softwrap: true,
          ),
        ),
      ],
    );
  }

  Widget dates(bool isCreate, String date, String time) {
    return Row(
      children: [
        CustomText(
          text: isCreate
              ? "${AppLocalizations.of(context)!.createdat} : "
              : "${AppLocalizations.of(context)!.updatedAt} : ",
          size: 13.sp,
          color: Theme.of(context).colorScheme.textClrChange,
          fontWeight: FontWeight.w600,
        ),
        CustomText(
          text: "📅 $date 🕒$time",
          size: 12.sp,
          color: Theme.of(context).colorScheme.textClrChange,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  Widget allowanceTableForm(List<Allowance> list, String currency) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
      },
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(color:  Theme.of(context).colorScheme.containerDark),
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'ALLOWANCE',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'AMOUNT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        // Data rows
        ...list.map(
              (item) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item.title ?? ""),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("$currency ${item.amount?.toStringAsFixed(2) ?? "0.00"}"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget totalAllowanceDeductionTable({
    required String currency,
    required double totalAllowances,
    required double totalDeductions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomText(
          text: AppLocalizations.of(context)!.totalallowancedeductions,
          fontWeight: FontWeight.w700,
          size: 18,
          color: Theme.of(context).colorScheme.textChange,
          maxLines: 3,
          softwrap: true,
        ),
        SizedBox(height: 10.h),
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "TOTAL ALLOWANCES",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("$currency ${totalAllowances.toStringAsFixed(2)}"),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "TOTAL DEDUCTIONS",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("$currency ${totalDeductions.toStringAsFixed(2)}"),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget allowances(String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomText(
          text: AppLocalizations.of(context)!.allowances,
          fontWeight: FontWeight.w700,
          size: 18,
          color: Theme.of(context).colorScheme.textChange,
          maxLines: 3,
          softwrap: true,
        ),
        SizedBox(height: 10.h),
        widget.payslipModel.allowances != null
            ? allowanceTableForm(widget.payslipModel.allowances!, currency)
            : SizedBox(),
      ],
    );
  }

  Widget deduction(String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomText(
          text: AppLocalizations.of(context)!.deductions,
          fontWeight: FontWeight.w700,
          size: 18,
          color: Theme.of(context).colorScheme.textChange,
          maxLines: 3,
          softwrap: true,
        ),
        SizedBox(height: 10.h),
        widget.payslipModel.allowances != null
            ? allowanceTableForm(widget.payslipModel.allowances!, currency)
            : SizedBox(),
      ],
    );
  }

  @override
  void dispose() {
    sideBarController.dispose();
    super.dispose();
  }
}