import 'package:flutter/material.dart';
import '../../config/colors.dart';

class CustomCheckbox extends StatefulWidget {
  final bool isSelected;
  final ValueChanged<bool?>? onChanged; // Correct type

  const CustomCheckbox({super.key,required this.isSelected,required this.onChanged});

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  @override
  Widget build(BuildContext context) {
    return     TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300),
        tween: Tween<double>(begin: 1.0, end: widget.isSelected ? 1.5 : 1.3),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(
              scale: scale, // Smoothly animates scale without adding space
              child: Checkbox.adaptive(
                  activeColor: AppColors.primary,
                  checkColor: Colors.white,
                  side: BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  value: widget.isSelected,
                  onChanged: widget.onChanged));});
  }
}
