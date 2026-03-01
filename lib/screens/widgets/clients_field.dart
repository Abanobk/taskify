import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/clients/client_bloc.dart';
import '../../bloc/clients/client_event.dart';
import '../../bloc/clients/client_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../data/model/clients/client_model.dart';
import '../../utils/widgets/custom_text.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/no_data.dart';
import 'custom_cancel_create_button.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class ClientField extends StatefulWidget {
  final bool isCreate;
  final bool isRequired;
  final List<String> usersname;
  final List<int> clientsid;
  final List<ClientModel> project;
  final Function(List<String>, List<int>) onSelected;

  const ClientField({
    super.key,
    this.isRequired = false,
    required this.isCreate,
    required this.usersname,
    required this.project,
    required this.clientsid,
    required this.onSelected,
  });

  @override
  State<ClientField> createState() => _ClientFieldState();
}

class _ClientFieldState extends State<ClientField> {
  List<int> userSelectedId = [];
  List<String> userSelectedname = [];
  String searchWord = "";
  final TextEditingController _clientSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize selections from widget props
    _initializeSelections();
    // Fetch client list
    BlocProvider.of<ClientBloc>(context).add(ClientList());
  }



  void _initializeSelections() {
    userSelectedId.clear();
    userSelectedname.clear();

    // Populate userSelectedId and userSelectedname from widget.clientsid and widget.usersname
    for (int i = 0; i < widget.clientsid.length; i++) {
      final id = widget.clientsid[i];
      if (!userSelectedId.contains(id)) {
        userSelectedId.add(id);
        // Only add non-empty, non-whitespace names
        if (i < widget.usersname.length && widget.usersname[i].trim().isNotEmpty) {
          userSelectedname.add(widget.usersname[i].trim());
        } else {
          print("Warning: Skipping empty or invalid name for client ID $id at index $i");
        }
      }
    }
    print("Initialized userSelectedname: $userSelectedname (length: ${userSelectedname.length})");

    // Defer the onSelected callback to after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSelected(userSelectedname, userSelectedId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    bool isLightTheme = currentTheme is LightThemeState;

    print("build: userSelectedname.length: ${userSelectedname.length}");
    print("build: userSelectedname: $userSelectedname");
    if (userSelectedname.isNotEmpty) {
      print("build: userSelectedname[0]: '${userSelectedname[0]}'");
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.clients,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              if (widget.isRequired)
                const CustomText(
                  text: " *",
                  color: AppColors.red,
                  size: 15,
                  fontWeight: FontWeight.w400,
                ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        BlocBuilder<ClientBloc, ClientState>(
          builder: (context, state) {
            print("BlocBuilder state: $state");
            return AbsorbPointer(
              absorbing: state is ClientInitial,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      if (state is! ClientInitial) {
                        showDialog(
                          context: context,
                          builder: (ctx) => _buildDialog(context),
                        );
                      }
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
                                  ? (userSelectedname.any((name) => name.trim().isNotEmpty)
                                  ? userSelectedname.join(", ")
                                  : AppLocalizations.of(context)!.selectclient)
                                  : (widget.usersname.any((name) => name.trim().isNotEmpty)
                                  ? widget.usersname.join(", ")
                                  : AppLocalizations.of(context)!.selectclient),
                              fontWeight: FontWeight.w500,
                              size: 14.sp,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              color:
                              Theme.of(context).colorScheme.textClrChange,
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

  Widget _buildDialog(BuildContext context) {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        if (state is ClientPaginated) {
          ScrollController scrollController = ScrollController();
          scrollController.addListener(() {
            if (scrollController.position.atEdge &&
                scrollController.position.pixels != 0) {
              BlocProvider.of<ClientBloc>(context).add(ClientLoadMore(searchWord));
            }
          });

          return StatefulBuilder(
            builder: (BuildContext dialogContext, void Function(void Function()) dialogSetState) {
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
                                dialogSetState(() {
                                  searchWord = value;
                                });
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
                  child: state.client.isEmpty ?NoData(isImage: true):ListView.builder(
                    controller: scrollController,
                    shrinkWrap: true,
                    itemCount: state.client.length,
                    itemBuilder: (BuildContext context, int index) {
                      final clientId = state.client[index].id!;
                      final clientName = state.client[index].firstName ?? "Unknown Client";
                      final isSelected = userSelectedId.contains(clientId);

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.h),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              // Update parent widget's state
                              if (isSelected) {
                                userSelectedId.remove(clientId);
                                userSelectedname.remove(clientName);
                              } else {
                                if (clientName.trim().isNotEmpty) {
                                  userSelectedId.add(clientId);
                                  userSelectedname.add(clientName.trim());
                                } else {
                                  print("Skipping empty client name for ID $clientId");
                                }
                              }
                              print("Updated userSelectedname: $userSelectedname (length: ${userSelectedname.length})");
                              widget.onSelected(userSelectedname, userSelectedId);
                            });
                            dialogSetState(() {
                              // Update dialog's UI
                            });
                            // Optionally update ClientBloc
                            BlocProvider.of<ClientBloc>(context).add(
                              ToggleClientSelection(index, clientName),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.purpleShade : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.purple : Colors.transparent,
                                ),
                              ),
                              width: double.infinity,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: SizedBox(
                                          width: 200.w,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundImage: NetworkImage(state.client[index].profile ?? ""),
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
                                                              text: state.client[index].firstName ?? "Unknown",
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
                                                              text: state.client[index].lastName ?? "",
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
                                                              text: state.client[index].email ?? "",
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
                        ),
                      );
                    },
                  ),
                ),
                actions: [
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
    );
  }
}