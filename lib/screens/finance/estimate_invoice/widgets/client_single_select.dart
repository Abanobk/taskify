import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/bloc/clients/client_bloc.dart';
import 'package:taskify/bloc/clients/client_event.dart';
import 'package:taskify/bloc/clients/client_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import '../../../../bloc/theme/theme_bloc.dart';
import '../../../../bloc/theme/theme_state.dart';
import '../../../../data/model/client/client_model.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../../utils/widgets/custom_text.dart';
import '../../../../utils/widgets/my_theme.dart';
import '../../../widgets/custom_cancel_create_button.dart';

class SingleClientField extends StatefulWidget {
  final bool isCreate;
  final bool isRequired;
  final String? username; // Changed from List to single String
  final int? clientId; // Changed from List to single int
  final List<ClientModel> project;
  final Function(String?, int?) onSelected; // Modified callback function

  const SingleClientField({
    super.key,
    this.isRequired = false,
    required this.isCreate,
    this.username, // Optional now
    required this.project,
    this.clientId, // Optional now
    required this.onSelected,
  });

  @override
  State<SingleClientField> createState() => _SingleClientFieldState();
}

class _SingleClientFieldState extends State<SingleClientField> {
  String? selectedClientName;
  int? selectedClientId;
  String searchWord = "";

  final TextEditingController _clientSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with provided client if any
    if (widget.isCreate == false) {
      selectedClientId = widget.clientId;
      selectedClientName = widget.username;
    }
    BlocProvider.of<ClientBloc>(context).add(ClientList());
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
                text: AppLocalizations.of(context)!.client,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
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
        BlocBuilder<ClientBloc, ClientState>(
          builder: (context, state) {
            if (state is ClientInitial) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {},
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
                                text: widget.isCreate
                                    ? (selectedClientName ??
                                        AppLocalizations.of(context)!
                                            .selectclient)
                                    : (widget.username ??
                                        AppLocalizations.of(context)!
                                            .selectclient),
                                fontWeight: FontWeight.w400,
                                size: 12,
                                color: AppColors.greyForgetColor,
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
            } else if (state is ClientPaginated || state is ClientError) {
              // Handler for both successful load and error states
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) =>
                              BlocBuilder<ClientBloc, ClientState>(
                            builder: (context, state) {
                              if (state is ClientPaginated) {
                                ScrollController scrollController =
                                    ScrollController();
                                scrollController.addListener(() {
                                  if (scrollController.position.atEdge) {
                                    if (scrollController.position.pixels != 0) {
                                      BlocProvider.of<ClientBloc>(context)
                                          .add(ClientLoadMore(searchWord));
                                    }
                                  }
                                });

                                return StatefulBuilder(
                                  builder: (BuildContext context,
                                      void Function(void Function()) setState) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .alertBoxBackGroundColor,
                                      contentPadding: EdgeInsets.zero,
                                      title: Center(
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          child: Column(
                                            children: [
                                              CustomText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .selectclient,
                                                fontWeight: FontWeight.w800,
                                                size: 20,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .whitepurpleChange,
                                              ),
                                              const Divider(),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 0.w),
                                                child: SizedBox(
                                                  height: 35.h,
                                                  width: double.infinity,
                                                  child: TextField(
                                                    cursorColor: AppColors
                                                        .greyForgetColor,
                                                    cursorWidth: 1,
                                                    controller:
                                                        _clientSearchController,
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                        vertical:
                                                            (35.h - 20.sp) / 2,
                                                        horizontal: 10.w,
                                                      ),
                                                      hintText:
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .search,
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: AppColors
                                                              .greyForgetColor,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        borderSide: BorderSide(
                                                          color:
                                                              AppColors.purple,
                                                          width: 1.0,
                                                        ),
                                                      ),
                                                    ),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        searchWord = value;
                                                      });
                                                      context
                                                          .read<ClientBloc>()
                                                          .add(SearchClients(
                                                              value));
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
                                        constraints:
                                            BoxConstraints(maxHeight: 900.h),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child:state.client.isEmpty?NoData(isImage: true,): ListView.builder(
                                          controller: scrollController,
                                          shrinkWrap: true,
                                          itemCount: state.client.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            final isSelected =
                                                selectedClientId ==
                                                    state.client[index].id;

                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20.h),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                onTap: () {
                                                  setState(() {
                                                    // Single selection logic
                                                    selectedClientId =
                                                        state.client[index].id;
                                                    selectedClientName = state
                                                        .client[index]
                                                        .firstName;

                                                    // Update parent through callback
                                                    widget.onSelected(
                                                        selectedClientName,
                                                        selectedClientId);
                                                  });
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 2.h),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? AppColors
                                                              .purpleShade
                                                          : Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                          color: isSelected
                                                              ? AppColors.purple
                                                              : Colors
                                                                  .transparent),
                                                    ),
                                                    width: double.infinity,
                                                    child: Center(
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.w),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              flex: 4,
                                                              child: SizedBox(
                                                                width: 200.w,
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      flex: 7,
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            200.w,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            CircleAvatar(
                                                                              radius: 20,
                                                                              backgroundImage: NetworkImage(state.client[index].profile!),
                                                                            ),
                                                                            Expanded(
                                                                              child: Padding(
                                                                                padding: EdgeInsets.symmetric(horizontal: 18.w),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        Flexible(
                                                                                          child: CustomText(
                                                                                            text: state.client[index].firstName!,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            size: 18.sp,
                                                                                            color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(width: 5.w),
                                                                                        Flexible(
                                                                                          child: CustomText(
                                                                                            text: state.client[index].lastName!,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            size: 18.sp,
                                                                                            color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    Row(
                                                                                      children: [
                                                                                        Flexible(
                                                                                          child: CustomText(
                                                                                            text: state.client[index].email!,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            size: 18.sp,
                                                                                            color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
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
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            isSelected
                                                                ? Expanded(
                                                                    flex: 1,
                                                                    child: const HeroIcon(
                                                                        HeroIcons
                                                                            .checkCircle,
                                                                        style: HeroIconStyle
                                                                            .solid,
                                                                        color: AppColors
                                                                            .purple),
                                                                  )
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
                                          },
                                        ),
                                      ),
                                      actions: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(top: 20.h),
                                          child: CreateCancelButtom(
                                            title: "OK",
                                            onpressCancel: () {
                                              Navigator.pop(context);
                                            },
                                            onpressCreate: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                              return Container();
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
                              child: SizedBox(
                                child: CustomText(
                                  text: widget.isCreate
                                      ? (selectedClientName ??
                                          AppLocalizations.of(context)!
                                              .selectclient)
                                      : (widget.username ??
                                          AppLocalizations.of(context)!
                                              .selectclient),
                                  fontWeight: FontWeight.w500,
                                  size: 14.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
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
            return AbsorbPointer(
              absorbing: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5.h),
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {},
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
                            child: SizedBox(
                              child: CustomText(
                                text:
                                    AppLocalizations.of(context)!.selectclient,
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
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
          },
        ),
      ],
    );
  }
}
