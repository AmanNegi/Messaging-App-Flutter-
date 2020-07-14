import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:messaging_app_new/consts/theme.dart';

class TextFormBuilder extends StatelessWidget {
  String hintText;
  Function validator;
  Function onSaved;
  TextEditingController controller;
  Icon icon;
  TextInputType keybordType;
  TextFormBuilder({
    this.hintText,
    this.validator,
    this.onSaved,
    this.icon,
    this.controller,
    this.keybordType,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30.0),
      child: Container(
        color: Colors.white,
        child: TextFormField(
          controller: controller,
          maxLines: 1,
          keyboardType: keybordType,
          // validator: validator,
          autocorrect: false,
          onSaved: onSaved,
          onChanged: (v) {},
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(20.0),
            fillColor: Colors.white,
            hintText: hintText,
            hintStyle: TextStyle(
              fontFamily: AppTheme.fontFamily,
            ),
            prefixIcon: icon,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
