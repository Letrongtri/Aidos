import 'package:flutter/material.dart';

class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({super.key, this.onSaved, this.validator});

  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextFormField(
        obscureText: passwordVisible,
        validator: widget.validator,
        onSaved: widget.onSaved,

        style: textTheme.bodyLarge,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                passwordVisible = !passwordVisible;
              });
            },
            icon: Icon(
              passwordVisible ? Icons.visibility : Icons.visibility_off,

              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          contentPadding: const EdgeInsets.all(16),
          hintText: "Enter your password",

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
