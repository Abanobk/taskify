import 'package:flutter/material.dart';


import '../../config/colors.dart';

class AppBarAction extends StatelessWidget {
  const AppBarAction({
    super.key,
    required this.icondata,
    required this.appBarFun,
  });


  final IconData icondata;
  final Function appBarFun;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.5),
        child: IconButton(
          icon: Icon(icondata),
          color: Colors.white,
          onPressed: () => appBarFun(),
        ),
      ),
    );
  }
}