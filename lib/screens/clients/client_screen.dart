import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/permissions/permissions_event.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/screens/widgets/no_permission_screen.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../../src/generated/i18n/app_localizations.dart';

import 'package:taskify/utils/widgets/back_arrow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/clients/client_bloc.dart';
import '../../bloc/clients/client_event.dart';
import '../../bloc/clients/client_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_text.dart';
import 'package:heroicons/heroicons.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../notes/widgets/notes_shimmer_widget.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../widgets/edit_delete_pop.dart';
import '../widgets/search_field.dart';
import '../widgets/side_bar.dart';
import '../widgets/speech_to_text.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  final TextEditingController searchController = TextEditingController();
  final SlidableBarController sideBarController = SlidableBarController(initialStatus: false);
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late SpeechToTextHelper speechHelper;
  
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  String searchword = "";
  bool isLoading = true;
  static const bool _onDevice = false;

  final options = SpeechListenOptions(
    onDevice: _onDevice,
    listenMode: ListenMode.confirmation,
    cancelOnError: true,
    partialResults: true,
    autoPunctuation: true,
    enableHapticFeedback: true
  );

  void onDeleteClient(client) {
    context.read<ClientBloc>().add(DeleteClients(client));

    final clientBloc = context.read<ClientBloc>();
    clientBloc.stream.listen((state) {
      if (state is ClientDeleteSuccess) {
        router.push('/client');
        if (mounted) {
          flutterToastCustom(
            msg: AppLocalizations.of(context)!.deletedsuccessfully,
            color: AppColors.primary
          );
        }
      }
      if (state is ClientDeleteError) {
        flutterToastCustom(msg: state.errorMessage);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _initializeSpeechRecognition();
    _loadInitialData();
  }

  void _initializeConnectivity() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() => _connectionStatus = results);
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() => _connectionStatus = value);
        });
      }
    });
  }

  void _initializeSpeechRecognition() {
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<ClientBloc>().add(SearchClients(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
  }

  void _loadInitialData() {

    searchController.addListener(() => setState(() {}));
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<ClientBloc>(context).add(ClientList());
    
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() => isLoading = true);
    BlocProvider.of<ClientBloc>(context).add(ClientList());
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    final isLightTheme = currentTheme is LightThemeState;

    return _connectionStatus.contains(ConnectivityResult.none)
        ? NoInternetScreen()
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            body: SideBar(
              context: context,
              controller: sideBarController,
              underWidget: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: BackArrow(
                        iSBackArrow: true,
                        iscreatePermission: context.read<PermissionsBloc>().iscreateClient,
                        title: AppLocalizations.of(context)!.clientsFordrawer,
                        isAdd: context.read<PermissionsBloc>().iscreateClient,
                        onPress: () => router.push(
                          '/createclient',
                          extra: {'isCreate': true},
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.only(bottom: 25.h),
                      child: CustomSearchField(
                        isLightTheme: isLightTheme,
                        controller: searchController,
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (searchController.text.isNotEmpty)
                                SizedBox(
                                  width: 20.w,
                                  child: IconButton(
                                    highlightColor: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.clear,
                                      size: 20.sp,
                                      color: Theme.of(context).colorScheme.textFieldColor,
                                    ),
                                    onPressed: () {
                                      searchController.clear();
                                      context.read<ClientBloc>().add(SearchClients(""));
                                    },
                                  ),
                                ),
                              IconButton(
                                icon: Icon(
                                  !speechHelper.isListening ? Icons.mic_off : Icons.mic,
                                  size: 20.sp,
                                  color: Theme.of(context).colorScheme.textFieldColor,
                                ),
                                onPressed: () {
                                  if (speechHelper.isListening) {
                                    speechHelper.stopListening();
                                  } else {
                                    speechHelper.startListening(context, searchController, SearchPopUp());
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        onChanged: (value) {
                          searchword = value;
                          context.read<ClientBloc>().add(SearchClients(value));
                          setState(() {});
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.backGroundColor,
                        child: RefreshIndicator(
                          color: AppColors.primary,
                          backgroundColor: Theme.of(context).colorScheme.backGroundColor,
                          onRefresh: _onRefresh,
                          child: _clientGridList(isLightTheme)
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          );
  }

  Widget _clientGridList(bool isLightTheme) {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        if (state is ClientInitial || state is ClientLoading) {
          return GridShimmer(count: 10);
        } else if (state is ClientError) {
          return Text("ERROR ${state.errorMessage}");
        }
        
        return AbsorbPointer(
          absorbing: false,
          child: BlocBuilder<ClientBloc, ClientState>(
            builder: (context, state) {
              if (state is ClientPaginated) {
                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (!state.hasReachedMax && state.isLoading && 
                        scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                      BlocProvider.of<ClientBloc>(context).add(ClientLoadMore(searchword));
                    }
                    return false;
                  },
                  child: context.read<PermissionsBloc>().isManageClient == true
                    ? state.client.isNotEmpty
                      ? Stack(children: [
                          MasonryGridView.count(
                            padding: EdgeInsets.only(
                              top: 0.h,
                              bottom: 50.h,
                              left: 18.w,
                              right: 18.w
                            ),
                            crossAxisCount: 2,
                            mainAxisSpacing: 13,
                            crossAxisSpacing: 15,
                            itemCount: state.hasReachedMax
                                ? state.client.length
                                : state.client.length + 1,
                            itemBuilder: (context, index) {
                              if (index < state.client.length) {
                                final hasPhoneNumber = state.client[index].phone != null && 
                                    state.client[index].phone!.isNotEmpty;
                                return _clientListCard(
                                  state.client[index].id,
                                  hasPhoneNumber,
                                  isLightTheme,
                                  index,
                                  state.client[index],
                                  state.client,
                                  state.isLoading
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ])
                      : NoData(isImage: true)
                    : NoPermission()
                );
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _clientListCard(
    clientId, 
    bool hasPhone, 
    bool isLightTheme, 
    int index, 
    clientIndex, 
    List<dynamic> client, 
    bool isLoading
  ) {
    return Padding(
      padding: EdgeInsets.only(top: 0.w),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () => router.push(
          '/clientdetails',
          extra: {
            "isClient": "client",
            "id": clientId,
          },
        ),
        child: Container(
          height: hasPhone ? 225.h : 205.h,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.containerDark,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildHeader(clientIndex, index, client),
                _buildClientInfo(clientIndex),
                _buildStatsSection(clientIndex),
                _buildStatusSection(clientIndex),
                if (clientIndex.phone != null && clientIndex.phone!.isNotEmpty)
                  _buildPhoneSection(clientIndex),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(clientIndex, int index, List<dynamic> client) {
    final permissionsBloc = context.read<PermissionsBloc>();
    final isEditAllowed = permissionsBloc.iseditClient ?? false;
    final isDeleteAllowed = permissionsBloc.isdeleteClient ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: "#${clientIndex.id!}",
          size: 12.sp,
          color: Theme.of(context).colorScheme.textClrChange,
          fontWeight: FontWeight.w600,
        ),
        if (isEditAllowed || isDeleteAllowed)
          SizedBox(
            height: 30.h,
            child: Row(
              children: [
                Container(
                  width: 30.w,
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: CustomPopupMenuButton(
                    isEditAllowed: isEditAllowed,
                    isDeleteAllowed: isDeleteAllowed,
                    onSelected: (value) {
                      if (value == 'Edit') {
                        router.push(
                          '/createclient',
                          extra: {
                            'isCreate': false,
                            "index": index,
                            "client": client,
                            "clientModel": clientIndex
                          },
                        );
                      } else if (value == "Delete") {
                        _showDeleteConfirmationDialog(clientIndex.id);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildClientInfo(clientIndex) {
    return Row(
      children: [
        clientIndex.profile != null
            ? CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 20.r,
                backgroundImage: NetworkImage(clientIndex.profile!),
              )
            : CircleAvatar(
                radius: 20.r,
                backgroundColor: Colors.grey[200],
              ),
        SizedBox(width: 10.h),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 70.w,
              child: CustomText(
                text: clientIndex.firstName!,
                size: 14.sp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                color: Theme.of(context).colorScheme.textClrChange,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              width: 70.w,
              child: CustomText(
                text: clientIndex.email!,
                size: 12.sp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                color: Theme.of(context).colorScheme.colorChange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildStatsSection(clientIndex) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        SizedBox(
          width: 150.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                AppLocalizations.of(context)!.projectwithCounce,
                clientIndex.assigned?.projects?.toString() ?? "0"
              ),
              _buildStatItem(
                AppLocalizations.of(context)!.tasks,
                clientIndex.assigned?.tasks?.toString() ?? "0"
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        CustomText(
          text: label,
          size: 12.sp,
          color: Theme.of(context).colorScheme.colorChange,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 5.h),
        Container(
          width: 60.w,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(5)
          ),
          child: Center(
            child: CustomText(
              text: value,
              size: 12.sp,
              color: Theme.of(context).colorScheme.textClrChange,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildStatusSection(clientIndex) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        SizedBox(
          width: 150.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusItem(
                AppLocalizations.of(context)!.status,
                clientIndex.status == 1 ? "Active" : "InActive",
                clientIndex.status == 1 ? Colors.green : Colors.red
              ),
              _buildEmailVerificationStatus(clientIndex),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(String label, String status, Color color) {
    return Column(
      children: [
        CustomText(
          text: label,
          size: 12.sp,
          color: Theme.of(context).colorScheme.colorChange,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 5.h),
        Container(
          height: 20.h,
          width: 60.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5)
          ),
          child: Center(
            child: CustomText(
              text: status,
              size: 10.sp,
              color: AppColors.pureWhiteColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailVerificationStatus(clientIndex) {
    return Column(
      children: [
        SizedBox(
          width: 60.w,
          child: CustomText(
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            text: AppLocalizations.of(context)!.emailverified,
            size: 12.sp,
            color: Theme.of(context).colorScheme.colorChange,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 5.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Center(
            child: HeroIcon(
              clientIndex.emailVerificationMailSent == 1 
                ? HeroIcons.checkBadge 
                : HeroIcons.exclamationCircle,
              style: HeroIconStyle.solid,
              size: 20.sp,
              color: clientIndex.emailVerificationMailSent == 1 
                ? Colors.green 
                : Colors.orange,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPhoneSection(clientIndex) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        Row(
          children: [
            HeroIcon(
              HeroIcons.phone,
              style: HeroIconStyle.solid,
              size: 12.sp,
              color: Theme.of(context).colorScheme.textFieldColor,
            ),
            SizedBox(width: 10.w),
            CustomText(
              text: clientIndex.phone ?? "",
              size: 12.sp,
              color: Theme.of(context).colorScheme.colorChange,
              fontWeight: FontWeight.w400,
              letterspace: 2,
            ),
          ],
        )
      ],
    );
  }

  void _showDeleteConfirmationDialog(clientId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
        title: Text(AppLocalizations.of(context)!.confirmDelete),
        content: Text(AppLocalizations.of(context)!.areyousure),
        actions: [
          TextButton(
            onPressed: () {
              onDeleteClient(clientId);
              context.read<ClientBloc>().add(ClientList());
              Navigator.of(context).pop(true);
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
