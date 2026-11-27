import 'package:flutter/material.dart';
import 'package:serba_jaya_mobile/app/theme/app_theme.dart';

/// Profile input from Figma 168:2491 and 439:1493.
class ProfileField extends StatelessWidget {
  const ProfileField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.enabled = true,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.lines = 1,
    this.validator,
    this.onSaved,
    this.onChanged,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int lines;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onChanged;

  static const _border = OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFE5E7EB)),
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const labelStyle = TextStyle(
    fontFamily: 'AuthRoboto',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Color(0xFF202329),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 6,
    children: [
      ExcludeSemantics(child: Text(label, style: labelStyle)),
      Semantics(
        label: label,
        child: TextFormField(
          controller: controller,
          initialValue: initialValue,
          enabled: enabled,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLines: lines,
          validator: validator,
          onSaved: onSaved,
          onChanged: onChanged,
          style: AppTypography.authInput.copyWith(
            color: enabled ? AppColors.authText : AppColors.authSecondary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.authInput.copyWith(
              color: AppColors.authSecondary,
            ),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF0F1F3),
            constraints: BoxConstraints(minHeight: lines == 1 ? 50 : 74),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 15,
            ),
            border: _border,
            enabledBorder: _border,
            disabledBorder: _border,
            focusedBorder: _border.copyWith(
              borderSide: const BorderSide(color: AppColors.authPrimary),
            ),
          ),
        ),
      ),
    ],
  );
}
