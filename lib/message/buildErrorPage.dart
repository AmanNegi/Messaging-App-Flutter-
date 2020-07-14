import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:messaging_app_new/consts/theme.dart';

class BuildErrorPage extends StatelessWidget {
  final String errorText;
  double height;
  BuildErrorPage(this.errorText);

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    return ListView(
      children: <Widget>[
        Container(
          height: height * 0.897,
          color: AppTheme.mainColor,
          child: Stack(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  SvgPicture.asset(
                    "assets/search.svg",
                    color: AppTheme.mainColor,
                    allowDrawingOutsideViewBox: false,
                    colorBlendMode: BlendMode.color,
                  ),
                  Positioned.fill(
                      child: Container(
                    color: Colors.black.withOpacity(0.02),
                  ))
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    errorText,
                    style: TextStyle(
                        color: AppTheme.iconColor, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
