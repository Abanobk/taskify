import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/permissions/permissions_event.dart';
import 'package:taskify/bloc/setting/settings_bloc.dart';
import 'package:taskify/config/colors.dart';

import 'package:taskify/utils/widgets/shake_widget.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../bloc/estimate_invoice/estimateInvoice_bloc.dart';
import '../../../bloc/estimate_invoice/estimateInvoice_event.dart';
import '../../../bloc/estimate_invoice/estimateInvoice_state.dart';

import '../../../bloc/estimate_invoice_filter/estimate_invoice_filter_bloc.dart';
import '../../../bloc/estimate_invoice_filter/estimate_invoice_filter_event.dart';
import '../../../bloc/estimate_invoice_filter/estimate_invoice_filter_state.dart';

import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/constants.dart';
import '../../../data/localStorage/hive.dart';
import '../../../data/model/finance/estimate_invoices_model.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/custom_dimissible.dart';
import '../../../utils/widgets/custom_text.dart';
import 'package:heroicons/heroicons.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../../config/internet_connectivity.dart';
import '../../../utils/widgets/circularprogress_indicator.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../../utils/widgets/search_pop_up.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';
import '../../widgets/no_data.dart';

import '../../widgets/search_field.dart';
import '../../widgets/side_bar.dart';
import '../../widgets/speech_to_text.dart';
import 'estimate_invoice_filter_bottomsheet.dart';

class EstimateInvoiceScreen extends StatefulWidget {
  final bool? fromNoti;
  const EstimateInvoiceScreen({super.key, this.fromNoti});

  @override
  State<EstimateInvoiceScreen> createState() => _EstimateInvoiceScreenState();
}

class _EstimateInvoiceScreenState extends State<EstimateInvoiceScreen> {
  TextEditingController searchController = TextEditingController();

  String searchWord = "";

  bool shouldDisableEdit = true;

  bool isListening =
      false; // Flag to track if speech recognition is in progress
  bool dialogShown = false;

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late SpeechToTextHelper speechHelper;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  bool isLoadingMore = false;
  String currency = "";
  final List<String> filter = [
    'Clients',
    'type',
    'usercreator',
    'clientcreator',
    'Date'
  ];
  final ValueNotifier<String> filterNameNotifier =
      ValueNotifier<String>('Clients'); // Initialize with default value

  String filterName = 'Clients';
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  Future<void> _launchUrl(url) async {
    var token = await HiveStorage.getToken();
    if (!await launchUrl(Uri.parse("$url?token=$token"),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
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

    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          final filterState =
              context.read<EstimateInvoiceFilterCountBloc>().state;

          context.read<EstinateInvoiceBloc>().add(SearchEstimateInvoices(
              result,
              filterState.selectedTypeIds,
              filterState.selectedUserCreatorIds,
              filterState.selectedClientCreatorIds,
              filterState.selectedClientIds,
              filterState.fromDate,
              filterState.toDate));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<EstinateInvoiceBloc>()
          .add(EstinateInvoiceLists([], [], [], [], "", ""));
      context.read<PermissionsBloc>().add(GetPermissions());
      currency = context.read<SettingsBloc>().currencySymbol!;
    });
  }

  bool? isLoading = true;
  void onDeleteEstinateInvoice(int EstinateInvoice) {
    context
        .read<EstinateInvoiceBloc>()
        .add(DeleteEstinateInvoices(EstinateInvoice));
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    context
        .read<EstinateInvoiceBloc>()
        .add(EstinateInvoiceLists([], [], [], [], "", ""));

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;

    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          router.pop();
          context
              .read<EstimateInvoiceFilterCountBloc>()
              .add(EstimateInvoiceResetFilterCount());


        }
      },
            child: Scaffold(
                backgroundColor: Theme.of(context).colorScheme.backGroundColor,
                body: SideBar(
                  context: context,
                  controller: sideBarController,
                  underWidget: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: BackArrow(
                          onTap: () {
                            router.pop();
                            context
                                .read<EstimateInvoiceFilterCountBloc>()
                                .add(EstimateInvoiceResetFilterCount());
                          },
                          iscreatePermission: context
                              .read<PermissionsBloc>()
                              .iscreateEstimateInvoice,
                          isFromNotification: widget.fromNoti,
                          fromNoti: "EstinateInvoice",
                          iSBackArrow: true,
                          title: AppLocalizations.of(context)!.estinateinvoices,
                          isAdd: context
                              .read<PermissionsBloc>()
                              .iscreateEstimateInvoice,
                          onPress: () {
                            EstimateInvoicesUnit unit = EstimateInvoicesUnit(
                                id: 0,
                                workspaceId: 0,
                                title: "",
                                description: "");
                            InvoicesItems item = InvoicesItems(
                                id: 0,
                                name: "",
                                description: "",
                                quantity: "",
                                unit: unit,
                                rate: "0");
                            InvoiceClient client = InvoiceClient(
                                id: 0,
                                email: "",
                                photo: "",
                                firstName: "",
                                lastName: "");
                            EstimateInvoicesModel model = EstimateInvoicesModel(
                                type: "",
                                note: "",
                                state: "",
                                status: "",
                                city: "",
                                client: client,
                                clientId: 0,
                                country: "",
                                createdAt: "",
                                name: "",
                                address: "",
                                fromDate: "",
                                taxAmount: " 0",
                                toDate: "",
                                personalNote: "",
                                phone: "",
                                total: "0",
                                finalTotal: "0",
                                items: [item],
                                updatedAt: "");
                            router.push(
                              '/createupdateestimateinvoice',
                              extra: {
                                'isCreate': true,
                                "estimateInvoicesModel": model,
                                "itemModel": <InvoicesItems>[],
                                "unitWidget": <EstimateInvoicesUnit>[]
                              },
                            );

                            // createEditNotes(isLightTheme: isLightTheme, isCreate: true);
                          },
                        ),
                      ),
                      SizedBox(height: 20.h),
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
                                    final filterState = context
                                        .read<EstimateInvoiceFilterCountBloc>()
                                        .state;

                                    // Optionally trigger the search event with an empty string
                                    context.read<EstinateInvoiceBloc>().add(
                                        SearchEstimateInvoices(
                                            "",
                                            filterState.selectedTypeIds,
                                            filterState.selectedUserCreatorIds,
                                            filterState
                                                .selectedClientCreatorIds,
                                            filterState.selectedClientIds,
                                            filterState.fromDate,
                                            filterState.toDate));
                                  },
                                ),
                              ),
                            IconButton(
                              icon: Icon(
                                !speechHelper.isListening
                                    ? Icons.mic_off
                                    : Icons.mic,
                                size: 20.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .textFieldColor,
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
                            BlocBuilder<EstimateInvoiceFilterCountBloc,
                                EstimateInvoiceFilterCountState>(
                              builder: (context, state) {
                                return SizedBox(
                                  width: 35.w,
                                  child: Stack(
                                    children: [
                                      IconButton(
                                        icon: HeroIcon(
                                          HeroIcons.adjustmentsHorizontal,
                                          style: HeroIconStyle.solid,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .textFieldColor,
                                          size: 30.sp,
                                        ),
                                        onPressed: () {
                                          final estinateInvoiceBloc = context
                                              .read<EstinateInvoiceBloc>();

                                          showModalBottomSheet(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .containerDark,
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) =>
                                                EstimateInvoiceFilterDialog(
                                                    isLightTheme: isLightTheme,
                                                    filter: filter,
                                                    estinateInvoice:
                                                        estinateInvoiceBloc),
                                          );
                                          // Your existing filter dialog logic
                                        },
                                      ),
                                      if (state.count > 0)
                                        Positioned(
                                          right: 5.w,
                                          top: 7.h,
                                          child: Container(
                                            padding: EdgeInsets.zero,
                                            alignment: Alignment.center,
                                            height: 12.h,
                                            width: 10.w,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: CustomText(
                                              text: state.count.toString(),
                                              color: Colors.white,
                                              size: 6,
                                              textAlign: TextAlign.center,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                        onChanged: (value) {
                          searchWord = value;
                          final filterState = context
                              .read<EstimateInvoiceFilterCountBloc>()
                              .state;

                          context.read<EstinateInvoiceBloc>().add(
                              SearchEstimateInvoices(
                                  value,
                                  filterState.selectedTypeIds,
                                  filterState.selectedUserCreatorIds,
                                  filterState.selectedClientCreatorIds,
                                  filterState.selectedClientIds,
                                  filterState.fromDate,
                                  filterState.toDate));
                        },
                      ),
                      SizedBox(height: 20.h),
                      Expanded(
                        child: RefreshIndicator(
                            color: AppColors.primary, // Spinner color
                            backgroundColor:
                                Theme.of(context).colorScheme.backGroundColor,
                            onRefresh: _onRefresh,
                            child: _EstinateInvoiceBloc(isLightTheme)),
                      ),
                    ],
                  ),
                )),
          );
  }

  Widget _EstinateInvoiceBloc(isLightTheme) {
    return BlocBuilder<EstinateInvoiceBloc, EstinateInvoiceState>(
      builder: (context, state) {
        print("udhrghkd $state");
        if (state is EstinateInvoiceDeleteSuccess) {
          // Navigator.pop(context);
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
          context
              .read<EstinateInvoiceBloc>()
              .add(const EstinateInvoiceLists([], [], [], [], "", ""));
        }
        if (state is EstinateInvoiceDeleteError) {
          flutterToastCustom(msg: state.errorMessage);
          context
              .read<EstinateInvoiceBloc>()
              .add(const EstinateInvoiceLists([], [], [], [], "", ""));
        }
        if (state is EstinateInvoiceLoading) {
          return NotesShimmer(
            height: 190.h,
            count: 4,
          );
        } else if (state is EstinateInvoicePaginated) {
          // Show EstinateInvoice list with pagination
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              // Check if the user has scrolled to the end and load more EstinateInvoice if needed
              if (!state.hasReachedMax &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                final filterState =
                    context.read<EstimateInvoiceFilterCountBloc>().state;

                context.read<EstinateInvoiceBloc>().add(
                    LoadMoreEstinateInvoices(
                        searchWord,
                        filterState.selectedTypeIds,
                        filterState.selectedUserCreatorIds,
                        filterState.selectedClientCreatorIds,
                        filterState.selectedClientIds,
                        filterState.fromDate,
                        filterState.toDate));
              }
              return false;
            },
            child: state.EstinateInvoice.isNotEmpty
                ? _EstinateInvoiceList(
                    isLightTheme, state.hasReachedMax, state.EstinateInvoice)
                : NoData(
                    isImage: true,
                  ),
          );
        } else if (state is EstinateInvoiceError) {
          // Show error message
          return Center(
            child: Text(
              state.errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return const Text("");
      },
    );
  }

  Widget _EstinateInvoiceList(
      isLightTheme, hasReachedMax, EstinateInvoiceList) {
    return ListView.builder(
      padding: EdgeInsets.only(left: 18.w, right: 18.w, bottom: 70.h, top: 0),
      // shrinkWrap: true,
      itemCount: hasReachedMax
          ? EstinateInvoiceList.length // No extra item if all data is loaded
          : EstinateInvoiceList.length + 1, // Add 1 for the loading indicator
      itemBuilder: (context, index) {
        if (index < EstinateInvoiceList.length) {
          final EstinateInvoice = EstinateInvoiceList[index];
          return index == 0
              ? ShakeWidget(
                  child: _EstinateInvoiceCard(
                      isLightTheme: isLightTheme,
                      EstinateInvoiceModel: EstinateInvoice,
                      EstinateInvoiceList: EstinateInvoiceList,
                      index: index))
              : _EstinateInvoiceCard(
                  isLightTheme: isLightTheme,
                  EstinateInvoiceModel: EstinateInvoice,
                  EstinateInvoiceList: EstinateInvoiceList,
                  index: index);
        } else {
          // Show a loading indicator when more EstinateInvoice are being loaded
          return CircularProgressIndicatorCustom(
            hasReachedMax: hasReachedMax,
          );
        }
      },
    );
  }

  Widget _EstinateInvoiceCard(
      {isLightTheme,
      required EstimateInvoicesModel EstinateInvoiceModel,
      required List<EstimateInvoicesModel> EstinateInvoiceList,
      required int index}) {
    final EstinateInvoiceFromDate =
        formatDateFromApi(EstinateInvoiceModel.fromDate!, context);
    final EstinateInvoiceToDate =
        formatDateFromApi(EstinateInvoiceModel.toDate!, context);
    Color getStatusColor(String? status) {
      switch (status?.toLowerCase()) {
        case 'accepted':
          return Colors.green;
        case 'sent':
          return AppColors.primary;
        case 'partially_paid':
          return Color(0xFFfaab01);
        case 'fully_paid':
          return Colors.green;
        case 'draft':
          return Color(0xFF8592a3);
        case 'declined':
          return Colors.red;
        case 'cancelled':
          return Colors.red;
        case 'expired':
          return Color(0xFFfaab01);
        case 'not_specified':
          return Color(0xFF8592a3);
        case 'due':
          return Colors.red;
        default:
          return Colors.transparent; // default/fallback color
      }
    }

    return DismissibleCard(
      title: EstinateInvoiceModel.id.toString(),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.endToStart &&
            context.read<PermissionsBloc>().isdeleteEstimateInvoice == true) {
          // Right to left swipe (Delete action)

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
                  EstinateInvoiceList.removeAt(index);
                });
                context
                    .read<EstinateInvoiceBloc>()
                    .add(DeleteEstinateInvoices(EstinateInvoiceModel.id!));
              });
              // Return false to prevent the dismissible from animating
              return false;
            }

            return false; // Always return false since we handle deletion manually
          } catch (e) {
            print("Error in dialog: $e");
            return false;
          }
        } else if (direction == DismissDirection.startToEnd &&
            context.read<PermissionsBloc>().iseditEstimateInvoice == true) {
          final unitList = EstinateInvoiceModel.items
              ?.map((item) => item.unit)
              .whereType<EstimateInvoicesUnit>()
              .toList();
          router.push(
            '/createupdateestimateinvoice',
            extra: {
              'isCreate': false,
              "estimateInvoicesModel": EstinateInvoiceModel,
              "itemsList": EstinateInvoiceModel.items!,
              "unitWidget": unitList
            },
          );

          return false; // Prevent dismiss
        }

        return false;
      },
      dismissWidget: Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Container(
          // height: 250.h,
          decoration: BoxDecoration(
              boxShadow: [
                isLightTheme
                    ? MyThemes.lightThemeShadow
                    : MyThemes.darkThemeShadow,
              ],
              // color: AppColors.red,
              color: Theme.of(context).colorScheme.containerDark,
              borderRadius: BorderRadius.circular(12)),
          width: double.infinity,
          // color: Colors.yellow,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: ID and Date
                InkWell(
                  onTap: () {
                    _launchUrl(
                      Uri.parse(
                          "${url}api/estimates-invoices/pdf/${EstinateInvoiceModel.id}"),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (EstinateInvoiceModel.type == "invoice")
                        Text(
                          "INV-${EstinateInvoiceModel.id.toString()}",
                          style: TextStyle(
                              color: AppColors.primary, fontSize: 16.sp),
                        ),
                      if (EstinateInvoiceModel.type == "estimate")
                        Text(
                          "EST-${EstinateInvoiceModel.id.toString()}",
                          style: TextStyle(
                              color: AppColors.primary, fontSize: 16.sp),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                // Title

                // EstinateInvoice Type
                Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: getStatusColor(EstinateInvoiceModel.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CustomText(
                      text: EstinateInvoiceModel.status!
                          .replaceAll('_', ' ') // Remove underscores
                          .split(
                              ' ') // Split the string by spaces (in case there are multiple words)
                          .map((word) =>
                              word[0].toUpperCase() +
                              word
                                  .substring(1)
                                  .toLowerCase()) // Capitalize the first letter of each word
                          .join(' '),
                      color: AppColors.pureWhiteColor,
                      size: 14.sp,
                      fontWeight: FontWeight.w700,
                    )),
                SizedBox(height: 16.h),
                // User & Amount
                Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 23.r,
                      backgroundColor: AppColors.greyColor,
                      child: CircleAvatar(
                        radius: 22.r,
                        backgroundColor: Colors.blue,
                        backgroundImage:
                            NetworkImage(EstinateInvoiceModel.client!.photo!),
                      ),
                    ),
                    SizedBox(width: 12.h),
                    // User details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: (EstinateInvoiceModel.client != null &&
                                  ((EstinateInvoiceModel
                                              .client!.firstName?.isNotEmpty ??
                                          false) ||
                                      (EstinateInvoiceModel
                                              .client!.lastName?.isNotEmpty ??
                                          false)))
                              ? "${EstinateInvoiceModel.client!.firstName ?? ''} ${EstinateInvoiceModel.client!.lastName ?? ''}"
                                  .trim()
                              : "",
                          color: Theme.of(context).colorScheme.textClrChange,
                          size: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        CustomText(
                          text: EstinateInvoiceModel.client!.email ?? "",
                          color: AppColors.greyColor,
                          size: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Amount
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "$currency ${EstinateInvoiceModel.total ?? ""}",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      " ${EstinateInvoiceFromDate}",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.textClrChange,
                        fontWeight: FontWeight.normal,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    HeroIcon(
                      HeroIcons.arrowUturnRight,
                      style: HeroIconStyle.solid,
                      color: Theme.of(context).colorScheme.textClrChange,
                      size: 15.sp,
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Text(
                      " ${EstinateInvoiceToDate.isNotEmpty ? EstinateInvoiceToDate : ""}",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.textClrChange,
                        fontWeight: FontWeight.normal,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                )
                // Action Icons
              ],
            ),
          ),
        ),
      ),
      direction: DismissDirection.horizontal,
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.endToStart &&
            context.read<PermissionsBloc>().isdeleteEstimateInvoice == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              EstinateInvoiceList.removeAt(index);
            });
            context
                .read<EstinateInvoiceBloc>()
                .add(DeleteEstinateInvoices(EstinateInvoiceModel.id!));
          });
        } else if (direction == DismissDirection.startToEnd) {
          // Perform edit action
        }
      },
    );
  }
}
