import 'package:flutter/material.dart';

class DotIndicator extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final Color activeColor;
  final Color inactiveColor;
  final double dotSize;
  final double spacing;

  const DotIndicator({super.key, 
    required this.totalPages,
    required this.currentPage,
    this.activeColor = const Color(0xFF007BFF), // Default blue
    this.inactiveColor = const Color(0xFFCCCCCC), // Default light gray
    this.dotSize = 8.0,
    this.spacing = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: index == currentPage ? activeColor : inactiveColor,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
