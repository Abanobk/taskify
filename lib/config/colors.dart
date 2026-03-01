import 'package:flutter/material.dart';

extension AppColors on ColorScheme {

  static const Color primary = Color(0xff696CFF);
  static const Color secondary = Color(0xff22747F);
  // static const Color primary = Color(0xff696CFF);
  // static const Color secondary = Color(0xff22747F);

  static const Color greyForgetColor = Color(0xff9C9C9C);
  static const Color unselectedIcon = Color(0xffC4C4C4);
  static const Color whiteColor = Color(0xffF5F5F9);
  static const Color pureWhiteColor = Color(0xffffffff);
  static const Color brightBgColor = Color(0xffF5F5F9);
  static const Color textsubColor = Color(0xff616161);
  static const Color scaffoldBackgroundColor = Color(0xffFAFAFA);
  static const Color textsub2Color = Color(0xff212121);
  static const Color textColorInDarkheme = Color(0xff6D7D90);
  static const Color colorInDarkheme = Color(0xff9294F0);
  static const Color blackColor = Color(0xff000000);
  static const Color greyColor = Color(0xff999999);
  static const Color hintColor = Color(0xffD7D7D7);
  static const Color dividerColor = Color(0xffDFDFDF);
  static const Color dividerColor2 = Color(0xffF4F4F4);
  static const Color whiteBackgroundColor = Color(0xfff5eded);




  static const Color greenColor = Color(0xff71DD37);
  static const Color greyListColor = Color(0xffE5E7EB);
  static const Color orangeYellowishColor = Color(0xffFFAB00);
  static const Color mileStoneColor = Color(0xfffaab01);
  static const Color mileStoneBgColor = Color(0xfffddda6);
  static const Color photoColor = Color(0xff7bde4a);
  static const Color photoBgColor = Color(0xffd0e7d0);
  static const Color statusTimelineColor = Color(0xff566a7f);
  static const Color statusTimelineBgColor = Color(0xffbfc4c9);
  static const Color activityLogColor = Color(0xff16a7cf);
  static const Color activityLogBgColor = Color(0xffcff1fb);
  static const Color purpleColor = Color(0xff8E61E9);

  static const Color purple = Color(0xff03579b);


  static const Color purpleShade = Color(0xffE2E3FF);
  static const Color blueLight = Color(0xff39A8FD);
  static const Color purple2Color = Color(0xff8EC9F6);
  static const Color blueColor = Color(0xff75ACFF);
  static const Color orangeColor = Color(0xffFF8B8B);
  static const Color redColor = Color(0xffE96161);

  static const Color shades1Color = Color(0xffFDEDD3);
  static const Color shades2Color = Color(0xffDEECEC);
  static const Color shades3Color = Color(0xff8EC9F6);
  static const Color shades4Color = Color(0xffE0F2FF);
  static const Color shades5Color = Color(0xffF8E9C8);
  static const Color shades6Color = Color(0xffFCDADA);
  static const Color shades7Color = Color(0xffD2D3FF);

  static  Color containerColor1 =  const Color(0xffF8E9C8);
  static const Color containerColor2 =   Color(0xffDEECEC);
  static  Color lightDividerColor =   Colors.grey.shade50;


  static const Color darkBlue = Color(0xff3E4ADE);
  static const Color color2 = Color(0xffA698EB);
  static const Color color3 = Color(0xffD3CCF5);
  static const Color color4 = Color(0xffECE9FF);

  static const Color grad1Color = AppColors.primary;
  static const Color grad2Color = Colors.black54;
  static  Color lightGreyColor = const Color(0xff343434);

  static const Color darkColor = Color(0xff18181B);
  static const Color projDetailsSubText = Color(0xff707070);
  // static const Color darkColor = Color(0xff240750);
  static const Color darkContainer = Color(0xff27272A);
  static const Color chatLightTheme = Color(0xFFEDECF2);
  // static const Color darkContainer = Color(0xff344C64);
  static List<Color> colorLight = [
    const Color(0xffE0F2FF),
    const Color(0xffF8E9C8),
    const Color(0xffFCDADA),
    const Color(0xffD2D3FF),
  ];
  static List<Color> colorDark = [
    const Color(0xff4EB5FF),
    const Color(0xffFFCB58),
    const Color(0xffFF6F6F),
    const Color(0xff6265FF),
  ];

  // static List<Color> chatBackgroundColor = [
  //   const Color(0xff3a1e62),
  //   const Color(0xffaa8fd2),
  //
  // ];
  static List<Color> chatBackgroundColor = [
    const Color(0xff03579b),
    const Color(0xff54c5f8),

  ];


  static final List<Color> backgroundColors = [
    // Colors.white,
    const Color(0xffE0F2FF),
    const Color(0xffF8E9C8),
    const Color(0xffFCDADA),
    // Add more colors if you have more pages
  ];

  Color get textColorChange => brightness == Brightness.dark ? whiteColor : primary;
  Color get demoChange => brightness == Brightness.dark ? primary
      : white;
  Color get textClrChange => brightness == Brightness.dark ? pureWhiteColor : blackColor;
  Color get dividerClrChange => brightness == Brightness.dark ? lightGreyColor : lightDividerColor;
  Color get whitepurpleChange => brightness == Brightness.dark ? pureWhiteColor : purple;
  Color get selectedFieldListChange => brightness == Brightness.dark ? const Color(0xff343434): Colors.grey.shade400 ;

  Color get bgColorChange => brightness == Brightness.dark ?  darkColor:brightBgColor;
  Color get textChange => brightness == Brightness.dark ?  brightBgColor:darkColor;

  Color get textfieldDisabled => brightness == Brightness.dark ?  Colors.grey.shade800:Colors.grey.shade200;
  Color get backGroundColor => brightness == Brightness.dark ?  darkColor:pureWhiteColor;
  Color get alertBoxBackGroundColor => brightness == Brightness.dark ?  const Color(0xff2a2a2a):pureWhiteColor;
  Color get popupBackGroundColor => brightness == Brightness.dark ?  darkColor:pureWhiteColor;
  Color get containerDark => brightness == Brightness.dark ?  darkContainer:pureWhiteColor;
  Color get chatTheme => brightness == Brightness.dark ?  darkContainer:chatLightTheme;
  Color get containerDark1 => brightness == Brightness.dark ?     greyColor:pureWhiteColor;
  Color get navbarColor => brightness == Brightness.dark ?  containerDark:pureWhiteColor;
  Color get textFieldColor => brightness == Brightness.dark ?  pureWhiteColor:greyForgetColor;
  Color get dividerColorchange => brightness == Brightness.dark ?  darkContainer:dividerColor2;
  Color get colorChange => brightness == Brightness.dark ?  pureWhiteColor:projDetailsSubText;
  Color get blkwhiteChange => brightness == Brightness.dark ?  pureWhiteColor:blackColor;








  Color get btnColor => brightness == Brightness.dark ? whiteTemp : primary;

  Color get changeablePrimary => brightness == Brightness.dark
      ? const Color(0xffFDC994)
      : const Color(0xffFC6A57);

  Color get lightWhite => brightness == Brightness.dark ? darkColor : pureWhiteColor;
  // Color get sameThemeColor => brightness == Brightness.dark ? darkColor : pureWhiteColor;


  // Color get blue => brightness == Brightness.dark
  //     ? const Color(0xff8381d5)
  //     : const Color(0xff4543c1);

  Color get fontColor =>
      brightness == Brightness.dark ? whiteTemp : const Color(0xff222222);

  Color get gray =>
      brightness == Brightness.dark ? darkColor3 : const Color(0xfff0f0f0);

  Color get simmerBase =>
      brightness == Brightness.dark ? darkColor2 : Colors.grey[300]!;

  Color get simmerHigh =>
      brightness == Brightness.dark ? darkColor : Colors.grey[100]!;

  static Color darkIcon = const Color(0xff9B9B9B);

  static const Color lightWhite2 = Color(0xffEEF2F3);

  static const Color yellow = Color(0xfffdd901);
  static  Color detailsFieldOverlayFieldDark = Colors.grey.withValues(alpha: 0.2);
  static  Color detailsFieldOverlayFieldLight = Colors.grey.withValues(alpha: 0.2);
  Color get detailsOverlay => brightness == Brightness.dark ? detailsFieldOverlayFieldDark : detailsFieldOverlayFieldLight;

  static const Color red = Colors.red;

  Color get lightBlack => brightness == Brightness.dark
      ? whiteTemp.withValues()
      : const Color(0xff52575C);

  Color get lightBlack2 => brightness == Brightness.dark
      ? whiteTemp.withValues()
      : const Color(0xff999999);

  static const Color darkColor2 = Color(0xff252525);
  static const Color darkColor3 = Color(0xffa0a1a0);

  Color get white =>
      brightness == Brightness.dark ? darkColor2 : const Color(0xffFFFFFF);
  static const Color whiteTemp = Color(0xffFFFFFF);

  Color get black =>
      brightness == Brightness.dark ? whiteTemp : const Color(0xff000000);

  static const Color white10 = Colors.white10;
  static const Color white30 = Colors.white30;
  static const Color white70 = Colors.white70;

  static const Color black54 = Colors.black54;
  static const Color black12 = Colors.black12;
  static const Color disableColor = Color(0xffEEF2F9);
  // static const Color textsubColor = Color(0xff2C3948);

  static const Color blackTemp = Color(0xff000000);

  Color get black26 => brightness == Brightness.dark ? white30 : Colors.black54;
  static const Color cardColor = Color(0xffFFFFFF);

}
