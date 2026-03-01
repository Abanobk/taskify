import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/config/colors.dart';

import '../../../utils/widgets/custom_text.dart';

// class ReusableDropdown<T> extends StatelessWidget {
//   final List<DropdownMenuItem<T>> items;
//   final T? value;
//   final void Function(T?)? onChanged;
//   final String? hintText;
//   final double? borderRadius;
//   final Color? borderColor;
//   final EdgeInsetsGeometry? padding;
//
//   const ReusableDropdown({
//     Key? key,
//     required this.items,
//     required this.onChanged,
//     this.value,
//     this.hintText,
//     this.borderRadius,
//     this.borderColor,
//     this.padding,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Determine color of selected text based on whether the current value is in highlightValues
//     final bool isHighlighted = value != null && (items.contains(value) ?? false);
//     final Color selectedTextColor = isHighlighted ? Colors.red : Theme.of(context).colorScheme.textChange;
//
//     return    DropdownButtonFormField<T>(
//       value: value,
//       items: items,
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         contentPadding: EdgeInsets.symmetric(horizontal: 12),
//         filled: true,
//         fillColor: Theme.of(context).colorScheme.backGroundColor,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: borderColor ?? Colors.grey),
//         ),
//
//       ),
//       dropdownColor: Theme.of(context).colorScheme.containerDark,
//       style: TextStyle(color: selectedTextColor,fontSize: 14.sp,fontWeight:  FontWeight.w500,), // selected text color
//     );
//
//   }
// }

// class ReusableDropdownDialog<T> extends StatelessWidget {
//   final List<DropdownMenuItem<T>> items;
//   final T? value;
//   final void Function(T?)? onChanged;
//   final String? hintText;
//   final double? borderRadius;
//   final Color? borderColor;
//   final EdgeInsetsGeometry? padding;
//
//   const ReusableDropdownDialog({
//     Key? key,
//     required this.items,
//     required this.onChanged,
//     this.value,
//     this.hintText,
//     this.borderRadius,
//     this.borderColor,
//     this.padding,
//   }) : super(key: key);
//
//   void _openSelectionDialog(BuildContext context) async {
//     final selected = await showDialog<T>(
//       context: context,
//       builder: (context) {
//         return SimpleDialog(
//           title: hintText != null ? Text(hintText!) : null,
//           children: items.map((item) {
//             final bool isSelected = item.value == value;
//             return SimpleDialogOption(
//               onPressed: () => Navigator.pop(context, item.value),
//               child: Container(
//                 color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: Text(
//                   item.child is Text ? (item.child as Text).data ?? '' : item.value.toString(),
//                   style: TextStyle(
//                     color: isSelected ? Colors.blue : Colors.black,
//                     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//
//     if (selected != null && onChanged != null) {
//       onChanged!(selected);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Show label for current selected value or hint
//     String displayText = hintText ?? '';
//     for (var item in items) {
//       if (item.value == value) {
//         if (item.child is Text) {
//           displayText = (item.child as Text).data ?? '';
//         } else {
//           displayText = item.value.toString();
//         }
//         break;
//       }
//     }
//
//     return GestureDetector(
//       onTap: () => _openSelectionDialog(context),
//       child: Container(
//         padding: padding ?? EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.background,
//           borderRadius: BorderRadius.circular(borderRadius ?? 12),
//           border: Border.all(color: borderColor ?? Colors.grey),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Text(
//                 displayText,
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w500,
//                   color: value == null
//                       ? Colors.grey
//                       : Theme.of(context).colorScheme.onBackground,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             const Icon(Icons.arrow_drop_down),
//           ],
//         ),
//       ),
//     );
//   }
// }

class ReusableDropdownDialog<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?)? onChanged;
  final String? hintText;
  final double? borderRadius;
  final Color? borderColor;
  final bool isDetails;
  final EdgeInsetsGeometry? padding;

  const ReusableDropdownDialog({
    Key? key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hintText,
    this.isDetails =false,
    this.borderRadius,
    this.borderColor,
    this.padding,
  }) : super(key: key);

  void _openSelectionDialog(BuildContext context) async {
    final selected = await showDialog<T>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: hintText != null ? Text(hintText!) : null,

          backgroundColor: Theme.of(context)
              .colorScheme
              .alertBoxBackGroundColor,
          children: items.map((item) {
            final bool isSelected = item.value == value;
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, item.value),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.purpleShade
                      : Colors.transparent,
                  borderRadius:
                  BorderRadius.circular(10),
                  border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child:  Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                      children: [
                        CustomText(
                          text: item.child is Text ? (item.child as Text).data ?? '' : item.value.toString(),
                          fontWeight:
                          FontWeight.w500,
                          size: 18,
                          color: isSelected
                              ? AppColors.purple
                              : Theme.of(context)
                              .colorScheme
                              .textClrChange,
                        ),
                        if (isSelected)
                          const HeroIcon(
                            HeroIcons.checkCircle,
                            style:
                            HeroIconStyle.solid,
                            color: AppColors.purple,
                          ),
                      ],
                    ),
                  ),
                ),

              ),
            );
          }).toList(),
        );
      },
    );

    if (selected != null && onChanged != null) {
      onChanged!(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show label for current selected value or hint
    String displayText = hintText ?? 'Select an option';
    if (value != null) {
      for (var item in items) {
        if (item.value == value) {
          displayText = item.child is Text
              ? (item.child as Text).data ?? item.value.toString()
              : item.value.toString();
          break;
        }
      }
    }

    return GestureDetector(
      onTap: () => _openSelectionDialog(context),
      child: Container(
        padding: padding ?? EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color:
            isDetails ?                  Theme.of(context).colorScheme.detailsOverlay:Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          border: Border.all(
            color: AppColors.greyColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: value == null
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}