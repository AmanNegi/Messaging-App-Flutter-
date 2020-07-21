import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:messaging_app_new/consts/theme.dart';

class TextFormBuilder extends StatelessWidget {
  String hintText;
  Function validator;
  Function onSaved;
  TextEditingController controller;
  Widget suffixWidget;
  TextStyle textStyle;
  TextInputType keybordType;
  bool obscureText;
  TextFormBuilder(
      {this.hintText,
      this.validator,
      this.onSaved,
      this.controller,
      this.suffixWidget,
      this.textStyle,
      this.keybordType,
      this.obscureText});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30.0),
      child: Container(
        color: Colors.white,
        child: TextFormField(
          obscureText: obscureText != null ? obscureText : false,
          controller: controller,
          maxLines: 1,
          keyboardType: keybordType,
          // validator: validator,
          autocorrect: false,
          onSaved: onSaved,
          onChanged: (v) {},
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(20.0),
            fillColor: Colors.white,
            hintText: hintText,
            hintStyle: textStyle != null ? textStyle : TextStyle(),
            suffixIcon: suffixWidget != null ? suffixWidget : null,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
