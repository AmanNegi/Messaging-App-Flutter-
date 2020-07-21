import 'package:flutter/material.dart';
import '../consts/theme.dart';

class UseOfDataDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            color: Theme.of(context).cardColor,
            child: Column(
              children: <Widget>[
                AppBar(
                  elevation: 0,
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  title: Text(
                    "How do we use your data?",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: _buildText(),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildText() {
    return RichText(
      text: TextSpan(
          style: TextStyle(
              fontFamily: AppTheme.fontFamily, color: AppTheme.textColor),
          children: [
            TextSpan(text: 'The data we take from a user are : \n\n'),
            TextSpan(
              text: 'UserName\nE-mail\nProfile Photo\n\n',
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
            TextSpan(
                text:
                    'These data fields are general and no private information is gathered. The permissions this app uses are :\n\n'),
            TextSpan(
              text: '1) Internet\n2) Storage - to send images',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ]),
    );
  }
}
