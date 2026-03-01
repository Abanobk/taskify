import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../config/colors.dart';

class CircularProgressIndicatorCustom extends StatelessWidget {
  final bool? hasReachedMax;
  const CircularProgressIndicatorCustom({super.key,this.hasReachedMax});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Center(
        child: hasReachedMax!
            ? const Text('')
            :  SpinKitFadingCircle(
          color: AppColors.primary,
          size: 40.0,
        ),
      ),
    );
  }
}
