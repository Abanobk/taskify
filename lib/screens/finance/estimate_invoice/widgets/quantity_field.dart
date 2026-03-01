import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';

import '../../../../utils/widgets/custom_text.dart';
import '../../../../src/generated/i18n/app_localizations.dart';

class QuantityStepper extends StatefulWidget {
  final double initialValue;
  final double step;
  final ValueChanged<double> onChanged;
  final String label;
  final bool isRequired;
  final double minValue;
  final double maxValue;

  const QuantityStepper({
    Key? key,
    this.initialValue = 1,
    this.step = 0.25,
    required this.onChanged,
    this.label = 'QUANTITY',
    this.isRequired = true,
    this.minValue = 0,
    this.maxValue = double.infinity,
  }) : super(key: key);

  @override
  State<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper> {
  late TextEditingController _controller;
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = TextEditingController(text: _value.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    if (_value + widget.step <= widget.maxValue) {
      setState(() {
        _value += widget.step;
        _controller.text = _value.toStringAsFixed(2);
      });
      widget.onChanged(_value);
    }
  }

  void _decrement() {
    if (_value - widget.step >= widget.minValue) {
      setState(() {
        _value -= widget.step;
        _controller.text = _value.toStringAsFixed(2);
      });
      widget.onChanged(_value);
    }
  }

  void _updateValueFromInput(String input) {
    final newValue = double.tryParse(input);
    if (newValue != null) {
      if (newValue >= widget.minValue && newValue <= widget.maxValue) {
        setState(() {
          _value = newValue;
        });
        widget.onChanged(_value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.quantity,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16.sp,
                fontWeight: FontWeight.w700,
              ),
              Text(
                " *",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          )
        ),

        // Input field with buttons
        Container(
          height: 40.h, // Default to 40.h if height is not passed
          width: double.infinity,

          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Text input
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                  ),
                  textAlignVertical: TextAlignVertical.center, // Ensures vertical centering
                  decoration: const InputDecoration(
                    isDense: true, // Makes the field more compact
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Add vertical padding
                    border: InputBorder.none,
                  ),
                  onChanged: _updateValueFromInput,
                ),
              ),



              // Buttons
              Container(
                width: 40,

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Up arrow
                    Expanded(
                      child: InkWell(
                        onTap: _increment,
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              // bottom: BorderSide(color: Color(0xFFCBD5E1), width: 0.5),
                            ),
                            // color: Color(0xFFF8FAFC),
                          ),
                          child:  Center(
                            child: Icon(
                              Icons.keyboard_arrow_up,
                              size: 16,
                              color: Theme.of(context).colorScheme.textClrChange,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Down arrow
                    Expanded(
                      child: InkWell(
                        onTap: _decrement,
                        child: Container(
                          decoration: const BoxDecoration(
                            // color: Color(0xFFF8FAFC),
                          ),
                          child:  Center(
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: Theme.of(context).colorScheme.textClrChange,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Step indicator

      ],
    );
  }
}