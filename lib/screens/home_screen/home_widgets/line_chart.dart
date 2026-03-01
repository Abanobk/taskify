// // import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:taskify/config/colors.dart';
// //
// import '../../../bloc/income_expense/income_expense_bloc.dart';
// import '../../../bloc/income_expense/income_expense_event.dart';
// import '../../../bloc/income_expense/income_expense_state.dart';
// import '../../../bloc/theme/theme_bloc.dart';
// import '../../../bloc/theme/theme_state.dart';
// import '../../../config/constants.dart';
// import '../../../data/model/income_expense/income_expense_model.dart';
// import '../../../utils/widgets/custom_text.dart';
// import '../../widgets/search_field.dart';
//
//
// class ChartPage extends StatefulWidget {
//   @override
//   _ChartPageState createState() => _ChartPageState();
// }
//
// class _ChartPageState extends State<ChartPage> {
//   TextEditingController searchController = TextEditingController();  String? formattedTimeEnd;
//   DateTime? selectedDateStarts;
//   DateTime? selectedDateEnds;
//   String? fromDate;
//   String? toDate;
//   String searchWord = "";
//   late List<ChartData> chartData;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     final themeBloc = context.read<ThemeBloc>();
//     final currentTheme = themeBloc.currentThemeState;
//     bool isLightTheme = currentTheme is LightThemeState;
//
//     return BlocBuilder<ChartBloc, ChartState>(
//       builder: (context, state) {
//         print("jfsdhbj dlgb $state");
//         if (state is ChartLoading) {
//           return Center(child: CircularProgressIndicator());
//         } else if (state is ChartError) {
//           return Center(child: Text(state.message));
//         } else if (state is ChartLoaded) {
//           List<ChartData> buildChartData(List<Invoice> invoices, List<Expense> expenses) {
//             final Map<String, double> incomeMap = {};
//             final Map<String, double> expenseMap = {};
//
//             for (var inv in invoices) {
//               final date = inv.fromDate;
//               final amount = double.tryParse(inv.amount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
//               incomeMap.update(date, (prev) => prev + amount, ifAbsent: () => amount);
//             }
//
//             for (var exp in expenses) {
//               final date = exp.expenseDate;
//               final amount = double.tryParse(exp.amount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
//               expenseMap.update(date, (prev) => prev + amount, ifAbsent: () => amount);
//             }
//
//             final allDates = {...incomeMap.keys, ...expenseMap.keys}.toList();
//             allDates.sort((a, b) => DateFormat("yyyy-MM-dd").parse(a).compareTo(DateFormat("yyyy-MM-dd").parse(b)));
//
//             return allDates.map((date) {
//               final income = incomeMap[date] ?? 0;
//               final expense = expenseMap[date] ?? 0;
//               return ChartData(
//                 DateFormat("yyyy-MM-dd").parse(date),
//                 income,
//                 expense,
//               );
//             }).toList();
//           }
//           final mergedChartData = buildChartData(state.chartData.invoices, state.chartData.expenses);
//
//           return Padding(
//             padding: EdgeInsets.symmetric(horizontal: 18.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CustomText(
//                   text: AppLocalizations.of(context)!.incomevsexpense,
//                   color: Theme.of(context).colorScheme.textClrChange,
//                   size: 18,
//                   fontWeight: FontWeight.w800,
//                 ),
//                 SizedBox(height: 15.h),
//                 CustomSearchField(
//                   onTap: () {
//                     showCustomDateRangePicker(
//                       context,
//                       dismissible: true,
//                       minimumDate: DateTime(1900),
//                       maximumDate: DateTime(9999),
//                       endDate: selectedDateEnds,
//                       startDate: selectedDateStarts,
//                       backgroundColor: Theme.of(context).colorScheme.containerDark,
//                       primaryColor: AppColors.primary,
//                       onApplyClick: (start, end) {
//                         setState(() {
//                           selectedDateEnds = end;
//                           selectedDateStarts = start;
//
//                           // Show both start and end dates in the same controller
//                           searchController.text =
//                           "${dateFormatConfirmed(selectedDateStarts!, context)}  -  ${dateFormatConfirmed(selectedDateEnds!, context)}";
//
//                           // Assign values for API submission
//                           fromDate = dateFormatConfirmedToApi(start);
//                           toDate = dateFormatConfirmedToApi(end);
//                           context.read<ChartBloc>().add(FetchChartData(endDate: toDate??"", startDate: fromDate??"")); // or whatever your event is
//
//                         });
//                       },
//                       onCancelClick: () {
//                         setState(() {
//                           searchController.clear();
//                           selectedDateStarts = null;
//                           selectedDateEnds = null;
//                           fromDate = null;
//                           toDate = null;
//                         });
//                         context.read<ChartBloc>().add(FetchChartData(endDate: toDate??"", startDate: fromDate??"")); // or whatever your event is
//
//
//                       },
//                     );
//                   },
//                   isNoti: true,
//                   hintText: "Date between",
//                   isLightTheme: isLightTheme,
//                   controller: searchController,
//                   suffixIcon: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (searchController.text.isNotEmpty)
//                         Container(
//                           width: 20.w,
//                           // color: AppColors.red,
//                           child: IconButton(
//                               highlightColor: AppColors.greyForgetColor,
//                               padding: EdgeInsets.zero,
//                               icon: Icon(
//                                 Icons.clear,
//                                 size: 20.sp,
//                                 color: Theme.of(context).colorScheme.textFieldColor,
//                               ),
//                             onPressed: () {
//                               setState(() {
//                                 searchController.clear();
//                                 selectedDateStarts = null;
//                                 selectedDateEnds = null;
//                                 fromDate = null;
//                                 toDate = null;
//                               });
//                               context.read<ChartBloc>().add(FetchChartData(endDate: toDate??"", startDate: fromDate??"")); // or whatever your event is
//
//
//                             },
//                           ),
//                         ),
//                     ],
//                   ),
//                   onChanged: (value) {
//                     searchWord = value;
//                   },
//                 ),
//                 SizedBox(height: 10.h),
//
//         SfCartesianChart(
//         legend: Legend(isVisible: true),
//         tooltipBehavior: TooltipBehavior(enable: true),
//         primaryXAxis: DateTimeAxis(
//         intervalType: DateTimeIntervalType.days,
//         dateFormat: DateFormat('dd MMM'),
//         majorGridLines: const MajorGridLines(width: 0),
//         ),
//         primaryYAxis: NumericAxis(
//         numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
//         majorGridLines: const MajorGridLines(width: 0.5),
//         ),
//         series: <CartesianSeries>[
//         ColumnSeries<ChartData, DateTime>(
//         name: 'Income',
//         dataSource: mergedChartData,
//         xValueMapper: (ChartData data, _) => data.date,
//         yValueMapper: (ChartData data, _) => data.income,
//         color: Colors.green,
//         ),
//         ColumnSeries<ChartData, DateTime>(
//         name: 'Expense',
//         dataSource: mergedChartData,
//         xValueMapper: (ChartData data, _) => data.date,
//         yValueMapper: (ChartData data, _) => data.expense,
//         color: Colors.red,
//         ),
//         ],
//         )
//
//         // Container(
//                 //   height: 300.h,
//                 //   child: Container(
//                 //     height: 300.h,
//                 //     child: SfCartesianChart(
//                 //       legend: Legend(isVisible: true),
//                 //       tooltipBehavior: TooltipBehavior(enable: true),
//                 //       primaryXAxis: DateTimeAxis(
//                 //         intervalType: DateTimeIntervalType.days,
//                 //         dateFormat: DateFormat('dd MMM'),
//                 //         majorGridLines: const MajorGridLines(width: 0),
//                 //       ),
//                 //       primaryYAxis: NumericAxis(
//                 //         numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
//                 //         majorGridLines: const MajorGridLines(width: 0.5),
//                 //       ),
//                 //       series: <CartesianSeries>[
//                 //         ColumnSeries<Invoice, DateTime>(
//                 //           name: 'Income',
//                 //           color: Colors.green,
//                 //           dataSource: state.chartData.invoices
//                 //             ..sort((a, b) => DateFormat("yyyy-MM-dd")
//                 //                 .parse(a.fromDate)
//                 //                 .compareTo(DateFormat("yyyy-MM-dd").parse(b.fromDate))),
//                 //           xValueMapper: (Invoice invoice, _) =>
//                 //               DateFormat("yyyy-MM-dd").parse(invoice.fromDate),
//                 //           yValueMapper: (Invoice invoice, _) =>
//                 //           double.tryParse(invoice.amount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0,
//                 //           borderRadius: BorderRadius.circular(4),
//                 //           width: 0.3,
//                 //           spacing: 0.2,
//                 //         ),
//                 //         ColumnSeries<Expense, DateTime>(
//                 //           name: 'Expense',
//                 //           color: Colors.red,
//                 //           dataSource: state.chartData.expenses
//                 //             ..sort((a, b) => DateFormat("yyyy-MM-dd")
//                 //                 .parse(a.expenseDate)
//                 //                 .compareTo(DateFormat("yyyy-MM-dd").parse(b.expenseDate))),
//                 //           xValueMapper: (Expense expense, _) =>
//                 //               DateFormat("yyyy-MM-dd").parse(expense.expenseDate),
//                 //           yValueMapper: (Expense expense, _) =>
//                 //           double.tryParse(expense.amount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0,
//                 //           borderRadius: BorderRadius.circular(4),
//                 //           width: 0.3,
//                 //           spacing: 0.2,
//                 //         ),
//                 //       ],
//                 //
//                 //       // series: <CartesianSeries>[
//                 //       //   // INCOME LINE
//                 //       //   SplineSeries<Invoice, DateTime>(
//                 //       //     name: 'Income',
//                 //       //     dataSource: state.chartData.invoices..sort((a, b) =>
//                 //       //         DateFormat("yyyy-MM-dd").parse(a.fromDate).compareTo(
//                 //       //             DateFormat("yyyy-MM-dd").parse(b.fromDate))),
//                 //       //     xValueMapper: (Invoice invoice, _) =>
//                 //       //         DateFormat("yyyy-MM-dd").parse(invoice.fromDate),
//                 //       //     yValueMapper: (Invoice invoice, _) =>
//                 //       //     double.tryParse(invoice.amount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0,
//                 //       //     color: Colors.green,
//                 //       //     markerSettings: const MarkerSettings(isVisible: true),
//                 //       //   ),
//                 //       //
//                 //       //   // EXPENSE AREA
//                 //       //   SplineAreaSeries<Expense, DateTime>(
//                 //       //     name: 'Expense',
//                 //       //     dataSource: state.chartData.expenses..sort((a, b) =>
//                 //       //         DateFormat("yyyy-MM-dd").parse(a.expenseDate).compareTo(
//                 //       //             DateFormat("yyyy-MM-dd").parse(b.expenseDate))),
//                 //       //     xValueMapper: (Expense expense, _) =>
//                 //       //         DateFormat("yyyy-MM-dd").parse(expense.expenseDate),
//                 //       //     yValueMapper: (Expense expense, _) =>
//                 //       //     double.tryParse(expense.amount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0,
//                 //       //     color: Colors.red.withValues(alpha: 0.3),
//                 //       //     borderColor: Colors.red,
//                 //       //     borderWidth: 2,
//                 //       //     markerSettings: const MarkerSettings(isVisible: true),
//                 //       //   ),
//                 //       // ],
//                 //     ),
//                 //   ),
//                 //
//                 // ),
//
//
//
//
//
//               ],
//             ),
//           );
//         }
//         return Container();
//       },
//     );
//   }
// }
//
// class ChartData {
//   final DateTime date;
//   final double income;
//   final double expense;
//
//   ChartData(this.date, this.income, this.expense);
// }
// // List<ChartData> getChartData() {
// //   return [
// //     ChartData(DateTime(2024, 8, 1), 500, 2000),
// //     ChartData(DateTime(2024, 8, 5), 700, 1000),
// //     ChartData(DateTime(2024, 8, 8), 800, 2400),
// //     ChartData(DateTime(2024, 7, 3), 900, 1200),
// //     ChartData(DateTime(2024, 3, 26), 600, 600),
// //     ChartData(DateTime(2024, 5, 15), 400, 400),
// //   ];
// // }
// //
// // class ChartData {
// //   final DateTime date;
// //   final double income;
// //   final double expense;
// //   ChartData(this.date, this.income, this.expense);
// // }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';

import '../../../bloc/income_expense/income_expense_bloc.dart';
import '../../../bloc/income_expense/income_expense_event.dart';
import '../../../bloc/income_expense/income_expense_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../data/model/income_expense/income_expense_model.dart';
import '../../../../src/generated/i18n/app_localizations.dart';

import '../../../utils/widgets/custom_text.dart';
import '../../widgets/search_field.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  TextEditingController searchController = TextEditingController();
  DateTime? selectedDateStarts;
  DateTime? selectedDateEnds;
  String? fromDate;
  String? toDate;
  String searchWord = "";
  bool showBarChart = true; // 🔁 Toggle flag

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    bool isLightTheme = currentTheme is LightThemeState;

    return BlocBuilder<ChartBloc, ChartState>(
      builder: (context, state) {
        if (state is ChartLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is ChartError) {
          return Center(child: Text(state.message));
        } else if (state is ChartLoaded) {
          print("fghjk ${state.chartData.totalIncome}");
          print("fghjk ${state.chartData.profitOrLoss}");
          print("fghjk ${state.chartData.totalExpenses}");
          // 📊 Merge chart data
          List<ChartData> buildChartData(List<Invoice> invoices, List<Expense> expenses) {
            final Map<String, double> incomeMap = {};
            final Map<String, double> expenseMap = {};

            for (var inv in invoices) {
              final date = inv.fromDate;
              final amount = double.tryParse(inv.amount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
              incomeMap.update(date, (prev) => prev + amount, ifAbsent: () => amount);
            }

            for (var exp in expenses) {
              final date = exp.expenseDate;
              final amount = double.tryParse(exp.amount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
              expenseMap.update(date, (prev) => prev + amount, ifAbsent: () => amount);
            }

            final allDates = {...incomeMap.keys, ...expenseMap.keys}.toList();
            allDates.sort((a, b) => DateFormat("yyyy-MM-dd").parse(a).compareTo(DateFormat("yyyy-MM-dd").parse(b)));

            return allDates.map((date) {
              final income = incomeMap[date] ?? 0;
              final expense = expenseMap[date] ?? 0;
              return ChartData(
                DateFormat("yyyy-MM-dd").parse(date),
                income,
                expense,
              );
            }).toList();
          }

          final mergedChartData = buildChartData(state.chartData.invoices, state.chartData.expenses);

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: AppLocalizations.of(context)!.incomevsexpense,
                      color: Theme.of(context).colorScheme.textClrChange,
                      size: 18,
                      fontWeight: FontWeight.w800,
                    ),
                    InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: (){
                        setState(() {
                          showBarChart = !showBarChart;
                        });
                      },
                      child: showBarChart?Container(

                        height: 20.h,
                        width: 20.w,
                        decoration: BoxDecoration(image: DecorationImage(image:AssetImage("assets/images/png/area-graph.png"))),
                      ):Container(

                        height: 20.h,
                        width: 20.w,
                        decoration: BoxDecoration(image: DecorationImage(image:AssetImage("assets/images/png/bar-graph.png"))),
                      )
                      // child: HeroIcon(
                      //   showBarChart
                      //       ? HeroIcons.chartPie
                      //       : HeroIcons.chartBar, // ✅ Use `value`
                      //   style: HeroIconStyle.solid,
                      //   color: Theme.of(context).colorScheme.textFieldColor,
                      //   size: 15.sp,
                      // ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),

                // 🔍 Date Picker Search Field
                CustomSearchField(
                  onTap: () {
                    // showCustomDateRangePicker(
                    //   context,
                    //   dismissible: true,
                    //   minimumDate: DateTime(1900),
                    //   maximumDate: DateTime(9999),
                    //   endDate: selectedDateEnds,
                    //   startDate: selectedDateStarts,
                    //   backgroundColor: Theme.of(context).colorScheme.containerDark,
                    //   primaryColor: AppColors.primary,
                    //   onApplyClick: (start, end) {
                    //     setState(() {
                    //       selectedDateEnds = end;
                    //       selectedDateStarts = start;
                    //
                    //       searchController.text =
                    //       "${dateFormatConfirmed(start, context)}  -  ${dateFormatConfirmed(end, context)}";
                    //
                    //       fromDate = dateFormatConfirmedToApi(start);
                    //       toDate = dateFormatConfirmedToApi(end);
                    //       context.read<ChartBloc>().add(FetchChartData(startDate: fromDate!, endDate: toDate!));
                    //     });
                    //   },
                    //   onCancelClick: () {
                    //     setState(() {
                    //       searchController.clear();
                    //       selectedDateStarts = null;
                    //       selectedDateEnds = null;
                    //       fromDate = null;
                    //       toDate = null;
                    //     });
                    //     context.read<ChartBloc>().add(FetchChartData(startDate: '', endDate: ''));
                    //   },
                    // );
                  },
                  isNoti: true,
                  hintText: "Date between",
                  isLightTheme: isLightTheme,
                  controller: searchController,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (searchController.text.isNotEmpty)
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.clear, size: 20.sp),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              selectedDateStarts = null;
                              selectedDateEnds = null;
                              fromDate = null;
                              toDate = null;
                            });
                            context.read<ChartBloc>().add(FetchChartData(startDate: '', endDate: ''));
                          },
                        ),
                    ],
                  ),
                  onChanged: (value) => searchWord = value,
                ),

                SizedBox(height: 10.h),



                // 📊 Chart Section
                Container(
                  height: 300.h,
                  child: SfCartesianChart(
                    legend: Legend(isVisible: true),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    primaryXAxis: DateTimeAxis(
                      intervalType: DateTimeIntervalType.days,
                      dateFormat: DateFormat('dd MMM'),
                      majorGridLines: const MajorGridLines(width: 0),
                    ),
                    primaryYAxis: NumericAxis(
                      numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
                      majorGridLines: const MajorGridLines(width: 0.5),
                    ),
                    series: showBarChart
                        ? <CartesianSeries>[
                      ColumnSeries<ChartData, DateTime>(
                        name: 'Income',
                        dataSource: mergedChartData,
                        xValueMapper: (ChartData data, _) => data.date,
                        yValueMapper: (ChartData data, _) => data.income,
                        color: Colors.green,
                      ),
                      ColumnSeries<ChartData, DateTime>(
                        name: 'Expense',
                        dataSource: mergedChartData,
                        xValueMapper: (ChartData data, _) => data.date,
                        yValueMapper: (ChartData data, _) => data.expense,
                        color: Colors.red,
                      ),
                    ]
                        : <CartesianSeries>[
                      SplineSeries<ChartData, DateTime>(
                        name: 'Income',
                        dataSource: mergedChartData,
                        xValueMapper: (ChartData data, _) => data.date,
                        yValueMapper: (ChartData data, _) => data.income,
                        color: Colors.green,
                        markerSettings: const MarkerSettings(isVisible: true),
                      ),
                      SplineAreaSeries<ChartData, DateTime>(
                        name: 'Expense',
                        dataSource: mergedChartData,
                        xValueMapper: (ChartData data, _) => data.date,
                        yValueMapper: (ChartData data, _) => data.expense,
                        color: Colors.red.withValues(alpha: 0.3),
                        borderColor: Colors.red,
                        borderWidth: 2,
                        markerSettings: const MarkerSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}

class ChartData {
  final DateTime date;
  final double income;
  final double expense;

  ChartData(this.date, this.income, this.expense);
}
