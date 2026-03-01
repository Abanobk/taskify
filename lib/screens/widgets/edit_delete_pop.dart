import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/config/colors.dart';


class CustomPopupMenuButton extends StatelessWidget {
  final bool isEditAllowed;
  final bool isDeleteAllowed;
  final Future<void> Function()? onEdit;
  final Future<void> Function()? onDelete;
  final void Function(String value)? onSelected;

  const CustomPopupMenuButton({
    super.key,
    required this.isEditAllowed,
    required this.isDeleteAllowed,
    this.onEdit,this.onSelected,this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.over,
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface,
        size: 20.sp,
      ),
      constraints: BoxConstraints(maxWidth: 35.w),
        color: Theme.of(context)
            .colorScheme
            .popupBackGroundColor,
      offset: Offset(-1.w, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.w)),
      ),
      itemBuilder: (BuildContext context) => [
        if (isEditAllowed)
          PopupMenuItem<String>(
            height: 30.h,
            padding: EdgeInsets.zero,
            value: 'Edit',
            child: Container(
              alignment: Alignment.center,
              child: HeroIcon(

                HeroIcons.pencilSquare,
                style: HeroIconStyle
                    .outline,
                color: Theme.of(context)
                    .colorScheme
                    .textClrChange,
                size: 20.sp,
              ),
            ),
          ),
        if (isDeleteAllowed)
          PopupMenuItem<String>(
            height: 30.h,
            padding: EdgeInsets.zero,
            value: 'Delete',
            child: Container(
              alignment: Alignment.center,
              child:HeroIcon(

                HeroIcons.trash,
                style: HeroIconStyle
                    .outline,
                color: Theme.of(context)
                    .colorScheme
                    .textClrChange,
                size: 20.sp,
              ),
            ),
          ),
      ],
      onSelected:onSelected
    );
  }
}
