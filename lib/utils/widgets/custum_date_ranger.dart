import 'package:flutter/material.dart';


class CustomDateRangePickerIn extends StatefulWidget {
  const CustomDateRangePickerIn({super.key});

  @override
  State<CustomDateRangePickerIn> createState() => _CustomDateRangePickerInState();
}

class _CustomDateRangePickerInState extends State<CustomDateRangePickerIn> {
  DateTime? startDate;
  DateTime? endDate;

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Date Range Picker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  startDate == null ? 'Start Date' : 'Start Date: ${startDate!.toLocal()}',
                ),
                ElevatedButton(
                  onPressed: () => _selectStartDate(context),
                  child: const Text('Select Start Date'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  endDate == null ? 'End Date' : 'End Date: ${endDate!.toLocal()}',
                ),
                ElevatedButton(
                  onPressed: () => _selectEndDate(context),
                  child: const Text('Select End Date'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (startDate != null && endDate != null) {
                  // Handle selected date range
                  print('Selected range: ${startDate!.toLocal()} - ${endDate!.toLocal()}');
                }
              },
              child: const Text('Confirm Date Range'),
            ),
          ],
        ),
      ),
    );
  }
}
