import 'package:flutter/material.dart';
import 'package:messaging_app_new/consts/theme.dart';

class InfoDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
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
                    "U-id",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text(
                      "This a unique id to uniquely identify users. Share the U-id to your friends so that they can find you. UserName can be duplicated however the U-id is always unique."),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
