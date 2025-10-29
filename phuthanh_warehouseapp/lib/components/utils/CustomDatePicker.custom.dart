import 'package:flutter/material.dart';

class CustomDatePicker extends StatefulWidget {
  final String label;
  final DateTime? initialDate;
  final ValueChanged<DateTime> onChanged;
  final bool readOnly; // ✅ thay cho enabled

  final IconData? rightIcon;
  final VoidCallback? onRightIconTap;
  final Color? rightIconColor;
  final String? rightIconTooltip;

  const CustomDatePicker({
    Key? key,
    required this.label,
    required this.onChanged,
    this.initialDate,
    this.readOnly = false, // ✅ mặc định có thể chọn
    this.rightIcon,
    this.onRightIconTap,
    this.rightIconColor,
    this.rightIconTooltip,
  }) : super(key: key);

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late TextEditingController _controller;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    _controller = TextEditingController(
      text: selectedDate != null
          ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    if (widget.readOnly) return;

    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
      widget.onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isReadOnly = widget.readOnly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _controller,
          readOnly: true, // luôn không cho nhập bàn phím
          decoration: InputDecoration(
            filled: true,
            fillColor: isReadOnly ? Colors.grey.shade200 : Colors.white,
            border: const OutlineInputBorder(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: isReadOnly ? null : _pickDate,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.calendar_today,
                      color: isReadOnly ? Colors.grey : Colors.blue,
                    ),
                  ),
                ),
                if (widget.rightIcon != null)
                  IconButton(
                    icon: Icon(
                      widget.rightIcon,
                      color:
                          isReadOnly ? Colors.grey : (widget.rightIconColor ?? Colors.black),
                    ),
                    tooltip: widget.rightIconTooltip,
                    onPressed: isReadOnly ? null : widget.onRightIconTap,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
