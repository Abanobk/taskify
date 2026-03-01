import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/colors.dart';
import '../../utils/widgets/custom_text.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class CreateCancelButtom extends StatefulWidget {
  final String? title;
  final bool? isCreate;
  final bool? isLoading;
  final bool? isCancel;
  final VoidCallback? onpressCreate;
  final VoidCallback? onpressCancel;
  const CreateCancelButtom(
      {super.key,
      this.isLoading,
      this.isCreate,
      this.isCancel,
      this.title,
      this.onpressCreate,
      this.onpressCancel});

  @override
  State<CreateCancelButtom> createState() => _CreateCancelButtomState();
}

class _CreateCancelButtomState extends State<CreateCancelButtom> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          highlightColor: Colors.transparent, // No highlight on tap
          splashColor: Colors.transparent,
          onTap: widget.onpressCancel,
          child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.textsubColor,
                  borderRadius: BorderRadius.circular(6)),
              height: 30.h,
              width: 100.w,
              margin: EdgeInsets.symmetric(vertical: 10.h),
              child: CustomText(
                text: AppLocalizations.of(context)!.cancel,
                size: 12.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.pureWhiteColor,
              )),
        ),
        SizedBox(
          width: 20.w,
        ),
        InkWell(
          highlightColor: Colors.transparent, // No highlight on tap
          splashColor: Colors.transparent,
          onTap: widget.onpressCreate,
          child: widget.isLoading == true
              ? Container(
              height: 30.h,
              width: 30.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6)),
                  // margin: EdgeInsets.symmetric(vertical: 10.h),
                  child: Padding(
                    padding:  EdgeInsets.all(10.w),
                    child: CircularProgressIndicator(color: AppColors.pureWhiteColor,strokeWidth: 2,),
                  ))
              : Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6)),
                  height: 30.h,
                  width: 100.w,
                  margin: EdgeInsets.symmetric(vertical: 4.h),
                  child: CustomText(
                    text: widget.title == null
                        ? widget.isCreate == false
                            ? AppLocalizations.of(context)!.update
                            : AppLocalizations.of(context)!.create
                        : widget.title!,
                    size: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.pureWhiteColor,
                  )),
        )
      ],
    );
  }
}
