import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/config/colors.dart';

import '../../../utils/widgets/custom_text.dart';
import '../../../../src/generated/i18n/app_localizations.dart';

class TaxTypeField extends StatefulWidget {
  final bool isRequired;
  final bool isCreate;
  final String? access;
  final String? from;
  final bool? isFilter;
  final Function(String) onSelected;

  const TaxTypeField({
    super.key,
    required this.isRequired,
    required this.isCreate,
    required this.access,
    required this.from,
    this.isFilter = false,
    required this.onSelected,
  });

  @override
  State<TaxTypeField> createState() => _TaxTypeFieldState();
}

class _TaxTypeFieldState extends State<TaxTypeField> {
  String? projectsname;
  List<String> type = ["Amount", "Percentage"];
  late ValueNotifier<String?> selectedTypeNotifier;

  @override
  void initState() {
    super.initState();
    // Map access to display value regardless of isCreate
    if (widget.from == "type") {
      switch (widget.access?.toLowerCase()) {
        case "amount":
          projectsname = "Amount";
          break;
        case "percentage":
          projectsname = "Percentage";
          break;
        case "":
        case null:
          projectsname = null;
          break;
        default:
          projectsname = null;
          break;
      }
    }
    selectedTypeNotifier = ValueNotifier<String?>(projectsname);
  }

  @override
  void dispose() {
    selectedTypeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildContent() {
      switch (widget.from) {
        case "type":
          return buildWidget(title: AppLocalizations.of(context)!.type, type: type);
        default:
          return const SizedBox.shrink();
      }
    }

    return buildContent();
  }

  Widget buildWidget({required String title, required List<String> type}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              CustomText(
                text: title,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              if (widget.isRequired)
                const CustomText(
                  text: " *",
                  color: AppColors.red,
                  size: 15,
                  fontWeight: FontWeight.w400,
                ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            int selectedIndex = type.contains(projectsname) ? type.indexOf(projectsname!) : -1;
          widget.isCreate ?  showDialog(
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
                        child: ListView.builder(
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
                                  setState(() {
                                    selectedIndex = index;
                                    projectsname = type[index];
                                    selectedTypeNotifier.value = projectsname;
                                    widget.onSelected(projectsname!.toLowerCase()); // Pass lowercase to DeductionScreen
                                  });
                                  Navigator.pop(context);
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
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : Theme.of(context).colorScheme.textClrChange,
                                              ),
                                            ),
                                            if (isSelected)
                                              const HeroIcon(
                                                HeroIcons.checkCircle,
                                                style: HeroIconStyle.solid,
                                                color: AppColors.purple,
                                              ),
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
            ):SizedBox();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            height: 40.h,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color:widget.isCreate? Colors.transparent: Theme.of(context).colorScheme.detailsOverlay
        ,


              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.greyColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ValueListenableBuilder<String?>(
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
                if (widget.isCreate) const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}