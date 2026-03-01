import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:taskify/bloc/items/item_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import '../../../../bloc/items/item_event.dart';
import '../../../../bloc/items/item_state.dart';
import '../../../../data/model/finance/estimate_invoices_model.dart';
import '../../../../utils/widgets/custom_text.dart';
import '../../../widgets/custom_cancel_create_button.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
class ItemsListField extends StatefulWidget {
  final bool fromProfile;
  final bool isCreate;
  final List<String>? name;
  final List<int>? ids;
  final bool? isEdit;
  final bool? isRequired;
  final bool? isProfile;
  final Function(List<String>, List<int>, InvoicesItems) onSelected;
  final Function(int)? onDeselected;

  const ItemsListField({
    super.key,
    required this.fromProfile,
    required this.isCreate,
    this.isEdit,
    this.isRequired,
    this.name,
    this.ids,
    this.isProfile,
    required this.onSelected,
    this.onDeselected,
  });

  @override
  State<ItemsListField> createState() => _ItemsListFieldState();
}

class _ItemsListFieldState extends State<ItemsListField> {
  List<String> itemsName = [];
  List<int> itemsId = [];
  String searchWord = "";
  List<int> tempSelectedItemIds = [];
  List<InvoicesItems> tempSelectedItems = [];
  final TextEditingController _roleMultiSearchController = TextEditingController();
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    itemsName = List.from(widget.name ?? []);
    itemsId = List.from(widget.ids ?? []);
    tempSelectedItemIds = List.from(widget.ids ?? []);
    _scrollController = ScrollController();
    _scrollController!.addListener(_scrollListener);
    BlocProvider.of<ItemsBloc>(context).add(ItemsList());
    context.read<ItemsBloc>().add(SearchItems("", ""));
  }

  void _scrollListener() {
    if (_scrollController!.position.atEdge &&
        _scrollController!.position.pixels != 0) {
      final state = context.read<ItemsBloc>().state;
      if (state is ItemsPaginated && !state.hasReachedMax) {
        BlocProvider.of<ItemsBloc>(context).add(LoadMoreItems(searchWord));
      }
    }
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_scrollListener);
    _scrollController?.dispose();
    _roleMultiSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<ItemsBloc, ItemsState>(
          builder: (context, state) {
            if (state is ItemsInitial) {
              return const SizedBox();
            } else if (state is ItemsLoading) {
              return const Center(child: SpinKitFadingCircle(color: AppColors.primary, size: 40.0));
            } else if (state is ItemsPaginated) {
              if (tempSelectedItems.isEmpty && widget.ids != null) {
                tempSelectedItems = state.Items.where((item) => widget.ids!.contains(item.id)).toList();
                // Ensure itemsName is in sync with tempSelectedItems
                itemsName = tempSelectedItems.map((item) => item.title ?? '').toList();
                itemsId = tempSelectedItems.map((item) => item.id ?? 0).toList();
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.fromProfile)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          CustomText(
                            text: AppLocalizations.of(context)!.items,
                            color: Theme.of(context).colorScheme.textClrChange,
                            size: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          if (widget.isRequired == true)
                            const CustomText(
                              text: " *",
                              color: AppColors.red,
                              size: 15,
                              fontWeight: FontWeight.w400,
                            ),
                        ],
                      ),
                    ),
                  SizedBox(height: widget.fromProfile ? 2.h : 5.h),
                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => StatefulBuilder(
                          builder: (BuildContext dialogContext, StateSetter setDialogState) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
                              contentPadding: EdgeInsets.zero,
                              title: Column(
                                children: [
                                  CustomText(
                                    text: AppLocalizations.of(context)!.selectitem,
                                    fontWeight: FontWeight.w800,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.whitepurpleChange,
                                  ),
                                  const Divider(),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                                    child: SizedBox(
                                      height: 35.h,
                                      width: double.infinity,
                                      child: TextField(
                                        cursorColor: AppColors.greyForgetColor,
                                        cursorWidth: 1,
                                        controller: _roleMultiSearchController,
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
                                          setDialogState(() {
                                            searchWord = value;
                                          });
                                          context.read<ItemsBloc>().add(SearchItems(value, ""));
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                ],
                              ),
                              content: Container(
                                constraints: BoxConstraints(maxHeight: 400.h),
                                width: 300.w,
                                margin: EdgeInsets.symmetric(horizontal: 10.w),
                                child: state.Items.isEmpty?NoData(isImage: true,):ListView.builder(
                                  controller: _scrollController,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: state.hasReachedMax ? state.Items.length : state.Items.length + 1,
                                  itemBuilder: (BuildContext context, int index) {
                                    if (index < state.Items.length) {
                                      final item = state.Items[index];
                                      final isSelected = tempSelectedItemIds.contains(item.id);

                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 0.w),
                                        child: InkWell(
                                          highlightColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          onTap: () {
                                            setDialogState(() {
                                              if (isSelected) {
                                                tempSelectedItemIds.remove(item.id);
                                                tempSelectedItems.removeWhere((i) => i.id == item.id);
                                                itemsName.remove(item.title);
                                                itemsId.remove(item.id);
                                                if (widget.onDeselected != null) {
                                                  widget.onDeselected!(item.id!);
                                                }
                                              } else {
                                                tempSelectedItemIds.add(item.id!);
                                                tempSelectedItems.add(item);
                                                itemsName.add(item.title ?? '');
                                                itemsId.add(item.id ?? 0);
                                                widget.onSelected([item.title!], [item.id!], item);
                                              }
                                            });
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            height: 35.h,
                                            decoration: BoxDecoration(
                                              color: isSelected ? AppColors.purpleShade : Colors.transparent,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: isSelected ? AppColors.primary : Colors.transparent,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: CustomText(
                                                      text: item.title ?? '',
                                                      fontWeight: FontWeight.w500,
                                                      size: 18.sp,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      color: isSelected
                                                          ? AppColors.purple
                                                          : Theme.of(context).colorScheme.textClrChange,
                                                    ),
                                                  ),
                                                  if (isSelected)
                                                    const HeroIcon(
                                                      HeroIcons.checkCircle,
                                                      style: HeroIconStyle.solid,
                                                      color: AppColors.purple,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10.h),
                                        child: Center(
                                          child: state.hasReachedMax
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
                                    title: "OK",
                                    onpressCancel: () {
                                      Navigator.pop(dialogContext);
                                    },
                                    onpressCreate: () {
                                      setState(() {
                                        itemsName = tempSelectedItems.map((item) => item.title ?? '').toList();
                                        itemsId = tempSelectedItems.map((item) => item.id ?? 0).toList();
                                      });
                                      Navigator.pop(dialogContext);
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
                      height: 40.h,
                      width: double.infinity,
                      margin: widget.fromProfile
                          ? const EdgeInsets.symmetric(horizontal: 10)
                          : const EdgeInsets.symmetric(horizontal: 20),
                      decoration: widget.fromProfile
                          ? BoxDecoration(
                        color: Theme.of(context).colorScheme.containerDark,
                      )
                          : BoxDecoration(
                        border: Border.all(color: AppColors.greyColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: itemsName.isNotEmpty
                                  ? itemsName.join(", ")
                                  : AppLocalizations.of(context)!.selectitem,
                              fontWeight: FontWeight.w400,
                              size: 14.sp,
                              color: Theme.of(context).colorScheme.textClrChange,
                              maxLines: 1,
                            ),
                            if (!widget.fromProfile || widget.isCreate)
                              Icon(
                                Icons.arrow_drop_down,
                                color: Theme.of(context).colorScheme.backGroundColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is ItemsError) {
              return Text("ERROR ${state.errorMessage}");
            }
            return Container();
          },
        ),
      ],
    );
  }
}