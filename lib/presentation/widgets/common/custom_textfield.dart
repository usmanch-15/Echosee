// lib/presentation/widgets/common/custom_textfield.dart
import 'package:flutter/material.dart';
import 'package:echo_see_companion/core/constants/app_colors.dart';
import 'package:echo_see_companion/core/constants/app_styles.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final bool enabled;
  final bool autoFocus;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onSuffixIconTap;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final Color? fillColor;
  final bool filled;
  final String? errorText;
  final bool showErrorBorder;

  const CustomTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.enabled = true,
    this.autoFocus = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onSuffixIconTap,
    this.contentPadding,
    this.border,
    this.fillColor,
    this.filled = true,
    this.errorText,
    this.showErrorBorder = false,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _showPassword = false;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            widget.labelText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
        ),

        // Text Field
        TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText && !_showPassword,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          autofocus: widget.autoFocus,
          validator: widget.validator,
          onChanged: (value) {
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
            if (_hasError) {
              setState(() => _hasError = false);
            }
          },
          onFieldSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
              widget.prefixIcon,
              color: _hasError
                  ? Colors.red
                  : Theme.of(context).iconTheme.color,
            )
                : null,
            suffixIcon: _buildSuffixIcon(),
            contentPadding: widget.contentPadding ??
                EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: widget.maxLines > 1 ? 16 : 0,
                ),
            filled: widget.filled,
            fillColor: widget.fillColor ??
                Theme.of(context).colorScheme.surface.withOpacity(0.8),
            border: widget.border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  borderSide: BorderSide.none,
                ),
            enabledBorder: widget.border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  borderSide: BorderSide(
                    color: _hasError
                        ? Colors.red
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: BorderSide(
                color: _hasError
                    ? Colors.red
                    : AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            errorText: widget.errorText,
            errorStyle: const TextStyle(
              fontSize: 12,
              color: Colors.red,
            ),
          ),
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        ),

        // Error message (if any)
        if (widget.errorText != null && widget.errorText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 8.0),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) {
      return GestureDetector(
        onTap: widget.onSuffixIconTap,
        child: Icon(
          widget.suffixIcon,
          color: Theme.of(context).iconTheme.color,
        ),
      );
    }

    if (widget.obscureText) {
      return GestureDetector(
        onTap: () {
          setState(() => _showPassword = !_showPassword);
        },
        child: Icon(
          _showPassword ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey[600],
        ),
      );
    }

    return null;
  }
}

// Email-specific TextField
class EmailTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const EmailTextField({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: 'Email Address',
      hintText: 'Enter your email',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: validator ??
              (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
      onChanged: onChanged,
    );
  }
}

// Password-specific TextField
class PasswordTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String labelText;
  final String hintText;
  final bool showStrengthIndicator;

  const PasswordTextField({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
    this.labelText = 'Password',
    this.hintText = 'Enter your password',
    this.showStrengthIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icons.lock_outline,
      obscureText: true,
      validator: validator ??
              (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
      onChanged: onChanged,
    );
  }
}