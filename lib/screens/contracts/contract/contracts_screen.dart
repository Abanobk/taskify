import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/contract/contract_model.dart';
import 'package:taskify/screens/contracts/contract_detail_page.dart';
import '../../../routes/routes.dart';
import '../../../src/generated/i18n/app_localizations.dart';

import 'package:taskify/utils/widgets/back_arrow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/contracts/contracts_bloc.dart';
import '../../../bloc/contracts/contracts_event.dart';
import '../../../bloc/contracts/contracts_state.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/user/user_bloc.dart';
import '../../../bloc/user/user_event.dart';
import '../../../config/constants.dart';

import '../../../utils/widgets/custom_dimissible.dart';
import '../../../utils/widgets/custom_text.dart';

import '../../../config/internet_connectivity.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../../utils/widgets/search_pop_up.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';
import '../../widgets/no_data.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import '../../widgets/search_field.dart';
import '../../widgets/side_bar.dart';
import '../../widgets/speech_to_text.dart';

class ContractScreen extends StatefulWidget {
  const ContractScreen({super.key});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  TextEditingController searchController = TextEditingController();

  String searchword = "";

  bool dialogShown = false;

  bool? isLoading = true;
  bool isLoadingMore = false;
  String? formattedFrom;
  bool shouldDisableEdit = true;

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late SpeechToTextHelper speechHelper;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  String? formattedTo;
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    BlocProvider.of<ContractBloc>(context).add(SearchContract(""));
    searchController.clear();
    // await ContractRepo().ContractList(token: true, );
    setState(() {
      isLoading = false;
    });
  }

  void _onDeleteInterview(id) {
    context.read<ContractBloc>().add(DeleteContract(id));
    final setting = context.read<ContractBloc>();
    setting.stream.listen((state) {
      if (state is ContractDeleteSuccess) {
        if (mounted) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      } else if (state is ContractError) {
        flutterToastCustom(
          msg: state.errorMessage,
        );
      }
      BlocProvider.of<ContractBloc>(context).add(ContractList());
    });
  }

  @override
  void initState() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });
    searchController.addListener(() {
      setState(() {});
    });
    context.read<ContractBloc>().add(SearchContract(searchword));
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<ContractBloc>().add(SearchContract(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  void onDeleteContract(leaveReq) {
    context.read<ContractBloc>().add(DeleteContract(leaveReq));
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;

    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()

        : SideBar(
        context: context,
        controller: sideBarController,
        underWidget:Scaffold(
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            body: SizedBox(
              // height: 400,
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: BackArrow(
                      iscreatePermission: true,
                      fromNoti: "Contract",
                      title: AppLocalizations.of(context)!.managecontract,
                      isAdd: true,
                      onPress: () {
                        searchword = "";
                        searchController.clear();
                        router.push(
                          '/createeditcontract',
                          extra: {
                            'isCreate': true,
                            'contractModel': ContractModel.empty()
                          },
                        );
                        BlocProvider.of<UserBloc>(context).add(UserList());
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  CustomSearchField(
                    isLightTheme: isLightTheme,
                    controller: searchController,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (searchController.text.isNotEmpty)
                          SizedBox(
                            width: 20.w,
                            // color: AppColors.red,
                            child: IconButton(
                              highlightColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.clear,
                                size: 20.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .textFieldColor,
                              ),
                              onPressed: () {
                                // Clear the search field
                                setState(() {
                                  searchController.clear();
                                });
                                // Optionally trigger the search event with an empty string
                                context
                                    .read<ContractBloc>()
                                    .add(SearchContract(""));
                              },
                            ),
                          ),
                        IconButton(
                          icon: Icon(
                            !speechHelper.isListening
                                ? Icons.mic_off
                                : Icons.mic,
                            size: 20.sp,
                            color:
                            Theme.of(context).colorScheme.textFieldColor,
                          ),
                          onPressed: () {
                            if (speechHelper.isListening) {
                              speechHelper.stopListening();
                            } else {
                              speechHelper.startListening(
                                  context, searchController, SearchPopUp());
                            }
                          },
                        ),
                      ],
                    ),
                    onChanged: (value) {
                      searchword = value;
                      context.read<ContractBloc>().add(SearchContract(value));
                    },
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Expanded(
                    child: RefreshIndicator(
                        color: AppColors.primary, // Spinner color
                        backgroundColor:
                        Theme.of(context).colorScheme.backGroundColor,
                        onRefresh: _onRefresh,
                        child: ContractLists(isLightTheme)),
                  ),
                  // LeaveReqList(isLightTheme)
                ],
              ),
            )));

         // Scaffold(
         //    backgroundColor: Theme.of(context).colorScheme.backGroundColor,
         //    body: SideBar(
         //      context: context,
         //      controller: sideBarController,
         //      underWidget: SizedBox(
         //        // height: 400,
         //        width: double.infinity,
         //        child: Column(
         //          children: [
         //            Padding(
         //              padding: EdgeInsets.symmetric(horizontal: 18.w),
         //              child: BackArrow(
         //                iscreatePermission: true,
         //                fromNoti: "Contract",
         //                title: AppLocalizations.of(context)!.managecontract,
         //                isAdd: true,
         //                onPress: () {
         //                  searchword = "";
         //                  searchController.clear();
         //                  router.push(
         //                    '/createeditcontract',
         //                    extra: {
         //                      'isCreate': true,
         //                      'contractModel': ContractModel.empty()
         //                    },
         //                  );
         //                  BlocProvider.of<UserBloc>(context).add(UserList());
         //                },
         //              ),
         //            ),
         //            SizedBox(
         //              height: 20.h,
         //            ),
         //            CustomSearchField(
         //              isLightTheme: isLightTheme,
         //              controller: searchController,
         //              suffixIcon: Row(
         //                mainAxisSize: MainAxisSize.min,
         //                children: [
         //                  if (searchController.text.isNotEmpty)
         //                    SizedBox(
         //                      width: 20.w,
         //                      // color: AppColors.red,
         //                      child: IconButton(
         //                        highlightColor: Colors.transparent,
         //                        padding: EdgeInsets.zero,
         //                        icon: Icon(
         //                          Icons.clear,
         //                          size: 20.sp,
         //                          color: Theme.of(context)
         //                              .colorScheme
         //                              .textFieldColor,
         //                        ),
         //                        onPressed: () {
         //                          // Clear the search field
         //                          setState(() {
         //                            searchController.clear();
         //                          });
         //                          // Optionally trigger the search event with an empty string
         //                          context
         //                              .read<ContractBloc>()
         //                              .add(SearchContract(""));
         //                        },
         //                      ),
         //                    ),
         //                  IconButton(
         //                    icon: Icon(
         //                      !speechHelper.isListening
         //                          ? Icons.mic_off
         //                          : Icons.mic,
         //                      size: 20.sp,
         //                      color:
         //                          Theme.of(context).colorScheme.textFieldColor,
         //                    ),
         //                    onPressed: () {
         //                      if (speechHelper.isListening) {
         //                        speechHelper.stopListening();
         //                      } else {
         //                        speechHelper.startListening(
         //                            context, searchController, SearchPopUp());
         //                      }
         //                    },
         //                  ),
         //                ],
         //              ),
         //              onChanged: (value) {
         //                searchword = value;
         //                context.read<ContractBloc>().add(SearchContract(value));
         //              },
         //            ),
         //            SizedBox(
         //              height: 20.h,
         //            ),
         //            Expanded(
         //              child: RefreshIndicator(
         //                  color: AppColors.primary, // Spinner color
         //                  backgroundColor:
         //                      Theme.of(context).colorScheme.backGroundColor,
         //                  onRefresh: _onRefresh,
         //                  child: ContractLists(isLightTheme)),
         //            ),
         //            // LeaveReqList(isLightTheme)
         //          ],
         //        ),
         //      ),
         //    ));

  }

  Widget ContractLists(bool isLightTheme) {
    return BlocConsumer<ContractBloc, ContractState>(
      listener: (context, state) {
        if (state is ContractPaginated) {}
      },
      buildWhen: (previous, current) {
        return previous != current;
      },
      builder: (context, state) {
        print("SATTE OF CONTRACT SCREEN $state");
        if (state is ContractLoading) {
          return NotesShimmer();
        } else if (state is ContractPaginated) {
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              // Check if we're at the bottom and not already loading
              if (!state.hasReachedMax &&
                  state.hasReachedMax &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                context.read<ContractBloc>().add(LoadMoreContract(searchword));
                return true;
              }
              return false;
            },
            child: state.Contract.isEmpty
                ? NoData(isImage: true)
                : Stack(
                    children: [
                      state.Contract.isEmpty?NoData(isImage: true,): ListView.builder(
                        padding: EdgeInsets.only(bottom: 30.h),
                        shrinkWrap: true,
                        itemCount: state.hasReachedMax
                            ? state.Contract.length
                            : state.Contract.length + 1,
                        itemBuilder: (context, index) {
                          if (index < state.Contract.length) {
                            final contract = state.Contract[index];
                            final from = datechange(contract.startDate!);
                            final to = datechange(contract.endDate!);
                            print("fghjkl ${contract.title}");
                            return _leaveReqCard(isLightTheme, contract,
                                state.Contract, index, from, to);
                          } else {
                            return SizedBox();
                          }
                        },
                      ),
                    ],
                  ),
          );
        } else if (state is ContractError) {
          flutterToastCustom(msg: state.errorMessage);
        } else if (state is ContractDeleteError) {
          flutterToastCustom(msg: state.errorMessage);
        } else if (state is ContractDeleteSuccess) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
          BlocProvider.of<ContractBloc>(context)
              .add(ContractList());
          Navigator.pop(context);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _leaveReqCard(isLightTheme, contract, contractState, index, from, to) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
        child: DismissibleCard(
          title: contract.id!.toString(),
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart) {
              // Right to left swipe (Delete action)
              print("Showing delete dialog for contract: ${contract.id}");

              try {
                final result = await showDialog<bool>(
                  context: context,
                  barrierDismissible:
                  false, // Prevent dismissing by tapping outside
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      backgroundColor:
                      Theme.of(context).colorScheme.alertBoxBackGroundColor,
                      title: Text(
                        AppLocalizations.of(context)!.confirmDelete,
                      ),
                      content: Text(
                        AppLocalizations.of(context)!.areyousure,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            print(
                                "User confirmed deletion - about to pop with true");
                            Navigator.of(context).pop(true); // Confirm deletion
                          },
                          child: Text(
                            AppLocalizations.of(context)!.ok,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            print(
                                "User cancelled deletion - about to pop with false");
                            Navigator.of(context).pop(false); // Cancel deletion
                          },
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                          ),
                        ),
                      ],
                    );
                  },
                );

                print("Dialog result received: $result");
                print("About to return from confirmDismiss: ${result ?? false}");

                // If user confirmed deletion, handle it here instead of in onDismissed
                if (result == true) {
                  print("Handling deletion directly in confirmDismiss");
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      contractState.removeAt(index);
                    });
                    _onDeleteInterview(contract.id);
                  });
                  // Return false to prevent the dismissible from animating
                  return false;
                }

                return false; // Always return false since we handle deletion manually
              } catch (e) {
                print("Error in dialog: $e");
                return false;
              }
            }  else if (direction == DismissDirection.startToEnd) {
              searchword = "";
              searchController.clear();
              router.push(
                '/createeditcontract',
                extra: {'isCreate': false, 'contractModel': contract},
              );

              return false; // Prevent dismiss
            }
            return false;
          },
          dismissWidget: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  boxShadow: [
                    isLightTheme
                        ? MyThemes.lightThemeShadow
                        : MyThemes.darkThemeShadow,
                  ],
                  // border: Border.all(
                  //     color:
                  //     AppColors.colorDark[index % AppColors.colorDark.length],
                  //     width: 0.5),
                  color: isLightTheme
                      ? AppColors
                          .colorLight[index % AppColors.colorLight.length]
                      : AppColors.darkContainer,
                  borderRadius: BorderRadius.circular(12)),
              // height: 140.h,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 10.h,
                  horizontal: 20.h,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) =>
                                ContractDetails(model: contract),
                          ));
                        },
                        child: CustomText(
                          text: "# CTR-${contract.id.toString()}",
                          size: 16.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      CustomText(
                        text: contract.title!,
                        size: 18.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                NetworkImage(contract.client.profilePicture),
                          ),
                          SizedBox(
                            width: 10.h,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                // width: 59.w,
                                // color: Colors.red,
                                child: CustomText(
                                  text: contract.client.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  size: 16.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                // width: 59.w,
                                // color: Colors.red,
                                child: CustomText(
                                  text: contract.client.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  size: 14.sp,
                                  color: AppColors.greyColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      SizedBox(
                        // width: 59.w,
                        // color: Colors.red,
                        child: CustomText(
                          text: contract.project.title ?? "",
                          size: 14.sp,
                          softwrap: true,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      SizedBox(
                        // width: 59.w,
                        // color: Colors.red,
                        child: CustomText(
                          text: contract.contractType.name ?? "",
                          size: 14.sp,
                          softwrap: true,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      SizedBox(
                        // width: 59.w,
                        // color: Colors.red,
                        child: CustomText(
                          text: contract.value ?? "",
                          size: 14.sp,
                          softwrap: true,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: double.infinity),
                        child: IntrinsicWidth(
                          child: Container(
                            alignment: Alignment.center,
                            height: 25.h,
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blue.shade800,
                            ),
                            child: CustomText(
                              text: contract.status.replaceAll('_', ' '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              color: AppColors.whiteColor,
                              size: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                NetworkImage(contract.createdBy.profilePicture),
                          ),
                          SizedBox(
                            width: 10.h,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                // width: 59.w,
                                // color: Colors.red,
                                child: CustomText(
                                  text: contract.createdBy.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  size: 16.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                // width: 59.w,
                                // color: Colors.red,
                                child: CustomText(
                                  text: contract.createdBy.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  size: 14.sp,
                                  color: AppColors.greyColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ]),
              )),
          onDismissed: (DismissDirection direction) {
            // This will not be called if `confirmDismiss` returned `false`
            if (direction == DismissDirection.endToStart) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  contractState.removeAt(index);
                });
                _onDeleteInterview(contract.id);
              });
            }
          },
        ));
  }
}
