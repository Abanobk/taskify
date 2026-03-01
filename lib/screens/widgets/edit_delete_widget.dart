import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/config/colors.dart';

class EditDeleteWidget extends StatefulWidget {
  const EditDeleteWidget({super.key});

  @override
  State<EditDeleteWidget> createState() => _EditDeleteWidgetState();
}

class _EditDeleteWidgetState extends State<EditDeleteWidget> {
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
        // color: Colors.red,
      height: 30.h,
      child: Container(
        width: 30.w,
        // color: Colors.yellow,
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: PopupMenuButton(
          padding: EdgeInsets.zero,

          // shadowColor:
          // Color(0x4D000000),
          position:
          PopupMenuPosition
              .over,
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).colorScheme.textClrChange,
            size: 15.sp,
          ),
          // iconSize: 20,
          constraints:
          BoxConstraints(
            // maxHeight: 100.h,
              maxWidth: 35.w),
          color: Theme.of(context).colorScheme.containerDark,
          popUpAnimationStyle:
          AnimationStyle(
              duration:
              const Duration(
                  milliseconds:
                  100)),
          offset: Offset(-1.w, 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.w),),),
          itemBuilder: (BuildContext
          context) =>
          [
            PopupMenuItem<String>(
              height: 30,
              padding: EdgeInsets.zero,
              value: 'Edit',
              child: Container(
                // color: Colors.red,
                alignment: Alignment.center,
                child:  HeroIcon(

                  HeroIcons
                      .pencilSquare,
                  style: HeroIconStyle
                      .outline,
                  color: Theme.of(context)
                      .colorScheme
                      .textClrChange,
                  size: 20.sp,
                ),
              ),
            ),
            PopupMenuItem<String>(
              height: 30,
              padding: EdgeInsets.zero,
              value:
              'Delete',
              child: Container(
                // color: Colors.red,
                alignment: Alignment.center,
                child:  HeroIcon(

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
        ),
      ),
    );
  }
}
