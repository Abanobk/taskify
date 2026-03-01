import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class GlowIconButton extends StatelessWidget {
  final HeroIcons icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color glowColor;
  final Color selectedColor;
  final Color unselectedColor;

  const GlowIconButton({
    Key? key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.glowColor = const Color(0xFFffffff),
    required this.selectedColor,
    required this.unselectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: onTap,
        child: Center(
          child: isSelected
              ? Container(
            height: 30.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withAlpha(60),
                  blurRadius: 6.0,
                  spreadRadius: 0.0,
                  offset: const Offset(0.0, 3.0),
                ),
              ],
            ),
            child: HeroIcon(
              icon,
              style: HeroIconStyle.solid,
              color: selectedColor,
            ),
          )
              : HeroIcon(
            icon,
            style: HeroIconStyle.outline,
            color: unselectedColor,
          ),
        ),
      ),
    );
  }
}