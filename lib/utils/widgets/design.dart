import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../src/generated/i18n/app_localizations.dart';
class DesignConfiguration {
  static setSvgPath(String name) {
    return 'assets/images/svg/$name.svg';
  }

  static setPngPath(String name) {
    return name;
  }
  static printCustom(String message , String title) {
    return print("$message $title");
  }
  static setLottiePath(String name) {
    return 'assets/animation/$name.json';
  }

  static placeHolder(double height) {
    return AssetImage(
      DesignConfiguration.setPngPath('placeholder'),
    );
  }

  static erroWidget(double size) {
    return Image.asset(
      DesignConfiguration.setPngPath('placeholder'),
      height: size,
      width: size,
    );
  }

  static shadow() {
    return  const BoxDecoration(
      // color: Colors.grey.shade50,
      boxShadow: [
        BoxShadow(
          color: Color(0x1a0400ff),
          offset: Offset(0, 0),
          blurRadius: 30,
        )
      ],
    );
  }

  static back() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.grad1Color, AppColors.grad2Color],
        stops: [0, 1],
      ),
    );
  }

  static imagePlaceHolder(double size, BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Icon(
        Icons.account_circle,
        color: Theme.of(context).colorScheme.black,
        size: size,
      ),
    );
  }

  // static String? getPriceFormat(BuildContext context, double price) {
  //   return NumberFormat.currency(
  //     locale: Platform.localeName,
  //     name: '$supportedLocale',
  //     symbol: '$CUR_CURRENCY',
  //     decimalDigits: int.parse(DECIMAL_POINTS ?? '0'),
  //   ).format(price).toString();
  // }

  static getProgress() {
    return const Center(child: CircularProgressIndicator());
  }

  static getNoItem(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.noitems,
        style: TextStyle(
            fontFamily: 'ubuntu',
            color: Theme.of(context).colorScheme.fontColor),
      ),
    );
  }

  static Widget showCircularProgress(bool isProgress, Color color) {
    if (isProgress) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    return const SizedBox(
      height: 0.0,
      width: 0.0,
    );
  }

  static dialogAnimate(BuildContext context, Widget dialge) {
    return showGeneralDialog(
      barrierColor: Theme.of(context).colorScheme.black.withValues(alpha:0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(opacity: a1.value, child: dialge),
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox();
      },
    );
  }

  static getCacheNotworkImage({
    required String imageurlString,
    required BuildContext context,
    required BoxFit? boxFit,
    required double? heightvalue,
    required double? widthvalue,
    required double? placeHolderSize,
  }) {
    return FadeInImage.assetNetwork(
      // placeholderCacheWidth: 50,
      // imageCacheHeight: 50,
      // placeholderCacheHeight: 50,
      // imageCacheWidth: 50,
      image: imageurlString,
      placeholder: DesignConfiguration.setPngPath('placeholder'),
      width: widthvalue,
      height: heightvalue,
      fit: boxFit,
      fadeInDuration: const Duration(
        milliseconds: 150,
      ),
      fadeOutDuration: const Duration(
        milliseconds: 150,
      ),
      // imageCacheHeight: 50,
      //imageCacheWidth: 50,
      fadeInCurve: Curves.linear,
      fadeOutCurve: Curves.linear,
      imageErrorBuilder: (context, error, stackTrace) {
        return Container(
          child: DesignConfiguration.erroWidget(placeHolderSize ?? 50),
        );
      },
    );

    /*CachedNetworkImage(
      imageUrl: imageurlString,
      placeholder: (context, url) {
        return DesignConfiguration.erroWidget(placeHolderSize ?? 50);
      },
      errorWidget: (context, error, stackTrace) {
        return Container(
          child: DesignConfiguration.erroWidget(placeHolderSize ?? 50),
        );
      },
      fadeInCurve: Curves.linear,
      fadeOutCurve: Curves.linear,
      fadeInDuration: const Duration(
        milliseconds: 150,
      ),
      fadeOutDuration: const Duration(
        milliseconds: 150,
      ),
      fit: boxFit,
      height: heightvalue,
      width: widthvalue,
    );*/
  }
}



class MyBehavior extends ScrollBehavior {
  Widget glowingOverscrollIndicator(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
