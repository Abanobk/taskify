import 'package:flutter/material.dart';

import '../../config/colors.dart';


height(double height,context){
  var height = MediaQuery.of(context).size.height;
  // var Width = MediaQuery.of(context).size.width;

  var newHeight= height/height;
  return newHeight;
}
String removeHtmlTags(String text) {
  final RegExp exp = RegExp(r'<[^>]*>');
  return text.replaceAll(exp, '');
}
width(double width,context){
  var width = MediaQuery.of(context).size.width;
  // var width = MediaQuery.of(context).size.width;

  var newWidth= width/width;

  return newWidth;
}

double textSize(BuildContext context, double basePixelSize) {
  return basePixelSize * MediaQuery.of(context).size.width / 430; // Adjust divisor as needed
}


class DesignConfiguration {
  static setSvgPath(String name) {

    return 'assets/images/svg/$name.svg';
  }

  static setPngPath(String name) {

    return name;
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
    return const BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Color(0x33000000), // #00000033 in ARGB format
          offset: Offset(0, 8),     // x and y offset
          blurRadius: 24,           // blur radius
        ),
      ],
    );
  }


  static getProgress() {
    return const Center(child: CircularProgressIndicator(color: AppColors.whiteColor,));
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

 }
backArrow({required BuildContext context}){
  return  IconButton(
    icon: const Icon(Icons.arrow_back,color: AppColors.whiteColor,),
    onPressed: (){Navigator.pop(context);},
  );
}