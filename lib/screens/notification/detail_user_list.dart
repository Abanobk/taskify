import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../bloc/languages/language_switcher_bloc.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../data/localStorage/hive.dart';
import '../../utils/widgets/custom_text.dart';

class DetailUserList extends StatefulWidget {
  final List<dynamic> list;
  const DetailUserList({super.key, required this.list});

  @override
  State<DetailUserList> createState() => _DetailUserListState();
}

class _DetailUserListState extends State<DetailUserList> {
  bool isRtl = false;
  Future<void> _checkRtlLanguage() async {
    final languageCode = await HiveStorage().getLanguage();
    isRtl =
        LanguageBloc.instance.isRtlLanguage(languageCode ?? defaultLanguage);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkRtlLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120.w,
      height: 35.h,
      // color: Colors.yellow,
      child: Stack(
        children: [
          Padding(
            padding: widget.list.length > 3
                ? EdgeInsets.only(left: 0.w)
                : EdgeInsets.only(left: 0.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (int i = 0; i < (widget.list.length); i++)
                  if (i < 3)
                    Align(
                      widthFactor: 0.75.w,
                      child: CircleAvatar(
                        radius: 15.r,
                        backgroundColor: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.greyColor,
                              width: 1.5.w,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 15.r,
                            backgroundImage:
                                NetworkImage(widget.list[i].photo!),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
          if ((widget.list.length) > 3)
            Positioned(
              top: 3.h,
              // right: getLanguage == "ar" ?55.w:0,
              left: isRtl ? 0 : 50.w,
              right: isRtl ? 45.w : 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.pureWhiteColor,
                    width: 1.5.w,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 13.r,
                  child: CustomText(
                    text: '${widget.list.length - 3}+',
                    color: AppColors.pureWhiteColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
