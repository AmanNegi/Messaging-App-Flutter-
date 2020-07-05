import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messaging_app_new/consts/theme.dart';
import 'package:messaging_app_new/user/userInfoPage.dart';
import '../user/editProfile.dart';

class DrawerBuilder extends StatelessWidget {
  var height, width;
  @override
  Drawer build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Container(),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.3),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => EditProfile(),
                ),
              );
            },
            leading: Icon(
              Icons.edit,
              size: 30,
            ),
            title: Text("Edit profile"),
          ),
          Divider(),
          ListTile(
            title: Text("User info"),
            leading: Icon(Icons.info),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => UserInfo(),
                ),
              );
            },
          ),
          Divider(
            color: Colors.grey,
          ),
          SizedBox(
            height: 0.54 * height,
          ),
          Center(child: Text("@AsterJoules", style: GoogleFonts.oswald())),
          SizedBox(
            height: 10.0,
          )
        ],
      ),
    );
  }

  //_launchURL(String toMailId, String subject, String body) async {
  //  var url = 'mailto:$toMailId?subject=$subject&body=$body';
  //  if (await canLaunch(url)) {
  //   await launch(url);
  //   } else {
  //    throw 'Could not launch $url';
  //   }
  // }
}
