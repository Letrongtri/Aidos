import 'dart:developer';

import 'package:ct312h_project/ui/auth/login_form.dart';
import 'package:ct312h_project/ui/auth/signup_form.dart';
import 'package:ct312h_project/ui/shared/dialog_utils.dart';
import 'package:ct312h_project/viewmodels/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AuthMode { signup, login }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final _isSubmitting = ValueNotifier<bool>(false);
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
    'username': '',
  };

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      _formKey.currentState!.reset();
      setState(() {
        _authMode = AuthMode.signup;
      });
    } else {
      _formKey.currentState!.reset();
      setState(() {
        _authMode = AuthMode.login;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    _isSubmitting.value = true;

    try {
      if (_authMode == AuthMode.login) {
        // Log user in
        await context.read<AuthManager>().login(
          _authData['email']!,
          _authData['password']!,
        );
      } else {
        // Sign user up
        await context.read<AuthManager>().signup(
          _authData['email']!,
          _authData['username']!,
          _authData['password']!,
        );
        _switchAuthMode();
      }
    } catch (error) {
      log('$error');
      debugPrint(error.toString());
      if (mounted) {
        showErrorDialog(context, error.toString());
      }
    }

    _isSubmitting.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Center(child: Image.asset('assets/images/logo.png', width: 80)),

              if (_authMode == AuthMode.signup)
                SignupForm(
                  formKey: _formKey,
                  onSavedField: (key, value) {
                    _authData[key] = value;
                  },
                ),
              if (_authMode == AuthMode.login)
                LoginForm(
                  formKey: _formKey,
                  onSavedField: (key, value) {
                    _authData[key] = value;
                  },
                ),
              SizedBox(height: 20),

              ValueListenableBuilder<bool>(
                valueListenable: _isSubmitting,
                builder: (context, isSubmitting, child) {
                  if (isSubmitting) {
                    return const CircularProgressIndicator();
                  }
                  return _buildSubmitButton();
                },
              ),

              Spacer(),
              Divider(),
              _buildAuthModeSwitch(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthModeSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _authMode == AuthMode.login
              ? "Don't have an account yet?"
              : "Already have an account?",
          style: TextStyle(color: Colors.black87),
        ),
        TextButton(
          onPressed: _switchAuthMode,
          child: Text(
            _authMode == AuthMode.login ? 'SIGN UP' : 'LOG IN',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  SizedBox _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
        child: Text(
          _authMode == AuthMode.login ? 'LOGIN' : 'SIGN UP',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
