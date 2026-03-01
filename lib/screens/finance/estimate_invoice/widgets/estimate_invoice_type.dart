import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import '../../../../src/generated/i18n/app_localizations.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/screens/widgets/no_data.dart';

import '../../../../utils/widgets/custom_text.dart';

class EstimateInvoiceField extends StatefulWidget {
  final bool isRequired;
  final bool isCreate;

  final String? access;
  final String? from;

  final Function(String) onSelected;
  const EstimateInvoiceField(
      {super.key,
        required this.isRequired,
        required this.isCreate,
        required this.access,

        required this.from,

        required this.onSelected});

  @override
  State<EstimateInvoiceField> createState() => _EstimateInvoiceFieldState();
}

class _EstimateInvoiceFieldState extends State<EstimateInvoiceField> {
  String? estinateInvoicesname;
  String? name;
  int? estinateInvoicesId;

  List<String> type = [ "Estimate","Invoice"];
  late ValueNotifier<String?> selectedTypeNotifier;



  @override
  void initState() {
    name = widget.access;
    print("frsufhpb ${widget.access}");
    if (widget.from == "type") {
      if (!widget.isCreate) {
        switch (widget.access?.toLowerCase()) {
          case "":
          case null:
            estinateInvoicesname = null; // not ""
            break;
          case "estimate":
            estinateInvoicesname = "Estimate";
            break;
          case "invoice":
            estinateInvoicesname = "Invoice";
            break;
          default:
            estinateInvoicesname = null;
            break;
        }

      }
    }

    selectedTypeNotifier = ValueNotifier<String?>(estinateInvoicesname);

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Widget buildContent() {
      switch (widget.from) {
        case "type":
          return buildWidget(title: AppLocalizations.of(context)!.estimatesinvoices,type: type);
        default:
          return const SizedBox.shrink(); // Empty if `widget.from` is unknown
      }
    }

    return buildContent();
  }

  Widget  buildWidget({required String title,required List<String> type}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              CustomText(
                text:title,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              widget.isRequired == true ?  const CustomText(
                text: " *",
                // text: getTranslated(context, 'myweeklyTask'),
                color: AppColors.red,
                size: 15,
                fontWeight: FontWeight.w400,
              ):const SizedBox.shrink(),
            ],
          ),
        ),
        // SizedBox(height: 5.h),
        AbsorbPointer(
          absorbing: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5.h),
              InkWell(
                highlightColor: Colors.transparent, // No highlight on tap
                splashColor: Colors.transparent,
                onTap: () {
                  // int selectedIndex = type.indexOf(estinateInvoicesname ?? type.first);
                  int selectedIndex = type.contains(estinateInvoicesname) ? type.indexOf(estinateInvoicesname!) : -1;

                   showDialog(
                    context: context,
                    builder: (ctx) {
                      return StatefulBuilder(
                        builder: (BuildContext context, void Function(void Function()) setState) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
                            contentPadding: EdgeInsets.zero,
                            title: Center(
                              child: Column(
                                children: [
                                  CustomText(
                                    text: AppLocalizations.of(context)!.pleaseselect,
                                    fontWeight: FontWeight.w800,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.whitepurpleChange,
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),
                            content: Container(
                              constraints: BoxConstraints(maxHeight: 900.h),
                              width: MediaQuery.of(context).size.width,
                              child: type.isEmpty?NoData(isImage: true,):ListView.builder(
                                padding: EdgeInsets.only(bottom: 20.h),
                                shrinkWrap: true,
                                itemCount: type.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final isSelected = selectedIndex == index;

                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 2.h),
                                    child: InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,

                                      onTap: () {
                                        selectedIndex = index;
                                        estinateInvoicesname = type[index];
                                        selectedTypeNotifier.value = estinateInvoicesname;

                                        widget.onSelected(estinateInvoicesname!);

                                        setState(() {}); // ✅ Trigger UI refresh (if needed visually)

                                        Navigator.pop(context); // ✅ Close the dialog
                                      },





                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                                        child: Container(
                                          width: double.infinity,
                                          height: 35.h,
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.purpleShade : Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: isSelected ? AppColors.purple : Colors.transparent,
                                            ),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: 150.w,
                                                    child: CustomText(
                                                      text: type[index],
                                                      fontWeight: FontWeight.w500,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      size: 18.sp,
                                                      color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,

                                                    ),
                                                  ),
                                                  if (isSelected)
                                                    Expanded(
                                                      flex:
                                                      1,
                                                      child: const HeroIcon(HeroIcons.checkCircle,
                                                          style: HeroIconStyle.solid,
                                                          color: AppColors.purple),
                                                    )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },

                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  height: 40.h,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(

                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.greyColor)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child:ValueListenableBuilder<String?>(
                          valueListenable: selectedTypeNotifier,
                          builder: (context, value, _) {
                            return CustomText(
                              text: value?.isEmpty ?? true
                                  ? AppLocalizations.of(context)!.pleaseselect
                                  : value!,
                              fontWeight: FontWeight.w500,
                              size: 14.sp,
                              color: Theme.of(context).colorScheme.textClrChange,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            );
                          },
                        ),

                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

}





