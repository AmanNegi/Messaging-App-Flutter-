import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

class TextFormBuilder extends StatelessWidget {
  String hintText;
  Function validator;
  Function onSaved;

  Icon icon;
  TextInputType keybordType;
  TextFormBuilder({
    this.hintText,
    this.validator,
    this.onSaved,
    this.icon,
    this.keybordType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: 1,
      keyboardType: keybordType,
      validator: validator,
      autocorrect: false,
      onSaved: onSaved,
      onChanged: (v){
        
      },
      style: GoogleFonts.aBeeZee(),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.aBeeZee(),
        prefixIcon: icon,
        border: OutlineInputBorder(
          borderSide: BorderSide(width: 1),
          gapPadding: 10.0,
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
