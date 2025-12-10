import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';

class PersonalTextField extends StatefulWidget {
  final String? labelText;
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool enabled;

  const PersonalTextField({
    super.key,
    this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<PersonalTextField> createState() => _PersonalTextFieldState();
}

class _PersonalTextFieldState extends State<PersonalTextField> {
  late bool _isObscured;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: TextFormField(
        controller: widget.controller,
        obscureText: _isObscured,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
          labelText: widget.labelText,
          labelStyle: TextStyle(
            color: _isFocused ? AppColors.primary : Colors.grey.shade700,
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 15,
            fontFamily: 'Poppins',
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: _isFocused ? AppColors.primary : Colors.grey.shade600,
                  size: 22,
                )
              : null,
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _isObscured
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: _isFocused
                        ? AppColors.primary
                        : Colors.grey.shade600,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: widget.enabled ? Colors.white : Colors.grey.shade50,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
        ),
      ),
    );
  }
}
