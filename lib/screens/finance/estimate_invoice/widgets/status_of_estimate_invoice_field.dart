import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/screens/widgets/no_data.dart';

import '../../../../utils/widgets/custom_text.dart';
import '../../../../src/generated/i18n/app_localizations.dart';

class EstimateInvoiceStatusField extends StatefulWidget {
  final bool isRequired;
  final bool isCreate;
  final String? access;
  final String? from;
  final String? type;
  final Function(String) onSelected;

  const EstimateInvoiceStatusField({
    super.key,
    required this.isRequired,
    required this.type,
    required this.isCreate,
    required this.access,
    required this.from,
    required this.onSelected,
  });

  @override
  State<EstimateInvoiceStatusField> createState() => _EstimateInvoiceStatusFieldState();
}

class _EstimateInvoiceStatusFieldState extends State<EstimateInvoiceStatusField> {
  String? estinateInvoiceStatusname;
  String? name;
  late ValueNotifier<String?> selectedTypeNotifier;

  final List<String> estimateType = [
    "Sent",
    "Accepted",
    "Draft",
    "Declined",
    "Expired",
  ];
  final List<String> invoiceType = [
    "Fully Paid",
    "Partially Paid",
    "Draft",
    "Cancelled",
    "Due",
  ];

  @override
  void initState() {
    super.initState();
    print("Initial type: ${widget.type}, access: ${widget.access}");
    name = widget.access;
    estinateInvoiceStatusname = _getInitialStatus(widget.access?.toLowerCase(), widget.type);
    selectedTypeNotifier = ValueNotifier<String?>(estinateInvoiceStatusname);
  }

  @override
  void didUpdateWidget(covariant EstimateInvoiceStatusField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      print("Type changed from ${oldWidget.type} to ${widget.type}");
      final statusOptions = widget.type?.toLowerCase() == "estimate" ? estimateType : invoiceType;
      // Reset estinateInvoiceStatusname if it's not valid for the new type
      if (!statusOptions.contains(estinateInvoiceStatusname)) {
        estinateInvoiceStatusname = null;
        selectedTypeNotifier.value = null;
        widget.onSelected(""); // Notify parent of reset
      }
    }
  }

  String? _getInitialStatus(String? access, String? type) {
    if (widget.from != "status" || widget.isCreate) {
      return access?.isEmpty ?? true ? null : access;
    }
    final statusOptions = type?.toLowerCase() == "estimate" ? estimateType : invoiceType;
    if (statusOptions.contains(access)) {
      return access;
    }
    switch (access) {
      case "sent":
        return "Sent";
      case "accepted":
        return "Accepted";
      case "draft":
        return "Draft";
      case "declined":
        return "Declined";
      case "expired":
        return "Expired";
      case "fully_paid":
        return "Fully Paid";
      case "partially_paid":
        return "Partially Paid";
      case "cancelled":
        return "Cancelled";
      case "due":
        return "Due";
      case "":
      case null:
        return null;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusOptions = widget.type?.toLowerCase() == "estimate" ? estimateType : invoiceType;
    print("Building with type: ${widget.type}, statusOptions: $statusOptions");

    Widget buildContent() {
      if (widget.from != "status") {
        return const SizedBox.shrink();
      }
      return buildWidget(
        title: AppLocalizations.of(context)!.status,
        type: statusOptions,
      );
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
            int selectedIndex = type.contains(estinateInvoiceStatusname)
                ? type.indexOf(estinateInvoiceStatusname!)
                : -1;

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
                        child:type.isEmpty?NoData(isImage: true,): ListView.builder(
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
                                    estinateInvoiceStatusname = type[index];
                                    selectedTypeNotifier.value = estinateInvoiceStatusname;
                                    widget.onSelected(estinateInvoiceStatusname!);
                                  });
                                  Navigator.pop(context); // Close dialog after selection
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
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            height: 40.h,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
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
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}