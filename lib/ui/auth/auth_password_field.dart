import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: TextFormField(
        obscureText: passwordVisible,
        validator: widget.validator,
        onSaved: widget.onSaved,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                passwordVisible = !passwordVisible;
              });
            },
            icon: Icon(
              passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.black,
            ),
          ),
          contentPadding: EdgeInsets.all(8.w),
          hintText: "Enter your password",
          hintStyle: TextStyle(color: Colors.black87),

          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54),
            borderRadius: BorderRadius.circular(10.r),
          ),

          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(10.r),
          ),
          labelStyle: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
