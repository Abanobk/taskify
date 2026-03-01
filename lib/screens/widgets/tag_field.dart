import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';
import '../../bloc/tags/tags_event.dart';
import '../../bloc/tags/tags_state.dart';
import '../../bloc/tags/tags_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../data/model/tags/tag_model.dart';
import '../../utils/widgets/custom_text.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/no_data.dart';
import '../../utils/widgets/toast_widget.dart';
import 'custom_cancel_create_button.dart';

import '../../../src/generated/i18n/app_localizations.dart';

class TagsField extends StatefulWidget {
  final bool isCreate;
  final bool? isRequired;
  final List<int> tagsid;
  final List<String> usersname;
  final List<TagsModel> project;
  final int? index;
  final Function(List<String>, List<int>) onSelected;
  const TagsField(
      {super.key,
        required this.isCreate,
        required this.usersname,
        this.isRequired,
        required this.tagsid,
        required this.project,
        required this.index,
        required this.onSelected});

  @override
  State<TagsField> createState() => _TagsFieldState();
}

class _TagsFieldState extends State<TagsField> {
  String? projectsname;
  int? projectsId;
  List<int> userSelectedId = [];
  List<String> userSelectedname = [];
  final TextEditingController _tagSearchController = TextEditingController();

  String searchWord = "";
@override
void initState() {
  BlocProvider.of<TagsBloc>(context).add(TagsList());

  super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // userSelectedId.addAll(widget.tagsid);
    // // Ensure the selected names are updated based on the current widget state
    // if (!widget.isCreate) {
    //   userSelectedname = List.from(widget.usersname);
    // }
    print(
      "jksbfk  ${widget.usersname}"
    );
    if (widget.tagsid.isNotEmpty && widget.usersname.isNotEmpty) {
      for (int i = 0; i < widget.tagsid.length; i++) {
        final id = widget.tagsid[i];
        final name = widget.usersname[i]; // Potential source of error

        if (!userSelectedId.contains(id)) {
          userSelectedId.add(id);
          userSelectedname.add(name); // Assuming name is non-null
        }
      }
    }

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
                text: AppLocalizations.of(context)!.tags,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              widget.isRequired == true ?  CustomText(
                text: " *",
                // text: getTranslated(context, 'myweeklyTask'),
                color: AppColors.red,
                size: 15,
                fontWeight: FontWeight.w400,
              ):SizedBox.shrink(),
            ],
          ),
        ),
        // SizedBox(height: 5.h),
        BlocBuilder<TagsBloc, TagsState>(
          builder: (context, state) {
            if (state is TagsInitial) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => BlocBuilder<TagsBloc, TagsState>(
                            builder: (context, state) {
                              if (state is TagsSuccess) {
                                print("fvghjnkmwde  ${state.tag.length}");
                                print("fvghjnkm ${state.isLoadingMore}");
                                final ScrollController scrollController = ScrollController();

                                scrollController.addListener(() {
                                  if (scrollController.position.atEdge &&
                                      scrollController.position.pixels != 0 &&
                                      !state.isLoadingMore) {
                                    BlocProvider.of<TagsBloc>(context).add(TagsLoadMore( search: searchWord,));
                                  }
                                });

                                return StatefulBuilder(
                                  builder: (BuildContext context, void Function(void Function()) setState) {
                                    print("fvghjnkm ${state.tag.isEmpty}");
                                    print("fvghjnkm ${state.isLoadingMore}");
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
                                      contentPadding: EdgeInsets.zero,
                                      title: Column(
                                        children: [
                                          CustomText(
                                            text: AppLocalizations.of(context)!.selectTags,
                                            fontWeight: FontWeight.w800,
                                            size: 20,
                                            color: Theme.of(context).colorScheme.whitepurpleChange,
                                          ),
                                          const Divider(),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 0.w),
                                            child: SizedBox(
                                              height: 35.h,
                                              width: double.infinity,
                                              child: TextField(
                                                controller: _tagSearchController,
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
                                                    borderSide: BorderSide(color: AppColors.purple),
                                                    borderRadius: BorderRadius.circular(10.0),
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    searchWord = value;
                                                  });
                                                  BlocProvider.of<TagsBloc>(context).add(SearchTags(value));
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: Container(
                                        constraints: BoxConstraints(maxHeight: 900.h),
                                        width: MediaQuery.of(context).size.width,
                                        child: state.tag.isNotEmpty? ListView.builder(
                                          controller: scrollController,
                                          shrinkWrap: true,
                                          itemCount: state.tag.length + 1,
                                          itemBuilder: (BuildContext context, int index) {
                                        if (index < state.tag.length) {
                                         final tag = state.tag[index];
                                         final isSelected = userSelectedId
                                             .contains(tag.id!);

                                         return Padding(
                                           padding: EdgeInsets.symmetric(
                                               vertical: 2.h),
                                           child: InkWell(
                                             highlightColor: Colors.transparent,
                                             splashColor: Colors.transparent,
                                             onTap: () {
                                               setState(() {
                                                 if (isSelected) {
                                                   final removeIndex = userSelectedId
                                                       .indexOf(tag.id!);
                                                   userSelectedId.removeAt(
                                                       removeIndex);
                                                   widget.tagsid.removeAt(
                                                       removeIndex);
                                                   userSelectedname.removeAt(
                                                       removeIndex);
                                                 } else {
                                                   userSelectedId.add(tag.id!);
                                                   widget.tagsid.add(tag.id!);
                                                   userSelectedname.add(
                                                       tag.title!);
                                                 }

                                                 widget.onSelected(
                                                     userSelectedname,
                                                     userSelectedId);
                                                 BlocProvider.of<TagsBloc>(
                                                     context).add(SelectedTags(
                                                     index, tag.title!));
                                                 BlocProvider.of<TagsBloc>(
                                                     context).add(
                                                     ToggleTagsSelection(
                                                         index, tag.title!));
                                               });
                                             },
                                             child: Padding(
                                               padding: EdgeInsets.symmetric(
                                                   horizontal: 20.w),
                                               child: Container(
                                                 width: double.infinity,
                                                 height: 35.h,
                                                 decoration: BoxDecoration(
                                                   color: isSelected
                                                       ? AppColors.purpleShade
                                                       : Colors.transparent,
                                                   borderRadius: BorderRadius
                                                       .circular(10),
                                                   border: Border.all(
                                                     color: isSelected
                                                         ? AppColors.purple
                                                         : Colors.transparent,
                                                   ),
                                                 ),
                                                 child: Center(
                                                   child: Padding(
                                                     padding: EdgeInsets
                                                         .symmetric(
                                                         horizontal: 18.w),
                                                     child: Row(
                                                       mainAxisAlignment: MainAxisAlignment
                                                           .spaceBetween,
                                                       children: [
                                                         Expanded(
                                                           flex: 6,
                                                           child: CustomText(
                                                             text: tag.title!,
                                                             fontWeight: FontWeight
                                                                 .w500,
                                                             size: 18.sp,
                                                             color: isSelected
                                                                 ? AppColors
                                                                 .purple
                                                                 : Theme
                                                                 .of(context)
                                                                 .colorScheme
                                                                 .textClrChange,
                                                             maxLines: 1,
                                                             overflow: TextOverflow
                                                                 .ellipsis,
                                                           ),
                                                         ),
                                                         isSelected
                                                             ? const HeroIcon(
                                                             HeroIcons
                                                                 .checkCircle,
                                                             style: HeroIconStyle
                                                                 .solid,
                                                             color: AppColors
                                                                 .purple)
                                                             : const SizedBox
                                                             .shrink(),
                                                       ],
                                                     ),
                                                   ),
                                                 ),
                                               ),
                                             ),
                                           ),
                                         );
                                       }   else {
                                         return state.isLoadingMore
                                             ? Padding(
                                           padding: EdgeInsets.symmetric(vertical: 8.h),
                                           child: const Center(child: CircularProgressIndicator()),
                                         )
                                             : const SizedBox.shrink();
                                       }
                                          },
                                        ): NoData(
                                          isImage: true,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(top: 20.h),
                                          child: CreateCancelButtom(
                                            title: "OK",
                                            onpressCancel: () {
                                              _tagSearchController.clear();
                                              Navigator.pop(context);
                                            },
                                            onpressCreate: () {
                                              _tagSearchController.clear();
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                              return const Center(child: CircularProgressIndicator());
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
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomText(
                                overflow: TextOverflow.ellipsis,
                                text: widget.isCreate
                                    ? (userSelectedname.isNotEmpty
                                    ? userSelectedname.join(", ")
                                    : AppLocalizations.of(context)!.selectTags)
                                    : (widget.usersname.isNotEmpty
                                    ? widget.usersname.join(", ")
                                    : AppLocalizations.of(context)!.selectTags),
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                color: Theme.of(context).colorScheme.textClrChange,
                                maxLines: 1,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    )

                  ],
                ),
              );
            }
            else if (state is TagsLoading) {
            }
            else if (state is TagsSuccess) {

              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => BlocBuilder<TagsBloc, TagsState>(
                            builder: (context, state) {
                              if (state is TagsSuccess) {
                                ScrollController scrollController = ScrollController();
                                scrollController.addListener(() {
                                  if (scrollController.position.atEdge) {
                                    if (scrollController.position.pixels != 0) {
                                      // BlocProvider.of<TagsBloc>(context).add(TagsLoadMore(searchWord));
                                    }
                                  }
                                });

                                return StatefulBuilder(
                                    builder: (BuildContext context, void Function(void Function()) setState) {

                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.r),  // Set the desired radius here
                                        ),
                                        backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,

                                        contentPadding: EdgeInsets.zero,
                                        title: Center(
                                          child: Column(
                                            children: [
                                              CustomText(
                                                text: AppLocalizations.of(context)!.selectTags,
                                                fontWeight: FontWeight.w800,
                                                size: 20,
                                                color: Theme.of(context).colorScheme.whitepurpleChange,
                                              ),
                                              const Divider(),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 0.w),
                                                child: SizedBox(
                                                  // color: Colors.red,
                                                  height: 35.h,
                                                  width: double.infinity,
                                                  child: TextField(
                                                    cursorColor:
                                                    AppColors.greyForgetColor,
                                                    cursorWidth: 1,
                                                    controller:
                                                    _tagSearchController,
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                      EdgeInsets.symmetric(
                                                        vertical:
                                                        (35.h - 20.sp) / 2,
                                                        horizontal: 10.w,
                                                      ),
                                                      hintText: AppLocalizations.of(context)!.search,
                                                      enabledBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: AppColors
                                                              .greyForgetColor, // Set your desired color here
                                                          width:
                                                          1.0, // Set the border width if needed
                                                        ),
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            10.0), // Optional: adjust the border radius
                                                      ),
                                                      focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                        borderSide: BorderSide(
                                                          color: AppColors
                                                              .purple, // Border color when TextField is focused
                                                          width: 1.0,
                                                        ),
                                                      ),
                                                    ),
                                                    onChanged: (value) {
                                                      setState((){
                                                        searchWord=value;
                                                      });

                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        content: Container(
                                          constraints: BoxConstraints(maxHeight: 900.h),
                                          width:MediaQuery.of(context).size.width,
                                          child:state.tag.isNotEmpty ? ListView.builder(
                                            controller: scrollController,
                                            shrinkWrap: true,
                                            itemCount: state.tag.length + 1,
                                            itemBuilder: (BuildContext context, int index) {
                                              if (index == state.tag.length) {
                                                return state.isLoadingMore
                                                    ? Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                                  child: const Center(child: CircularProgressIndicator()),
                                                )
                                                    : const SizedBox.shrink();
                                              }

                                              final isSelected = userSelectedId.contains(state.tag[index].id!);

                                              return Padding(
                                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                                child: InkWell(
                                                  highlightColor: Colors.transparent, // No highlight on tap
                                                  splashColor: Colors.transparent,
                                                  onTap: () {
                                                    setState(() {
                                                      final isSelected = userSelectedId.contains(state.tag[index].id!);

                                                      if (isSelected) {
                                                        // Remove the selected ID and corresponding username
                                                        final removeIndex = userSelectedId.indexOf(state.tag[index].id!);
                                                        userSelectedId.removeAt(removeIndex);
                                                        widget.tagsid.removeAt(removeIndex); // Sync with widget.usersid
                                                        userSelectedname.removeAt(removeIndex); // Remove corresponding username

                                                      } else {
                                                        // Add the selected ID and corresponding username
                                                        userSelectedId.add(state.tag[index].id!);
                                                        widget.tagsid.add(state.tag[index].id!); // Sync with widget.usersid
                                                        userSelectedname.add(state.tag[index].title!); // Add corresponding username

                                                      }

                                                      // Trigger any necessary UI or Bloc updates
                                                      widget.onSelected(userSelectedname, userSelectedId);
                                                      BlocProvider.of<TagsBloc>(context).add(SelectedTags(index, state.tag[index].title!));
                                                      BlocProvider.of<TagsBloc>(context).add(ToggleTagsSelection(index, state.tag[index].title!));
                                                    });
                                                  },
                                                  child:Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: 35.h,
                                                      decoration: BoxDecoration(
                                                          color: isSelected
                                                              ? AppColors
                                                              .purpleShade
                                                              : Colors
                                                              .transparent,
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              10),
                                                          border: Border.all(
                                                              color: isSelected
                                                                  ? AppColors
                                                                  .purple
                                                                  : Colors
                                                                  .transparent)),
                                                      child: Center(
                                                        child: Padding(
                                                          padding:  EdgeInsets.symmetric(horizontal:18.w),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                flex:11,
                                                                child: CustomText(
                                                                  text: state.tag[index]
                                                                      .title!,

                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                                  size: 18.sp,
                                                                  color: isSelected
                                                                      ? AppColors
                                                                      .purple
                                                                      : Theme.of(
                                                                      context)
                                                                      .colorScheme
                                                                      .textClrChange,
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                              isSelected ?  Expanded(
                                                                flex:1,
                                                                child: const HeroIcon(
                                                                    HeroIcons
                                                                        .checkCircle,
                                                                    style: HeroIconStyle
                                                                        .solid,
                                                                    color: AppColors
                                                                        .purple),
                                                              ):const SizedBox.shrink(),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ):NoData(),
                                        ),
                                        actions: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(top: 20.h),
                                            child: CreateCancelButtom(
                                              title: "OK",
                                              onpressCancel: () {
                                                _tagSearchController.clear();
                                                Navigator.pop(context);
                                              },
                                              onpressCreate: () {
                                                _tagSearchController.clear();
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    });
                              }
                              return const Center(child: CircularProgressIndicator());
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
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomText(
                                overflow: TextOverflow.ellipsis,
                                text:widget.isCreate
                                    ? (userSelectedname.isNotEmpty
                                    ? userSelectedname.join(", ")
                                    : AppLocalizations.of(context)!.selectTags)
                                    : (widget.usersname.isNotEmpty
                                    ? widget.usersname.join(", ")
                                    : AppLocalizations.of(context)!.selectTags),
                                // text: userSelectedname.isNotEmpty
                                //     ? userSelectedname.join(", ")
                                //     : getTranslated(context, "selectTags"),
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                color: Theme.of(context).colorScheme.textClrChange,


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
              );
            }
            else if (state is TagsError) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: () {
                        flutterToastCustom(msg: state.errorMessage);

                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 40.h,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greyColor),
                          color: Theme.of(context).colorScheme.containerDark,
                          boxShadow: [
                            isLightTheme
                                ? MyThemes.lightThemeShadow
                                : MyThemes.darkThemeShadow,
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomText(
                                text:widget.isCreate
                                    ? (userSelectedname.isNotEmpty
                                    ? userSelectedname.join(", ")
                                    : AppLocalizations.of(context)!.selectTags )
                                    : (widget.usersname.isNotEmpty
                                    ? widget.usersname.join(", ")
                                    : AppLocalizations.of(context)!.selectTags),
                                // text: userSelectedname.isNotEmpty
                                //     ? userSelectedname.join(", ")
                                //     : getTranslated(context, "selectTags"),
                                fontWeight: FontWeight.w400,
                                size: 12,
                                color: AppColors.greyForgetColor,
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
              );
            }
            return Container();
          },
        ),
      ],
    );
  }
}

