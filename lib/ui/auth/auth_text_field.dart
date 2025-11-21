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
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextFormField(
        validator: validator,
        onSaved: onSaved,
        keyboardType: keyboardType,
        cursorColor: theme.colorScheme.onPrimary,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(8),
          hintText: hint,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
          hintStyle: TextStyle(color: Colors.black87),
        ),
      ),
    );
  }
}
