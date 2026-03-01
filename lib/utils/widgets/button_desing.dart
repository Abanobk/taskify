
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../config/colors.dart';

class SimBtn extends StatelessWidget {
  final String? title;
  final VoidCallback? onBtnSelected;
   final double? size;
  final double? height;
  final Color? backgroundColor, borderColor, titleFontColor;
  final double? borderWidth, borderRadius;

  const SimBtn({
    super.key,
    this.title,
    this.onBtnSelected,
    this.size,
    this.height,
    this.titleFontColor,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {

    return _buildBtnAnimation(context);
  }

  Widget _buildBtnAnimation(BuildContext context) {
    return CupertinoButton(
      child: Container(
        width: size,
        height: height ?? 35,
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.grad1Color, AppColors.grad2Color],
              stops: [0, 1]),
          color: backgroundColor ?? AppColors.primary,
          borderRadius: BorderRadius.all(
            Radius.circular(
              borderRadius ?? 0.0,
            ),
          ),
          border: Border.all(
            width: borderWidth ?? 0,
            color: borderColor ?? Colors.transparent,
          ),
        ),
        child: Text(
          title!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: titleFontColor ?? AppColors.whiteTemp,
                fontWeight: FontWeight.normal,
                fontFamily: 'ubuntu',
              ),
        ),
      ),
      onPressed: () {
        onBtnSelected!();
      },
    );
  }
}

// appbtn

// class AppBtn extends StatelessWidget {
//   final String? title;
//   final AnimationController? btnCntrl;
//   final Animation? btnAnim;
//   final VoidCallback? onBtnSelected;
//   final bool removeTopPadding;
//
//   const AppBtn({
//     super.key,
//     this.title,
//     this.btnCntrl,
//     this.btnAnim,
//     this.onBtnSelected,
//     this.removeTopPadding = false,
//   });
//
//
//   @override
//   Widget build(BuildContext context) {
//     final initialWidth = btnAnim!.value;
//     return AnimatedBuilder(
//       builder: (c, child) => _buildBtnAnimation(
//         c,
//         child,
//         initialWidth: initialWidth,
//       ),
//       animation: btnCntrl!,
//     );
//   }
//
//   Widget _buildBtnAnimation(BuildContext context, Widget? child,
//       {required double initialWidth}) {
//     return Padding(
//       padding: EdgeInsets.only(top: removeTopPadding ? 0 : 25),
//       child: CupertinoButton(
//         child: Container(
//           width: btnAnim!.value,
//           height: 45,
//           alignment: FractionalOffset.center,
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [AppColors.grad1Color, AppColors.grad2Color],
//               stops: [0, 1],
//             ),
//             borderRadius: BorderRadius.all(
//               Radius.circular(
//                 circularBorderRadius10,
//               ),
//             ),
//           ),
//           child: btnAnim!.value > 75.0
//               ? Text(
//                   title!,
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.titleLarge!.copyWith(
//                         color: AppColors.whiteTemp,
//                         fontWeight: FontWeight.normal,
//                         fontFamily: 'ubuntu',
//                       ),
//                 )
//               : const CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     AppColors.whiteTemp,
//                   ),
//                 ),
//         ),
//         onPressed: () {
//           //if it's not loading do the thing
//           if (btnAnim!.value == initialWidth) {
//             onBtnSelected!();
//           }
//         },
//       ),
//     );
//   }
// }
