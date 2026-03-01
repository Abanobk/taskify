import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../widgets/custom_date.dart';

class DateList extends StatefulWidget {
  final TextEditingController? startController;
  final TextEditingController? endController;
  final  DateTime? selectedDateEnds;
 final  DateTime? selectedDateStarts;
  final String? fromDate;
   final String? toDate;
  final Function(String, String)? onSelected;



   DateList({super.key,this.startController,this.endController,this.fromDate,this.toDate,this.selectedDateEnds,this.selectedDateStarts,this.onSelected});

  @override
  State<DateList> createState() => _DateListState();
}

class _DateListState extends State<DateList> {
  DateTime? selectedDateEnds;
  DateTime? selectedDateStarts;
  String? fromDate;
  String? toDate;

  @override
  void initState() {
    super.initState();
    // initialize from widget final values
    selectedDateEnds = widget.selectedDateEnds;
    selectedDateStarts = widget.selectedDateStarts;
    fromDate = widget.fromDate;
    toDate = widget.toDate;
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    bool isLightTheme = currentTheme is LightThemeState;

    return SizedBox(
      height: 200.h,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: DateRangePickerWidget(
              dateController: widget.startController!,
              title: AppLocalizations.of(context)!.starts,
            titlestartend: AppLocalizations.of(context)!.selectstartenddate,
                    selectedDateEnds: selectedDateEnds,
                    selectedDateStarts: selectedDateStarts,
                    isLightTheme: isLightTheme,
                    onTap: (start, end) {
                      setState(() {
                        if (end!.isBefore(start!)) {
                          end = start;
                        }
                        selectedDateStarts = start;
                        selectedDateEnds = end;
                        widget.startController!.text =
                            DateFormat('MMMM dd, yyyy').format(start);
                        widget.endController!.text =
                            DateFormat('MMMM dd, yyyy').format(end!);
                        fromDate = DateFormat('yyyy-MM-dd').format(start);
                        toDate = DateFormat('yyyy-MM-dd').format(end!);

                        if (widget.onSelected != null) {
                          widget.onSelected!(fromDate!, toDate!);
                        }
                      });
                    },
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: DateRangePickerWidget(
              dateController: widget.endController!,
              title: AppLocalizations.of(context)!.ends,
              isLightTheme: isLightTheme,
            ),
          ),
        ],
      ),
    );
  }
}

