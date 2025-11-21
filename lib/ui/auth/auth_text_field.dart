import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    this.hint = '',
    this.onSaved,
    this.validator,
    this.keyboardType,
  });

  final String hint;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextFormField(
        validator: validator,
        onSaved: onSaved,
        keyboardType: keyboardType,

        style: textTheme.bodyLarge,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16),
          hintText: hint,

          hintStyle: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          filled: true,

          fillColor: colorScheme.surfaceContainerHighest,

          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),

          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.secondary),
            borderRadius: BorderRadius.circular(12),
          ),

          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.error),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.error),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
