import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/bloc/candidate/candidates_bloc.dart';
import 'package:taskify/bloc/candidate/candidates_event.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/dashboard_stats/dash_board_stats_bloc.dart';
import '../../bloc/dashboard_stats/dash_board_stats_event.dart';
import '../../bloc/languages/language_switcher_bloc.dart';
import '../../bloc/notifications/push_notification/notification_push_bloc.dart';
import '../../bloc/notifications/push_notification/notification_push_event.dart';
import '../../bloc/project_id/projectid_bloc.dart';
import '../../bloc/project_id/projectid_event.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../data/localStorage/hive.dart';
import '../../routes/routes.dart';
import '../../screens/dash_board/dashboard.dart';

class BackArrow extends StatefulWidget {
  final String? title;
  final int? projectId;
  final String? caseTitle;
  final String? caseDesc;
  final bool? iscreatePermission;
  final bool isDetailPage;
  final bool? isAdd;
  final bool? isFromNotification;
  final bool? iSBackArrow;
  final bool? isBottomSheet;
  final bool? isCase;
  final bool isFav;
  final String? fromNoti;
  final bool? fromDash;
  final bool isPen;
  final bool value;
  final bool? isEditFromDetail;
  final bool? isDeleteFromDetail;
  final bool? isEditCreate;
  final GlobalKey? caseKey;
  final Color? color;
  final VoidCallback? onPress;
  final VoidCallback? onTap;
  final VoidCallback? onFav;
  final String? discussionScreen ;
  final bool? refresh;
  final VoidCallback? onRefresh;
  final bool? mindMap;
  final bool? download;
  final VoidCallback? onDownload;
  final VoidCallback? onMindMap;
  final bool? format;
  final VoidCallback? onReformat;

  const BackArrow(
      {super.key,
      this.iscreatePermission,
        this.refresh,
        this.download,
        this.onDownload,
        this.onRefresh,
        this.isEditCreate,
      this.title,
        this.discussionScreen,
      this.fromNoti,
      this.isPen=false,
        this.onTap,
        this.value= false,
        this.isDetailPage = false,
        this.isEditFromDetail,
        this.isDeleteFromDetail,
        this.isBottomSheet,
      this.isFromNotification,
      this.isAdd,
      this.fromDash,
        this.projectId,
        this.mindMap,
        this.onMindMap,
      this.onPress,
        this.onFav,
      this.iSBackArrow,
      this.color,
      this.isFav=false,
      this.caseKey,
      this.caseDesc,
      this.caseTitle,
      this.format,
      this.onReformat,
      this.isCase});

  @override
  State<BackArrow> createState() => _BackArrowState();
}

class _BackArrowState extends State<BackArrow> {
  bool isRtl = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  // Future<String> getLang() async {
  //   final hiveStorage = HiveStorage();
  //   language = await hiveStorage.getLanguage();
  //   print("ftyuhijkm,l $language");
  //
  //   return language ?? defaultLanguage;
  // }
  Future<void> _checkRtlLanguage() async {
    final languageCode = await HiveStorage().getLanguage();
    isRtl = LanguageBloc.instance.isRtlLanguage(languageCode ?? defaultLanguage);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // getLang();
    _checkRtlLanguage();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: widget.isBottomSheet==true ?EdgeInsets.zero:EdgeInsets.only(top: 45.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.iSBackArrow == false
                  ? const SizedBox.shrink()
                  : InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: widget.onTap ??() {

                        BlocProvider.of<DashBoardStatsBloc>(context)
                            .add(StatsList());
                        BlocProvider.of<NotificationPushBloc>(context).add(NotificationPushList());
                        if (widget.fromDash == true) {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => const DashBoard(
                                  initialIndex: 0), // Navigate to index 1
                            ),
                          );
                        }    else if (widget.discussionScreen == "projectDiscussion") {
                          // if (widget.fromDetail == true) {
                            print("sjgfjkgfjf ");
                            BlocProvider.of<ProjectidBloc>(context).add(ProjectIdListId(widget.projectId));
                             router.pop(context);
                        }else if (widget.discussionScreen == "candidateDiscussion") {
                          // if (widget.fromDetail == true) {
                            print("sjgfjkgfjf ");
                            BlocProvider.of<CandidatesBloc>(context).add(CandidatesList(id:widget.projectId));
                             router.pop(context);
                        }
                        else if (widget.fromNoti == "project") {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => const DashBoard(
                                  initialIndex: 1), // Navigate to index 1
                            ),
                          );
                        }
                        else if (widget.isFromNotification == true &&
                            widget.fromNoti == "task") {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => const DashBoard(
                                  initialIndex: 2), // Navigate to index 1
                            ),
                          );
                        }
                        else if (widget.isFromNotification == true &&
                                widget.fromNoti == "leaverequest" ||
                            widget.fromNoti == "workspace" ||
                            widget.fromNoti == "meeting") {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => const DashBoard(
                                  initialIndex: 0), // Navigate to index 1
                            ),
                          );
                        } else {
                          print("deasrewerwewe ");
                          router.pop(context);
                        }

                        // Navigator.pop(context);
                      },
                      child: Container(
                        height: 30.h,
                        width: 30.w,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: AppColors.primary),
                        child: isRtl
                            ? HeroIcon(

                                size: 15.sp,
                                HeroIcons.chevronRight,
                                style: HeroIconStyle.solid,
                                color: AppColors.pureWhiteColor,
                              )
                            : HeroIcon(
                                size: 15.sp,
                                HeroIcons.chevronLeft,
                                style: HeroIconStyle.solid,
                          color: AppColors.pureWhiteColor,
                              )

                      ),
                    ),
              widget.iSBackArrow == false
                  ? const SizedBox.shrink()
                  : SizedBox(
                      width: 50.w,
                    ),
              CustomText(
                text: widget.title!,
                fontWeight: FontWeight.w700,
                size: 18,
                color:
                    widget.color ?? Theme.of(context).colorScheme.textClrChange,
              ),
            ],
          ),
          (widget.isAdd == true && widget.iscreatePermission == true)
              ? InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: widget.onPress,
            child: Container(
              height: 30.h,
              width: 34.w,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: AppColors.primary),
              child: const HeroIcon(
                size: 15,
                HeroIcons.plus,
                style: HeroIconStyle.outline,
                color: AppColors.pureWhiteColor,
              ),
            ),
          )
              : widget.isPen == true
              ? InkWell(
            highlightColor: Colors.transparent, // No highlight on tap
            splashColor: Colors.transparent,
            onTap: widget.onPress,
            child: const Icon(
              Icons.edit,
              size: 25,
              color: Colors.blue,
            ),
          )
              : widget.isFav
              ? InkWell(
            highlightColor: Colors.transparent, // No highlight on tap
            splashColor: Colors.transparent,
            onTap: widget.onFav,
            child: const Icon(
              Icons.favorite,
              size: 25,
              color: Colors.red,
            ),
          )
              : const SizedBox.shrink(),
          if (widget.refresh == true)
            InkWell(
              highlightColor: Colors.transparent, // No highlight on tap
              splashColor: Colors.transparent,
              onTap: widget.onRefresh,
              child: const Icon(
                Icons.refresh,
                size: 20,
                color: Colors.grey,
              ),
            ), if (widget.format == true)
            InkWell(
              highlightColor: Colors.transparent, // No highlight on tap
              splashColor: Colors.transparent,
              onTap: widget.onReformat,
              child:  HeroIcon(
                widget.value
                    ? HeroIcons.bars3
                    : HeroIcons.square2Stack, // ✅ Use `value`
                style: HeroIconStyle.solid,
                color: Theme.of(context).colorScheme.textFieldColor,
                size: 20.sp,
              ),
            ),
          if (widget.mindMap == true)
            InkWell(
                highlightColor: Colors.transparent, // No highlight on tap
                splashColor: Colors.transparent,
              onTap: widget.onMindMap,
              child:Icon(Icons.account_tree_outlined, size: 20, color: Theme.of(context).colorScheme.textFieldColor,)
            ),
          if (widget.download == true)
            InkWell(
              highlightColor: Colors.transparent, // No highlight on tap
              splashColor: Colors.transparent,
              onTap: widget.onDownload,
              child: HeroIcon(
                 HeroIcons.arrowDownTray, // ✅ Use `value`
                style: HeroIconStyle.solid,
                color: Theme.of(context).colorScheme.textFieldColor,
                size: 20.sp,
              ),
            ),


        ],
      ),
    );
  }
}
