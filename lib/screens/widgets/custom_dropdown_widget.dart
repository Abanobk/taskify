import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> options;
  final String hint;
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;

  const CustomDropdown({super.key, 
    required this.options,
    this.hint = 'Select an option',
    this.selectedValue,
    this.onChanged,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final LayerLink _layerLink = LayerLink();
  final _overlayEntries = <OverlayEntry>[];
  bool _isDropdownOpen = false;

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      for (var entry in _overlayEntries) {
        entry.remove();
      }
      _overlayEntries.clear();
    } else {
      _showDropdown();
    }
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  void _showDropdown() {
    final overlay = Overlay.of(context);
    final size = context.size!;
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          child: Material(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.options.map((option) {
                return ListTile(
                  title: Text(option),
                  onTap: () {
                    widget.onChanged?.call(option);
                    _toggleDropdown();
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
    _overlayEntries.add(overlayEntry);
    overlay.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.selectedValue ?? widget.hint,
              style: TextStyle(color: widget.selectedValue == null ? Colors.grey : Colors.black),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
