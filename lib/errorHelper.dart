import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ErrorHelper {
  String errorText;

  ErrorHelper({this.errorText});

  showErrorText() {
    Fluttertoast.showToast(
      msg: errorText,
      timeInSecForIosWeb: 2,
    );
    print("Error Text :- " + errorText);
  }
}
