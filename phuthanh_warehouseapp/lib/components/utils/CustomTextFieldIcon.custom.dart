import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:show_hide_password/show_hide_password.dart';

class CustomTextFieldIcon extends StatefulWidget {
  final String? label;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool readOnly;
  final bool enabled;
  final bool isPassword;
  final double height;
  final double fontSize;
  final EdgeInsetsGeometry contentPadding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixWidget;

  const CustomTextFieldIcon({
    super.key,
    required this.label,
    required this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.hintText,
    this.keyboardType,
    this.readOnly = false,
    this.enabled = true,
    this.isPassword = false,
    this.height = 48,
    this.fontSize = 14,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    this.borderRadius = 8,
    this.backgroundColor,
    this.borderColor,
    this.onChanged,
    this.inputFormatters,
    this.onSubmitted, // 🔹 Thêm dòng này
    this.suffixWidget,
  });

  @override
  State<CustomTextFieldIcon> createState() => _CustomTextFieldIconState();
}

class _CustomTextFieldIconState extends State<CustomTextFieldIcon> {
  bool _isIconActive = false;

  void _toggleIcon() => setState(() => _isIconActive = !_isIconActive);

  InputDecoration _buildDecoration() {
    final iconColor = _isIconActive ? Colors.blue : Colors.grey;

    return InputDecoration(
      hintText: widget.hintText ?? widget.label,
      prefixIcon: widget.prefixIcon != null
          ? Icon(widget.prefixIcon, color: iconColor)
          : null,
      // ✅ Nếu có suffixWidget thì hiển thị nó, ngược lại mới dùng suffixIcon
      suffixIcon: widget.suffixWidget != null
          ? widget.suffixWidget
          : widget.suffixIcon != null
          ? IconButton(
              icon: Icon(widget.suffixIcon, color: iconColor),
              onPressed: () {
                _toggleIcon();
                widget.onSuffixIconPressed?.call();
              },
            )
          : null,
      contentPadding: widget.contentPadding,
      fillColor: widget.backgroundColor,
      filled: widget.backgroundColor != null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide(
          color: widget.borderColor ?? Colors.grey.shade400,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide(color: iconColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              widget.label!,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        SizedBox(
          height: widget.height,
          child: widget.isPassword
              ? ShowHidePassword(
                  passwordField: (hidePassword) => TextField(
                    showCursor: true,
                    controller: widget.controller,
                    obscureText: hidePassword,
                    keyboardType: widget.keyboardType,
                    readOnly: widget.readOnly,
                    enabled: widget.enabled,
                    style: TextStyle(fontSize: widget.fontSize),
                    decoration: _buildDecoration(),
                    onChanged: widget.onChanged,
                    inputFormatters: widget.inputFormatters,
                  ),
                )
              : TextField(
                  controller: widget.controller,
                  showCursor:
                      !widget.readOnly, // nếu bạn không muốn cursor nháy
                  keyboardType: widget.keyboardType,
                  readOnly: widget.readOnly,
                  enabled: widget.enabled,
                  enableInteractiveSelection: true, // ✅ cho phép copy
                  focusNode: widget.readOnly
                      ? FocusNode()
                      : null, // ✅ iOS cần để không crash
                  style: TextStyle(fontSize: widget.fontSize),
                  decoration: _buildDecoration(),
                  onChanged: widget.onChanged,
                  inputFormatters: widget.inputFormatters,
                  onSubmitted: widget.onSubmitted,
                ),
        ),
      ],
    );
  }
}
