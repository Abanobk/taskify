import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Add this dependency


class NumberSpinner extends StatefulWidget {
  final double initialValue;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double> onChanged;
  final bool isDaysField; // New property to identify if this is for days

  const NumberSpinner({
    Key? key,
    this.initialValue = 0.0,
    this.min = 0.0,
    this.max = 100.0,
    this.step = 0.5,
    this.isDaysField = false, // Default to false
    required this.onChanged,
  }) : super(key: key);

  @override
  State<NumberSpinner> createState() => _NumberSpinnerState();
}

class _NumberSpinnerState extends State<NumberSpinner> {
  late double currentValue;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;
    _controller = TextEditingController(
      text: currentValue % 1 == 0
          ? currentValue.toInt().toString()
          : currentValue.toString(),
    );
  }

  void _showNegativeValueToast() {
    Fluttertoast.showToast(
      msg: "Negative values are not allowed",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showExceedsDaysToast() {
    Fluttertoast.showToast(
      msg: "Days cannot exceed 31",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _increment() {
    setState(() {
      print("fghjk $currentValue");
      print("fghjk ${widget.step}");
      print("fghjk ${widget.max}");
      if (currentValue + widget.step <= widget.max) {
        print("fghjk effd ");
        currentValue += widget.step;
        _controller.text = currentValue % 1 == 0
            ? currentValue.toInt().toString()
            : currentValue.toString();

        widget.onChanged(currentValue);
      }
    });
  }

  void _decrement() {
    setState(() {
      if (currentValue - widget.step >= widget.min) {
        currentValue -= widget.step;
        _controller.text = currentValue % 1 == 0
            ? currentValue.toInt().toString()
            : currentValue.toString();

        widget.onChanged(currentValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40.h,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) {
          // Check for negative sign or negative values immediately
          if (value.contains('-') || value.startsWith('-')) {
            _showNegativeValueToast();
            // Reset to previous valid value
            _controller.text = currentValue % 1 == 0
                ? currentValue.toInt().toString()
                : currentValue.toString();
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
            return;
          }

          final parsed = double.tryParse(value);

          // Additional check for parsed negative values (safety net)
          if (parsed != null && parsed < 0) {
            _showNegativeValueToast();
            // Reset to previous valid value
            _controller.text = currentValue % 1 == 0
                ? currentValue.toInt().toString()
                : currentValue.toString();
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
            return;
          }

          // Check for days field exceeding 31
          if (widget.isDaysField && parsed != null && parsed > 31) {
            _showExceedsDaysToast();
            // Reset to previous valid value
            _controller.text = currentValue % 1 == 0
                ? currentValue.toInt().toString()
                : currentValue.toString();
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
            return;
          }

          if (parsed != null &&
              parsed >= widget.min &&
              parsed <= widget.max) {
            setState(() {
              currentValue = parsed;
              widget.onChanged(currentValue);
            });
          }
        },
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: InputBorder.none,
          suffixIcon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _increment,
                child: Icon(Icons.arrow_drop_up, size: 15.sp),
              ),
              GestureDetector(
                onTap: _decrement,
                child: Icon(Icons.arrow_drop_down, size: 15.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}