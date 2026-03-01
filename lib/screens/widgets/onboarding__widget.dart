import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';

import '../../config/colors.dart';
import '../../config/strings.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_text.dart';
import 'onboarding_contacts.dart';

import '../../../src/generated/i18n/app_localizations.dart';




class OnboardingPage extends StatefulWidget {
  final String title;
  final Color color;
  final String description;
  final String imageUrl;
  final ValueNotifier<int> currentPage;
  final PageController controller;
  final bool isLastPage;
  final VoidCallback? onNext; // Optional callback for "Next" button

  const OnboardingPage({
    super.key,
    required this.title,
    required this.color,
    required this.description,
    required this.currentPage,
    required this.controller,
    required this.imageUrl,
    this.isLastPage = false,
    this.onNext,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      // Update current page value when the page controller changes
      widget.currentPage.value = widget.controller.page?.round() ?? 0;
    });
  }
  @override
  void dispose() {
    // widget.controller.dispose();
    // widget.currentPage.dispose();
    super.dispose();
  }
  setFirst() async {
    var box = await Hive.openBox(authBox);
    box.put(firstTimeUserKey, false);
  }
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      color: widget.color,
      child: Column(
        children: [
          InkWell(
            highlightColor: Colors.transparent, // No highlight on tap
            splashColor: Colors.transparent,
            onTap: () {
              setState(() {
                widget.controller.previousPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                );
                // _currentPage.value = currentPage;
                // _currentPage.value++;
              });
            },
            child: Padding(
              padding:  EdgeInsets.only(top: 50.h),
              child: SizedBox(
                width: width,
                 // color: Colors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.06),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                        size: 30.sp,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: width * 0.06),
                      child: InkWell(
                        highlightColor: Colors.transparent, // No highlight on tap
                        splashColor: Colors.transparent,
                        onTap: () {
                          router.go('/login');
                          setFirst();
                        },
                        child: Container(
                          height: height * 0.035,
                          width: width * 0.16,
                          decoration: BoxDecoration(
                            // gradient: LinearGradient(
                            //   stops: [0, 1],
                            //   begin: Alignment.topLeft,
                            //   end: Alignment.bottomRight,
                            //   colors: [colors.primary, colors.secondary],
                            // ),
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(15)),
                          child: Center(
                              child: CustomText(
                                text: AppLocalizations.of(context)!.skip,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          Center(
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: width*0.06),
                child: Column(
                  children: [
                    Container(

                      alignment: Alignment.topCenter,
                      width: width,
                      // height: height*0.5,
                      child: Padding(
                        padding: EdgeInsets.only(top: height * 0.1),
                        child: Container(

                           height: height * 0.4,
                          width: width,
                          decoration: BoxDecoration(
                            // color: colors.red,
                            image: DecorationImage(
                              image: AssetImage(widget.imageUrl), // Path to your image
                              fit: BoxFit
                                  .contain, // Adjust how the image fits the container (cover, contain, etc.)
                            ),
                          ),
                        ),
                        // Your other widgets inside the container (optional)
                      ),
                    ),
                    // SizedBox(height: 20),
                    SizedBox(
                      height: height * 0.25,
                      width: width,
                      child: Column(
                        children: [
                          SizedBox(height: 20.h),
                          CustomText(
                              text: widget.title,
                              size: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blackColor),

                          SizedBox(height: 20.h),
                          CustomText(
                            // onTapPress: (){},
                            text: widget.description,
                            size: 18.sp, color: AppColors.greyForgetColor,
                            textAlign: TextAlign.center,
                            fontWeight: FontWeight.w600,
                            maxLines: 4,
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),

                  ],
                ),
              )),
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.06,vertical: 10.h),
            child: SizedBox(
              // color: Colors.blue,
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIndicatorDots(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildIndicatorDots() {
    return Container(
      // color: Color(0xff302C52),
      color: widget.color,
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          contents.length,
              (int index) => _buildDots(
            index: index,
          ),
        ),
      ),
    );
  }
  AnimatedContainer _buildDots({
    int? index,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(30.r),
        ),
        border: widget.currentPage.value == index
            ? Border.all(color: AppColors.primary)
            : Border.all(color: Colors.white),
        color: widget.currentPage.value == index ? AppColors.primary : Colors.white,
      ),
      margin:  EdgeInsets.only(right: 10.w),
      height: 8.h,
      curve: Curves.easeIn,
      width: widget.currentPage.value == index ? 40.w : 8.w,
    );
  }

}
