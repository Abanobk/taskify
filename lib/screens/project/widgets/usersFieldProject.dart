import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';

import '../../../config/colors.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/strings.dart';
import '../../../data/model/Project/all_project.dart';
import '../../../data/model/task/task_model.dart';
import '../../../data/repositories/Project/project_repo.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_data.dart';
import '../../widgets/custom_cancel_create_button.dart';

class UsersFieldProject extends StatefulWidget {
  final bool? isRequired;
  final bool isCreate;
  final bool? isMeeting;
  final List<String> usersname;
  final List<int> usersid;
  final int projectId;
  final List<Tasks> project;
  final Function(List<String>, List<int>) onSelected;

  const UsersFieldProject({
    super.key,
    this.isRequired = false,
    required this.usersid,
    required this.isCreate,
    required this.projectId,
    this.isMeeting,
    required this.usersname,
    required this.project,
    required this.onSelected,
  });

  @override
  State<UsersFieldProject> createState() => _UsersFieldProjectState();
}

class _UsersFieldProjectState extends State<UsersFieldProject> {
  String? projectsname;
  int? projectsId;
  List<int> userSelectedId = [];
  List<String> userSelectedname = [];
  String searchWord = "";
  int? userId;
  final TextEditingController _userSearchController = TextEditingController();
  List<ProjectUsers> filteredUsers = [];
  int itemsPerPage = 20; // Number of items to show per "page"
  int currentPage = 1; // Current page for pagination
  bool hasReachedMax = false;

  @override
  void initState() {
    super.initState();
    // Initialize selected users
    for (int i = 0; i < widget.usersid.length; i++) {
      final id = widget.usersid[i];
      if (!userSelectedId.contains(id)) {
        userSelectedId.add(id);
        if (widget.usersname.isNotEmpty) {
          userSelectedname.add(widget.usersname[i]);
        }
      }
    }
    // Fetch users for the project
    getUsersOfProject().then((_) {
      setState(() {
        // Initialize filtered users with the project users
        hasReachedMax = filteredUsers.length <= itemsPerPage;
      });
      // Get user ID from Hive and handle meeting case
      getUserId().then((_) {
        if (widget.isCreate && userId != null && widget.isMeeting == true) {
          if (!userSelectedId.contains(userId)) {
            userSelectedId.add(userId!);
            final user = filteredUsers.firstWhere(
                  (user) => user.id == userId,
              orElse: () => ProjectUsers(id: userId, firstName: "Current User"),
            );
            userSelectedname.add(user.firstName ?? "Current User");
            widget.onSelected(userSelectedname, userSelectedId);
          }
        }
      });
    });
  }

  Future<void> getUsersOfProject() async {
    List<ProjectModel> project = [];
    Map<String, dynamic> result = await ProjectRepo().getProjects(
      id: widget.projectId,
    );
    project = List<ProjectModel>.from(
        result['data'].map((projectData) => ProjectModel.fromJson(projectData)));
    setState(() {
      filteredUsers = project.isNotEmpty && project[0].users != null ? project[0].users! : [];
    });
  }

  Future<void> getUserId() async {
    var userbox = await Hive.openBox(userBox);
    userId = userbox.get('user_id');
  }

  // Filter users based on search query
  void filterUsers(String query) {
    setState(() {
      searchWord = query;
      if (query.isEmpty) {
        getUsersOfProject().then((_) {
          setState(() {
            hasReachedMax = filteredUsers.length <= itemsPerPage * currentPage;
          });
        });
      } else {
        filteredUsers = filteredUsers.where((user) {
          return user.firstName!.toLowerCase().contains(query.toLowerCase()) ||
              (user.lastName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              (user.email?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
        currentPage = 1; // Reset pagination on search
        hasReachedMax = filteredUsers.length <= itemsPerPage * currentPage;
      }
    });
  }

  // Load more users for pagination
  void loadMoreUsers() {
    setState(() {
      currentPage++;
      hasReachedMax = filteredUsers.length <= itemsPerPage * currentPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    bool isLightTheme = currentTheme is LightThemeState;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.users,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16.sp,
                fontWeight: FontWeight.w700,
              ),
              widget.isRequired == true
                  ? const CustomText(
                text: " *",
                color: AppColors.red,
                size: 15,
                fontWeight: FontWeight.w400,
              )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => StatefulBuilder(
                    builder: (BuildContext context, void Function(void Function()) setState) {
                      ScrollController scrollController = ScrollController();
                      scrollController.addListener(() {
                        if (scrollController.position.atEdge &&
                            scrollController.position.pixels != 0 &&
                            !hasReachedMax) {
                          loadMoreUsers();
                        }
                      });

                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
                        contentPadding: EdgeInsets.zero,
                        title: Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Column(
                              children: [
                                CustomText(
                                  text: AppLocalizations.of(context)!.selectuser,
                                  fontWeight: FontWeight.w800,
                                  size: 20.sp,
                                  color: Theme.of(context).colorScheme.whitepurpleChange,
                                ),
                                const Divider(),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0.w),
                                  child: SizedBox(
                                    height: 35.h,
                                    width: double.infinity,
                                    child: TextField(
                                      cursorColor: AppColors.greyForgetColor,
                                      cursorWidth: 1,
                                      controller: _userSearchController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: (35.h - 20.sp) / 2,
                                          horizontal: 10.w,
                                        ),
                                        hintText: AppLocalizations.of(context)!.search,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: AppColors.greyForgetColor,
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: AppColors.purple,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          filterUsers(value);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5.h),
                              ],
                            ),
                          ),
                        ),
                        content: Container(
                          constraints: BoxConstraints(maxHeight: 900.h),
                          width: MediaQuery.of(context).size.width,
                          child: filteredUsers.isEmpty?NoData(isImage: true,):ListView.builder(
                            controller: scrollController,
                            shrinkWrap: true,
                            itemCount: hasReachedMax
                                ? filteredUsers.length
                                : (filteredUsers.length > itemsPerPage * currentPage
                                ? itemsPerPage * currentPage + 1
                                : filteredUsers.length + 1),
                            itemBuilder: (BuildContext context, int index) {
                              if (index < filteredUsers.length && index < itemsPerPage * currentPage) {
                                final user = filteredUsers[index];
                                final isSelected = userSelectedId.contains(user.id);

                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.h),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          final removeIndex = userSelectedId.indexOf(user.id!);
                                          userSelectedId.removeAt(removeIndex);
                                          userSelectedname.removeAt(removeIndex);
                                        } else {
                                          userSelectedId.add(user.id!);
                                          userSelectedname.add(user.firstName!);
                                        }
                                        widget.onSelected(userSelectedname, userSelectedId);
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                                      child: Container(
                                        width: double.infinity,
                                        height: 60.h,
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.purpleShade : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isSelected ? AppColors.purple : Colors.transparent,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 7,
                                                child: SizedBox(
                                                  width: 200.w,
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 20,
                                                        backgroundImage: NetworkImage(user.photo ?? ''),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:  EdgeInsets.only(left: 8.w),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Flexible(
                                                                    child: CustomText(
                                                                      text: user.firstName ?? '',
                                                                      fontWeight: FontWeight.w500,
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      size: 18.sp,
                                                                      color: isSelected
                                                                          ? AppColors.primary
                                                                          : Theme.of(context).colorScheme.textClrChange,
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 5.w),
                                                                  Flexible(
                                                                    child: CustomText(
                                                                      text: user.lastName ?? '',
                                                                      fontWeight: FontWeight.w500,
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      size: 18.sp,
                                                                      color: isSelected
                                                                          ? AppColors.primary
                                                                          : Theme.of(context).colorScheme.textClrChange,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Flexible(
                                                                    child: CustomText(
                                                                      text: user.email ?? '',
                                                                      fontWeight: FontWeight.w500,
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      size: 18.sp,
                                                                      color: isSelected
                                                                          ? AppColors.primary
                                                                          : Theme.of(context).colorScheme.textClrChange,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              isSelected
                                                  ? Expanded(
                                                flex: 1,
                                                child: const HeroIcon(
                                                  HeroIcons.checkCircle,
                                                  style: HeroIconStyle.solid,
                                                  color: AppColors.purple,
                                                ),
                                              )
                                                  : const SizedBox.shrink(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 0),
                                  child: Center(
                                    child: hasReachedMax
                                        ? const Text('')
                                        : const SpinKitFadingCircle(
                                      color: AppColors.primary,
                                      size: 40.0,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        actions: [
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: CreateCancelButtom(
                              title: "OK",
                              onpressCancel: () {
                                _userSearchController.clear();
                                setState(() {
                                  filterUsers('');
                                  userSelectedname=[];
                                  userSelectedId=[];// Reset search
                                });
                                Navigator.pop(context);
                              },
                              onpressCreate: () {
                                _userSearchController.clear();
                                setState(() {
                                  filterUsers(''); // Reset search
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
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
                  color: Theme.of(context).colorScheme.backGroundColor,
                  boxShadow: [
                    isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomText(
                        text: widget.isCreate
                            ? (userSelectedname.isNotEmpty
                            ? userSelectedname.join(", ")
                            : AppLocalizations.of(context)!.selectusers)
                            : (widget.usersname.isNotEmpty
                            ? widget.usersname.join(", ")
                            : AppLocalizations.of(context)!.selectusers),
                        fontWeight: FontWeight.w500,
                        size: 14.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}