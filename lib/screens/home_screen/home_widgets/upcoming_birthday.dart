
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';

import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import '../../../bloc/birthday/birthday_bloc.dart';
import '../../../bloc/birthday/birthday_event.dart';
import '../../../bloc/birthday/birthday_state.dart';
import '../../../bloc/clients/client_bloc.dart';
import '../../../bloc/clients/client_event.dart';
import '../../../bloc/clients/client_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/user/user_bloc.dart';
import '../../../bloc/user/user_event.dart';
import '../../../bloc/user/user_state.dart';
import '../../../config/constants.dart';
import '../../../data/model/Birthday/birthday_model.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';
import '../../widgets/custom_cancel_create_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/number_picker.dart';

class UpcomingBirthday extends StatefulWidget {
  const UpcomingBirthday({super.key});

  @override
  State<UpcomingBirthday> createState() => _UpcomingBirthdayState();
}

class _UpcomingBirthdayState extends State<UpcomingBirthday> {
  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _clientSearchController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final ValueNotifier<int> _currentValue = ValueNotifier<int>(7);

  @override
  void initState() {
    super.initState();
    dayController.text = _currentValue.value.toString();
    dayController.addListener(() {
      int? newValue = int.tryParse(dayController.text);
      if (newValue != null && newValue >= 1 && newValue <= 366) {
        _currentValue.value = newValue;
      }
    });
    context.read<BirthdayBloc>().add( WeekBirthdayList(7, [], [],[],[]));
    context.read<UserBloc>().add( UserList());
    context.read<ClientBloc>().add( ClientList());
  }

  @override
  void dispose() {
    _userSearchController.dispose();
    _clientSearchController.dispose();
    dayController.dispose();
    _currentValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    bool isLightTheme = currentTheme is LightThemeState;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            titleTask(context, AppLocalizations.of(context)!.upcomingBirthday),
          ],
        ),
        _birthdayFilter(dayController),
        _birthdayBloc(isLightTheme),
      ],
    );
  }

  Widget _birthdayFilter(TextEditingController dayController) {
    return Padding(
      padding: EdgeInsets.only(left: 18.w, right: 18.w, top: 20.h),
      child: SizedBox(
        height: 50.h,
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(
            child: Row(
              children: [
                _selectMembers(),
                SizedBox(width: 10.w),
                _selectClient(),
                SizedBox(width: 10.w),
                _selectDays(dayController),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectMembers() {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return const SpinKitFadingCircle(
                    color: AppColors.primary,
                    size: 40.0,
                  );
                }

                if (state is UserSuccess || state is UserPaginated) {
                  final users = state is UserSuccess
                      ? state.user
                      : (state as UserPaginated).user;
                  final hasReachedMax =
                  state is UserPaginated ? state.hasReachedMax : false;

                  ScrollController scrollController = ScrollController();
                  scrollController.addListener(() {
                    if (scrollController.position.atEdge &&
                        scrollController.position.pixels != 0) {
                      context
                          .read<UserBloc>()
                          .add(UserLoadMore(_userSearchController.text));
                    }
                  });

                  return BlocBuilder<BirthdayBloc, BirthdayState>(
                    builder: (context, birthdayState) {
                      List<String> userSelectedname = [];
                      List<String> clientSelectedname = [];
                      List<int> userSelectedId = [];
                      List<int> clientSelectedId = [];

                      if (birthdayState is TodayBirthdaySuccess) {
                        userSelectedname = birthdayState.userSelectedname;
                        userSelectedId = birthdayState.userSelectedId;
                        clientSelectedId = birthdayState.clientSelectedId;
                        clientSelectedname = birthdayState.clientSelectedname;
                        if (kDebugMode) {
                          print('SelectMembers Dialog: userSelectedname=$userSelectedname');
                        }
                      }

                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                        backgroundColor:
                        Theme.of(context).colorScheme.alertBoxBackGroundColor,
                        contentPadding: EdgeInsets.zero,
                        title: Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Column(
                              children: [
                                CustomText(
                                  text: AppLocalizations.of(context)!.selectuser,
                                  fontWeight: FontWeight.w800,
                                  size: 20,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .whitepurpleChange,
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
                                        hintText:
                                        AppLocalizations.of(context)!.search,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: AppColors.greyForgetColor,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: AppColors.purple,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        context
                                            .read<UserBloc>()
                                            .add(SearchUsers(value));
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
                          child: ListView.builder(
                            controller: scrollController,
                            shrinkWrap: true,
                            itemCount:
                            hasReachedMax ? users.length : users.length + 1,
                            itemBuilder: (context, index) {
                              if (index < users.length) {
                                final isSelected =
                                userSelectedId.contains(users[index].id!);
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.h),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      final updatedUserSelectedId =
                                      List<int>.from(userSelectedId);
                                      final updatedUserSelectedname =
                                      List<String>.from(userSelectedname);
                                      if (isSelected) {
                                        updatedUserSelectedId
                                            .remove(users[index].id!);
                                        updatedUserSelectedname
                                            .remove(users[index].firstName!);
                                      } else {
                                        updatedUserSelectedId.add(users[index].id!);
                                        updatedUserSelectedname
                                            .add(users[index].firstName!);
                                      }
                                      context.read<BirthdayBloc>().add(
                                        UpdateSelectedUsers(
                                          List<String>.from(
                                              updatedUserSelectedname),
                                          List<int>.from(updatedUserSelectedId),
                                        ),
                                      );
                                      context.read<UserBloc>().add(
                                          ToggleUserSelection(
                                              index, users[index].firstName!));
                                    },
                                    child: Padding(
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 20.w),
                                      child:
                                      Center(
                                        child:
                                        Container(
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
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                              10.w,vertical: 5.h),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              CustomText(
                                                text:users[index].firstName!,
                                                fontWeight:
                                                FontWeight.w500,
                                                size:
                                                18,
                                                color: isSelected
                                                    ? AppColors.purple
                                                    : Theme.of(context).colorScheme.textClrChange,
                                              ),
                                              isSelected
                                                  ? const HeroIcon(
                                                HeroIcons.checkCircle,
                                                style: HeroIconStyle.solid,
                                                color: AppColors.purple,
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
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                                  child: Center(
                                    child: hasReachedMax
                                        ? const SizedBox.shrink()
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
                        actions: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: CreateCancelButtom(
                              title: AppLocalizations.of(context)!.ok,
                              onpressCancel: () {
                                _userSearchController.clear();
                                context
                                    .read<BirthdayBloc>()
                                    .add(UpdateSelectedUsers([], []));
                                context.read<BirthdayBloc>().add(
                                  WeekBirthdayList(
                                    _currentValue.value,
                                    [],
                                    clientSelectedId,
                                    clientSelectedname,
                                    [],
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              onpressCreate: () {
                                _userSearchController.clear();
                                context.read<BirthdayBloc>().add(
                                  WeekBirthdayList(
                                    _currentValue.value,
                                    userSelectedId,
                                    clientSelectedId,
                                    clientSelectedname,
                                    userSelectedname,
                                  ),
                                );
                                Future.delayed(Duration(milliseconds: 100), () {
                                  Navigator.pop(context);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
        child: BlocBuilder<BirthdayBloc, BirthdayState>(
          builder: (context, state) {
            List<String> userSelectedname = [];
            if (state is TodayBirthdaySuccess) {
              userSelectedname = state.userSelectedname;
              if (kDebugMode) {
                print('SelectMembers UI: userSelectedname=$userSelectedname');
              }
            }
            return Container(
              alignment: Alignment.center,
              height: 40.h,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyColor, width: 0.5),
                color: Theme.of(context).colorScheme.containerDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CustomText(
                          text: userSelectedname.isNotEmpty
                              ? userSelectedname.join(", ")
                              : AppLocalizations.of(context)!.selectmembers,
                          color: Theme.of(context).colorScheme.textClrChange,
                          size: 14.sp,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _selectClient() {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => BlocBuilder<ClientBloc, ClientState>(
              builder: (context, state) {
                if (state is ClientLoading) {
                  return const SpinKitFadingCircle(
                    color: AppColors.primary,
                    size: 40.0,
                  );
                }
                if (state is ClientSuccess || state is ClientPaginated) {
                  final clients = state is ClientSuccess ? state.client : (state as ClientPaginated).client;
                  final hasReachedMax = state is ClientPaginated ? state.hasReachedMax : false;
                  ScrollController scrollController = ScrollController();
                  scrollController.addListener(() {
                    if (scrollController.position.atEdge && scrollController.position.pixels != 0) {
                      context.read<ClientBloc>().add(ClientLoadMore(_clientSearchController.text));
                    }
                  });

                  return BlocBuilder<BirthdayBloc, BirthdayState>(
                    builder: (context, birthdayState) {
                      List<String> clientSelectedname = [];
                      List<String> userSelectedname = [];
                      List<int> clientSelectedId = [];
                      List<int> userSelectedId = [];
                      if (birthdayState is TodayBirthdaySuccess) {
                        clientSelectedname = birthdayState.clientSelectedname;
                        userSelectedname = birthdayState.userSelectedname;
                        clientSelectedId = birthdayState.clientSelectedId;
                        userSelectedId = birthdayState.userSelectedId;
                        if (kDebugMode) {
                          print('SelectClient Dialog: clientSelectedname=$clientSelectedname');
                        }
                      }

                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
                        contentPadding: EdgeInsets.zero,
                        title: Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Column(
                              children: [
                                CustomText(
                                  text: AppLocalizations.of(context)!.selectclient,
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
                                      cursorColor: AppColors.greyForgetColor,
                                      cursorWidth: 1,
                                      controller: _clientSearchController,
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
                                        context.read<ClientBloc>().add(SearchClients(value));
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
                          child: ListView.builder(
                            controller: scrollController,
                            shrinkWrap: true,
                            itemCount: hasReachedMax ? clients.length : clients.length + 1,
                            itemBuilder: (context, index) {
                              if (index < clients.length) {
                                final isSelected = clientSelectedId.contains(clients[index].id!);
                                return InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    final updatedClientSelectedId = List<int>.from(clientSelectedId);
                                    final updatedClientSelectedname = List<String>.from(clientSelectedname);
                                    if (isSelected) {
                                      updatedClientSelectedId.remove(clients[index].id!);
                                      updatedClientSelectedname.remove(clients[index].firstName!);
                                    } else {
                                      updatedClientSelectedId.add(clients[index].id!);
                                      updatedClientSelectedname.add(clients[index].firstName!);
                                    }
                                    context.read<BirthdayBloc>().add(UpdateSelectedClients(
                                      List<String>.from(updatedClientSelectedname),
                                      List<int>.from(updatedClientSelectedId),
                                    ));
                                    context.read<ClientBloc>().add(SelectedClient(index, clients[index].firstName!));
                                    context.read<ClientBloc>().add(ToggleClientSelection(index, clients[index].firstName!));
                                  },
                                  child:
                                  Padding(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 20.w,vertical: 20.h),
                                    child:
                                    Center(
                                      child:
                                      Container(
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
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                            10.w,vertical: 5.h),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            CustomText(
                                              text: clients[index].firstName!,
                                              fontWeight:
                                              FontWeight.w500,
                                              size:
                                              18,
                                              color: isSelected
                                                  ? AppColors.purple
                                                  : Theme.of(context).colorScheme.textClrChange,
                                            ),
                                            isSelected
                                                ? const HeroIcon(
                                              HeroIcons.checkCircle,
                                              style: HeroIconStyle.solid,
                                              color: AppColors.purple,
                                            )
                                                : const SizedBox.shrink(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Center(
                                    child: hasReachedMax
                                        ? const SizedBox.shrink()
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
                        actions: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: CreateCancelButtom(
                              title: AppLocalizations.of(context)!.ok,
                              onpressCancel: () {
                                _clientSearchController.clear();
                                context.read<BirthdayBloc>().add( UpdateSelectedClients([], []));
                                context.read<BirthdayBloc>().add(WeekBirthdayList(
                                  _currentValue.value,
                                  userSelectedId,
                                  [],[],[]
                                ));
                                Navigator.pop(context);
                              },
                              onpressCreate: () {
                                _clientSearchController.clear();
                                context.read<BirthdayBloc>().add(WeekBirthdayList(
                                  _currentValue.value,
                                  userSelectedId,
                                  clientSelectedId,
                                  clientSelectedname,userSelectedname
                                ));
                                Future.delayed(Duration(milliseconds: 100), () {
                                  Navigator.pop(context);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
        child: BlocBuilder<BirthdayBloc, BirthdayState>(
          builder: (context, state) {
            List<String> clientSelectedname = [];
            if (state is TodayBirthdaySuccess) {
              clientSelectedname = state.clientSelectedname;
              if (kDebugMode) {
                print('SelectClient UI: clientSelectedname=$clientSelectedname');
              }
            }
            return Container(
              alignment: Alignment.center,
              height: 40.h,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyColor, width: 0.5),
                color: Theme.of(context).colorScheme.containerDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CustomText(
                          text: clientSelectedname.isNotEmpty
                              ? clientSelectedname.join(", ")
                              : AppLocalizations.of(context)!.selectclient,
                          color: Theme.of(context).colorScheme.textClrChange,
                          size: 14.sp,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }



  Widget _selectDays(TextEditingController dayController) {
    return Expanded(
      flex: 1,
      child: ValueListenableBuilder<int>(
        valueListenable: _currentValue,
        builder: (context, value, child) {
          return Container(
            alignment: Alignment.center,
            height: 40.h,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyColor, width: 0.5),
              color: Theme.of(context).colorScheme.containerDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: InkWell(
                  onTap: () {
                    _showNumberPickerDialog(dayController);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                        child: CustomText(
                          text: value == 7
                              ? AppLocalizations.of(context)!.sevendays
                              : "$value ${AppLocalizations.of(context)!.days}",
                          color: Theme.of(context).colorScheme.textClrChange,
                          size: 14.sp,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value == 7
                          ? const SizedBox.shrink()
                          : InkWell(
                        onTap: () {
                          _currentValue.value = 7;
                          dayController.text = "7";
                          context.read<BirthdayBloc>().add(WeekBirthdayList(
                            7,
                            (context.read<BirthdayBloc>().state as TodayBirthdaySuccess?)?.userSelectedId ?? [],
                            (context.read<BirthdayBloc>().state as TodayBirthdaySuccess?)?.clientSelectedId ?? [],
                              (context.read<BirthdayBloc>().state as TodayBirthdaySuccess?)?.clientSelectedname ?? [] ,
                              (context.read<BirthdayBloc>().state as TodayBirthdaySuccess?)?.userSelectedname ?? []
                          ));
                        },
                        child: Padding(
                          padding:  EdgeInsets.only(left: 8.w),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.greyColor,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(5.h),
                              child: HeroIcon(
                                HeroIcons.xMark,
                                style: HeroIconStyle.outline,
                                color: AppColors.pureWhiteColor,
                                size: 15.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showNumberPickerDialog(TextEditingController dayController) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    showDialog(
      context: context,
      builder: (context) => CustomNumberPickerDialog(
        dayController: dayController,
        currentValue: _currentValue,
        isLightTheme: currentTheme is LightThemeState,
        onSubmit: (value) {
          _currentValue.value = value;
          context.read<BirthdayBloc>().add(WeekBirthdayList(
            value,
            (context.read<BirthdayBloc>().state as TodayBirthdaySuccess?)?.userSelectedId ?? [],
            (context.read<BirthdayBloc>().state as TodayBirthdaySuccess?)?.clientSelectedId ?? [],
            (context.read<BirthdayBloc>().state as TodayBirthdaySuccess?)?.clientSelectedname ?? [],
            (context.read<BirthdayBloc>().state as TodayBirthdaySuccess?)?.userSelectedname ?? [],
          ));
        },
      ),
    );
  }

  Widget _birthdayList(bool hasReachedMax, List<BirthdayModel> birthdayState, bool isLightTheme) {
    return SizedBox(
      height: 230.h,
      width: double.infinity,
      child: ListView.builder(
        padding: EdgeInsets.only(right: 18.w, top: 5.h),
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: hasReachedMax ? birthdayState.length : birthdayState.length + 1,
        itemBuilder: (context, index) {
          if (index < birthdayState.length) {
            var birthday = birthdayState[index];
            String? dob = formatDateFromApi(birthday.dob!, context);
            return InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                router.push('/userdetail', extra: {"id": birthday.id});
              },
              child: Padding(
                padding: EdgeInsets.only(top: 10.h, bottom: 10.h, left: 18.w),
                child: Container(
                  width: 250.w,
                  decoration: BoxDecoration(
                    boxShadow: [
                      isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
                    ],
                    color: Theme.of(context).colorScheme.containerDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 40.r,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: NetworkImage(birthday.photo!),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "${birthday.birthdayCount!}",
                                        style: TextStyle(
                                          fontSize: 40.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.textClrChange,
                                        ),
                                      ),
                                      WidgetSpan(
                                        child: Transform.translate(
                                          offset: const Offset(0, -10),
                                          child: CustomText(
                                            text: "${getOrdinalSuffix(birthday.birthdayCount!)}",
                                            size: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.textClrChange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                CustomText(
                                  text: AppLocalizations.of(context)!.birthdattoday,
                                  size: 12.sp,
                                  color: AppColors.projDetailsSubText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: birthday.member!,
                              size: 22.sp,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.textClrChange,
                            ),
                            if (birthday.daysLeft! == 0)
                              CustomText(
                                text: AppLocalizations.of(context)!.today,
                                size: 16.sp,
                                color: AppColors.projDetailsSubText,
                                fontWeight: FontWeight.w600,
                              ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (birthday.daysLeft! != 0)
                              Text(
                                AppLocalizations.of(context)!.daysLeft,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 10.sp,
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    const HeroIcon(
                                      HeroIcons.cake,
                                      style: HeroIconStyle.outline,
                                      color: AppColors.blueColor,
                                    ),
                                    SizedBox(width: 10.w),
                                    CustomText(
                                      text: dob,
                                      color: AppColors.greyColor,
                                      size: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                                if (birthday.daysLeft! != 0)
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.textClrChange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      "${birthday.daysLeft!}",
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.lightWhite,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
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
                    ? const SizedBox.shrink()
                    : const SpinKitFadingCircle(
                  color: AppColors.primary,
                  size: 40.0,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _birthdayBloc(bool isLightTheme) {
    return BlocBuilder<BirthdayBloc, BirthdayState>(
      builder: (context, state) {
        if (state is TodaysBirthdayLoading) {
          return Container(
            height: 225.h,
            child: const HomeUpcomingShimmer(),
          );
        } else if (state is TodayBirthdaySuccess) {
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (!state.hasReachedMax &&
                  scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                context.read<BirthdayBloc>().add(LoadMoreBirthday(
                  _currentValue.value,
                  state.userSelectedId,
                  state.clientSelectedId,
                ));
              }
              return false;
            },
            child: state.birthday.isNotEmpty
                ? _birthdayList(state.hasReachedMax, state.birthday, isLightTheme)
                : Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15.h),
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
                  ],
                  color: Theme.of(context).colorScheme.containerDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const NoData(isImage: false),
              ),
            ),
          );
        } else if (state is BirthdayError) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            child: CustomText(
              text: state.message,
              size: 16.sp,
              color: AppColors.red,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

Widget titleTask(BuildContext context, String title) {
  return SizedBox(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: CustomText(
        text: title,
        color: Theme.of(context).colorScheme.textClrChange,
        size: 18,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
