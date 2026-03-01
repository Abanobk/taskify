import 'package:getwidget/components/radio/gf_radio.dart';
import 'package:getwidget/types/gf_radio_type.dart';
import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/toast_widget.dart';


class CustomRadioList extends StatelessWidget {
  final List<String> options;
  final String groupValue;
  final ValueChanged<String> onChanged;
  final double size;
  final Color activeColor;
  final Color inactiveBorderColor;
  final bool isDetails;

  const CustomRadioList({
    Key? key,
    required this.options,
    required this.groupValue,
    required this.onChanged,
    this.isDetails = false,
    this.size = 20.0,
    this.activeColor =AppColors.primary,
    this.inactiveBorderColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          return Padding(
            padding:  EdgeInsets.symmetric(vertical: 4.h,horizontal: 10.w),
            child: Row(
            children: [
              GFRadio<String>(
                type: GFRadioType.basic,
                size: size,
                value: option,
                groupValue: groupValue,
                onChanged: (value) {
                  if (value != "") {
                    onChanged(value);
                  }
                },

                activeBorderColor: activeColor,
                activeBgColor:  Theme.of(context).colorScheme.backGroundColor,
                inactiveBgColor:  Theme.of(context).colorScheme.backGroundColor,
                inactiveBorderColor: inactiveBorderColor,
                radioColor: activeColor,
              ),
              const SizedBox(width: 20),
              CustomText(text: option,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 14.sp,
                fontWeight: FontWeight.w700,),
            ],
                          ),
          );
        },
      ),
        if (isDetails)
          Positioned.fill(
            child: InkWell(
              onTap: (){
                print("tyuhjnkm,l");
                flutterToastCustom(
                  msg: AppLocalizations.of(context)!.createdsuccessfully,
                  color: AppColors.primary,
                );
              },
              child: Container(

                decoration: BoxDecoration(
                  color:  Theme.of(context).colorScheme.detailsOverlay,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

     ]
    );
  }
}
