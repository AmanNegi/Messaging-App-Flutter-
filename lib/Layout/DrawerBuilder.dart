import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:messaging_app_new/Layout/themeSettingsPage.dart';
import 'package:messaging_app_new/consts/theme.dart';
import 'package:messaging_app_new/message/imageFullScreen.dart';
import 'package:messaging_app_new/user/userInfoPage.dart';
import '../user/editProfile.dart';
import '../mainRepo.dart';
import '../user/user.dart';
import '../data/sharedPrefs.dart';

class DrawerBuilder extends StatefulWidget {
  @override
  _DrawerBuilderState createState() => _DrawerBuilderState();
}

class _DrawerBuilderState extends State<DrawerBuilder> {
  var height, width;
  User user;
  bool isLoading = true;
  _getCurrentUser() async {
    setState(() {
      isLoading = true;
    });
    print("getting user ");
    user = await mainRepo
        .getUserFromUid(sharedPrefs.getValueFromSharedPrefs('uid'));

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    _getCurrentUser();
    super.initState();
  }

  @override
  Drawer build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Drawer(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: <Widget>[
                Container(
                  color: Theme.of(context).cardColor,
                  height: 0.3 * height,
                  width: double.infinity,
                ),
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ImageFullScreen(user.imageUrl)));
                    },
                    child: Hero(
                      tag: isLoading ? " " : "drawerImage" + user.imageUrl,
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(isLoading ? "" : user.imageUrl),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
              color: AppTheme.iconColor,
              size: 30,
            ),
            title: Text(
              "Edit profile",
              style: TextStyle(color: AppTheme.textColor),
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              "User info",
              style: TextStyle(color: AppTheme.textColor),
            ),
            leading: Icon(
              Icons.info,
              color: AppTheme.iconColor,
            ),
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
          ListTile(
            title: Text(
              "Theme settings",
              style: TextStyle(color: AppTheme.textColor),
            ),
            leading: Icon(
              MdiIcons.themeLightDark,
              color: AppTheme.iconColor,
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ThemeSettingsPage(),
              ));
            },
          ),
          Divider(),
          SizedBox(
            height: 0.40 * height,
          ),
        ],
      ),
    );
  }
}
