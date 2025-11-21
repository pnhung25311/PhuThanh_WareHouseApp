import 'package:flutter/material.dart';

class CustomDateTimePicker extends StatefulWidget {
  final String label;
  final DateTime? initialDate;
  final ValueChanged<DateTime> onChanged;
  final bool readOnly;

  final IconData? rightIcon;
  final VoidCallback? onRightIconTap;
  final Color? rightIconColor;
  final String? rightIconTooltip;
  final BoxDecoration? rightIconDecoration;
  final EdgeInsetsGeometry? rightIconPadding;
  final double? rightIconSize;

  const CustomDateTimePicker({
    Key? key,
    required this.label,
    required this.onChanged,
    this.initialDate,
    this.readOnly = false,
    this.rightIcon,
    this.onRightIconTap,
    this.rightIconColor,
    this.rightIconTooltip,
    this.rightIconDecoration,
    this.rightIconPadding,
    this.rightIconSize,
  }) : super(key: key);

  @override
  State<CustomDateTimePicker> createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker> {
  late TextEditingController _controller;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    _controller = TextEditingController(
      text: selectedDate != null ? _formatDate(selectedDate!) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String _formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/"
        "${dt.month.toString().padLeft(2, '0')}/"
        "${dt.year}";
  }

  Future<void> _pickDate() async {
    if (widget.readOnly) return;

    final DateTime now = DateTime.now();
    final DateTime initial = selectedDate ?? now;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
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

    if (pickedDate == null) return;

    setState(() {
      selectedDate = pickedDate;
      _controller.text = _formatDate(pickedDate);
    });

    widget.onChanged(pickedDate);
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
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: isReadOnly ? Colors.grey.shade200 : Colors.white,
            border: const OutlineInputBorder(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: isReadOnly ? null : _pickDate,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.calendar_today, color: Colors.blue),
                  ),
                ),
                if (widget.rightIcon != null)
                  GestureDetector(
                    onTap: isReadOnly ? null : widget.onRightIconTap,
                    child: Container(
                      padding:
                          widget.rightIconPadding ?? const EdgeInsets.all(4),
                      decoration: widget.rightIconDecoration,
                      child: Icon(
                        widget.rightIcon,
                        size: widget.rightIconSize ?? 24,
                        color: isReadOnly
                            ? Colors.grey
                            : (widget.rightIconColor ?? Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
