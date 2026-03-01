import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/colors.dart';

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(

      color: Theme.of(context).scaffoldBackgroundColor,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // SizedBox(height: 50,),
            Padding(
              padding:
              EdgeInsets.symmetric(
                  horizontal: 18.w),
              child: Container(
                height: 40.h,
                decoration:
                BoxDecoration(
                  border: Border.all(
                      color: AppColors
                          .primary,
                      width: 2),
                  borderRadius:
                  BorderRadius
                      .circular(
                      15.r),
                ),
                child: _tabBar,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class AppBarDelegate extends SliverPersistentHeaderDelegate {
  AppBarDelegate(this.child, {this.minHeight = kToolbarHeight, this.maxHeight});

  final Widget child;
  final double minHeight;
  final double? maxHeight;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight ?? minHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(  // Ensures child fills the header
      child: Container(
        color: Theme.of(context).colorScheme.backGroundColor,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant AppBarDelegate oldDelegate) {
    return child != oldDelegate.child ||
        minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight;
  }
}