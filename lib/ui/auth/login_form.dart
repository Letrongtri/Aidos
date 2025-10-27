import 'package:ct312h_project/ui/auth/auth_password_field.dart';
import 'package:ct312h_project/ui/auth/auth_text_field.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.formKey,
    required this.onSavedField,
  });

  final GlobalKey<FormState> formKey;
  final Function(String key, String value) onSavedField;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AuthTextField(
            hint: "Enter your email",
            keyboardType: TextInputType.emailAddress,
            onSaved: (value) {
              onSavedField('email', value!);
            },
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Invalid email address';
              }
              return null;
            },
          ),
          AuthPasswordField(
            onSaved: (value) {
              onSavedField('password', value!);
            },
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'Password is too short';
              }
              return null;
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                  "Forgot password",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
