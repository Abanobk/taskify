import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import '../../../bloc/single_user/single_user_bloc.dart';
import '../../../bloc/single_user/single_user_event.dart';
import '../../../bloc/single_user/single_user_state.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/custom_cancel_create_button.dart';

class SingleUserField extends StatefulWidget {
  final bool isCreate;
  final String? name;
  final bool? from;
  final String? title;
  final bool? isRequired;
  final int? index;
  final bool? isEditLeaveReq;
  final List<int>? userId;
  final Function(String, int, String, String) onSelected;
  const SingleUserField(
      {super.key,
        required this.isCreate,
        this.name,
        this.title,
        this.from,
        this.isRequired = false,
        this.userId,
        this.isEditLeaveReq,
        required this.index,
        required this.onSelected});

  @override
  State<SingleUserField> createState() => _SingleUserFieldState();
}

class _SingleUserFieldState extends State<SingleUserField> {
  String? usersname;
  String? email;
  String? profile;
  int? usersId;
  List<int> userSelectedId = [];

  @override
  void initState() {
    print("rffnsd ${widget.title}");
    if (!widget.isCreate && widget.index != null) {
      usersname = widget.name;
      if (widget.from == true) {
        usersId = widget.index;
        userSelectedId.addAll(widget.userId!);
      }
      // Fetch user list on init
      BlocProvider.of<SingleUserBloc>(context).add(SingleUserList());
    }
    super.initState();
  }

  // Only fetch user list when needed
  void _fetchUserList() {
    BlocProvider.of<SingleUserBloc>(context).add(SingleUserList());
  }

  void _showUserSelectionDialog() {
    _fetchUserList(); // Fetch users initially

    showDialog(
      context: context,
      builder: (ctx) {
        return _UserSelectionDialog(
          title: widget.title,
          userSelectedId: userSelectedId,
          onUserSelected: (selectedName, selectedId, selectedEmail, selectedProfile) {
            setState(() {
              userSelectedId.clear();
              usersname = selectedName;
              usersId = selectedId;
              email = selectedEmail;
              profile = selectedProfile;
              userSelectedId.add(selectedId);
            });
            widget.onSelected(selectedName, selectedId, selectedEmail, selectedProfile);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("cfgbhjnkm ");
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: Row(
            children: [
              CustomText(
                text: (widget.title != null && widget.title != "")
                    ? widget.title!
                    : AppLocalizations.of(context)!.user,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16.sp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w700,
              ),
              widget.isRequired == true
                  ? const CustomText(
                text: " *",
                color: AppColors.red,
                size: 15,
                fontWeight: FontWeight.w400,
              )
                  : SizedBox(),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        BlocBuilder<SingleUserBloc, SingleUserState>(
          builder: (context, state) {
            print("ghjuki $state");
            return AbsorbPointer(
              absorbing: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      if (widget.from == true || widget.isCreate) {
                        _showUserSelectionDialog();
                      }
                    },
                    child: widget.from == true
                        ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      height: 40.h,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.greyColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: widget.isCreate
                                ? (usersname?.isEmpty ?? true
                                ? AppLocalizations.of(context)!.selectuser
                                : usersname!)
                                : (usersname?.isEmpty ?? true
                                ? widget.name ?? AppLocalizations.of(context)!.selectuser
                                : usersname!),
                            fontWeight: FontWeight.w400,
                            size: 14.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                          ),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    )
                        : Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      height: 40.h,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: widget.isCreate == true
                            ? Colors.transparent
                            : Theme.of(context).colorScheme.textfieldDisabled,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.greyColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: widget.isCreate
                                ? (usersname?.isEmpty ?? true
                                ? AppLocalizations.of(context)!.selectuser
                                : usersname!)
                                : (usersname?.isEmpty ?? true
                                ? widget.name!
                                : usersname!),
                            fontWeight: FontWeight.w400,
                            size: 14.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                          ),
                          widget.isCreate == false ? SizedBox() : Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        )
      ],
    );
  }
}

// Separate dialog widget to completely isolate from parent BLoC changes
class _UserSelectionDialog extends StatefulWidget {
  final String? title;
  final List<int> userSelectedId;
  final Function(String, int, String, String) onUserSelected;

  const _UserSelectionDialog({
    required this.title,
    required this.userSelectedId,
    required this.onUserSelected,
  });

  @override
  State<_UserSelectionDialog> createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends State<_UserSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  String? selectedName;
  int? selectedId;
  String? selectedEmail;
  String? selectedProfile;
  List<int> localSelectedId = [];
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    localSelectedId = List.from(widget.userSelectedId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_allUsers);
      } else {
        _filteredUsers = _allUsers.where((user) {
          final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
          final email = user.email?.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return fullName.contains(searchLower) || email.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
      contentPadding: EdgeInsets.zero,
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 900.h,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogHeader(),
            Expanded(
              child: BlocConsumer<SingleUserBloc, SingleUserState>(
                listener: (context, state) {
                  // Update users list only when we get new data
                  if (state is SingleUserSuccess) {
                    _allUsers = List.from(state.user);
                    if (_isInitialLoad) {
                      _filteredUsers = List.from(_allUsers);
                      _isInitialLoad = false;
                    } else {
                      // Apply current filter to new data
                      _filterUsers(_searchController.text);
                    }
                  }
                },
                builder: (context, state) {
                  // Always show the current filtered list, regardless of BLoC state
                  if (_filteredUsers.isNotEmpty) {
                    return _buildUserList(state is SingleUserSuccess ? state.isLoadingMore : false);
                  } else if (state is SingleUserSuccess && _allUsers.isEmpty) {
                    return const Center(child: Text('No users found'));
                  } else if (state is SingleUserLoading && _allUsers.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            _buildDialogFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      color: Theme.of(context).colorScheme.alertBoxBackGroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20.h),
          CustomText(
            text: widget.title ?? AppLocalizations.of(context)!.selectuser,
            fontWeight: FontWeight.w800,
            size: 20,
            color: Theme.of(context).colorScheme.whitepurpleChange,
          ),
          const Divider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: SizedBox(
              height: 35.h,
              width: double.infinity,
              child: TextField(
                controller: _searchController,
                cursorColor: AppColors.greyForgetColor,
                cursorWidth: 1,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: (35.h - 20.sp) / 2,
                    horizontal: 10.w,
                  ),
                  hintText: AppLocalizations.of(context)!.search,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.greyForgetColor),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: AppColors.purple),
                  ),
                ),
                onChanged: _filterUsers, // Direct local filtering
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildUserList(bool isLoadingMore) {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.atEdge &&
          scrollController.position.pixels != 0 &&
          isLoadingMore) {
        BlocProvider.of<SingleUserBloc>(context).add(SingleUserLoadMore());
      }
    });

    return _filteredUsers.isEmpty?NoData(isImage: true,):ListView.builder(
      controller: scrollController,
      shrinkWrap: true,
      itemCount: isLoadingMore ? _filteredUsers.length : _filteredUsers.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index < _filteredUsers.length) {
          final user = _filteredUsers[index];
          final isSelected = localSelectedId.contains(user.id!);

          return InkWell(
            onTap: () {
              setState(() {
                localSelectedId.clear();
                selectedName = user.firstName!;
                selectedId = user.id!;
                selectedEmail = user.email!;
                selectedProfile = user.profile!;
                localSelectedId.add(selectedId!);
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 4.h),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.purpleShade : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.purple : Colors.transparent,
                  ),
                ),
                height: 58.h,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(user.profile!),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: "${user.firstName!} ${user.lastName!}",
                            fontWeight: FontWeight.w500,
                            size: 18.sp,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            color: isSelected
                                ? AppColors.primary
                                : Theme.of(context).colorScheme.textClrChange,
                          ),
                          CustomText(
                            text: user.email!,
                            fontWeight: FontWeight.w400,
                            size: 14.sp,
                            overflow: TextOverflow.ellipsis,
                            color: isSelected
                                ? AppColors.primary
                                : Theme.of(context).colorScheme.textClrChange,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const HeroIcon(HeroIcons.checkCircle,
                          style: HeroIconStyle.solid, color: AppColors.purple),
                  ],
                ),
              ),
            ),
          );
        } else {
          return isLoadingMore
              ? Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: const Center(child: CircularProgressIndicator()),
          )
              : const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildDialogFooter() {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
      child: CreateCancelButtom(
        title: "OK",
        onpressCancel: () {
          Navigator.pop(context);
        },
        onpressCreate: () {
          if (selectedId != null) {
            widget.onUserSelected(
                selectedName!, selectedId!, selectedEmail ?? "", selectedProfile ?? "");
            BlocProvider.of<SingleUserBloc>(context).add(
              SelectSingleUser(-1, selectedName!),
            );
          }
          Navigator.pop(context);
        },
      ),
    );
  }
}