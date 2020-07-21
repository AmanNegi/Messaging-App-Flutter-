import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mdi/mdi.dart';
import 'package:messaging_app_new/Layout/themeSettingsPage.dart';
import 'package:messaging_app_new/consts/theme.dart';
import 'package:messaging_app_new/message/imageFullScreen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../user/editProfile.dart';
import '../mainRepo.dart';
import '../user/user.dart';
import '../data/sharedPrefs.dart';
import '../Layout/signOutConfirmationDialog.dart';
import '../appData.dart';

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
    setUser(user);
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
          _buildTopImage(context),
          Divider(),
          _buildEditProfile(context),
          Divider(),
          _buildThemeSettingsTile(context),
          Divider(),
          ListTile(
            leading: Icon(
              Mdi.logout,
            ),
            title: Text("Sign out"),
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => SignOutConfirmationDialog(),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Mdi.messageAlertOutline),
            title: Text('Want an feature? Suggest the developer'),
            onTap: () {
              _launchURL("asterJoules@gmail.com", "Suggestion of an feature",
                  "Enter here");
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Mdi.bugCheckOutline),
            title: Text('Found an issue? Ping the developer'),
            subtitle:
                Text('Include screenshot with a well detailed description'),
            onTap: () {
              _launchURL("asterJoules@gmail.com", "Suggestion of an feature",
                  "Enter here");
            },
          ),
          Divider(),
          _buildAboutTile(context),
        ],
      ),
    );
  }

  _buildAboutTile(BuildContext context) {
    return ListTile(
      leading: Icon(Mdi.informationOutline),
      title: Text('About'),
      onTap: () {
        showAboutDialog(
            context: context,
            applicationIcon: Image.asset(
              'assets/msg.png',
              height: 50.0,
              width: 50.0,
            ),
            children: [
              SizedBox(
                height: 30.0,
              ),
              Text(
                  "Copyright 2020 AsterJoules. All rights reserved.* Redistributions of source code must retain the above copyrightnotice, this list of conditions and the following disclaimer.\n\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS")
            ],
            applicationName: 'Messaging app',
            applicationVersion: '1.0.0 (Debug version)',
            applicationLegalese: '@2020 AsterJoules');
      },
    );
  }

  ListTile _buildThemeSettingsTile(BuildContext context) {
    return ListTile(
      title: Text(
        "Theme settings",
        style: TextStyle(color: AppTheme.textColor),
      ),
      leading: Icon(
        MdiIcons.themeLightDark,
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ThemeSettingsPage(),
        ));
      },
    );
  }

  ListTile _buildEditProfile(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => EditProfile(),
          ),
        );
      },
      leading: Icon(
        Mdi.circleEditOutline,
      ),
      title: Text(
        "Edit profile",
        style: TextStyle(color: AppTheme.textColor),
      ),
    );
  }

  Container _buildTopImage(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      height: 0.2 * height,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                  height: 0.12 * height,
                  width: double.infinity,
                  color: Theme.of(context).cardColor),
              Container(
                height: 0.08 * height,
                width: double.infinity,
                color: Theme.of(context).canvasColor,
              ),
            ],
          ),
          Positioned(
            left: 0.325 * width,
            top: 0.0925 * height,
            child: Text(
              user != null ? user.userName : '',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Positioned(
            top: 0.05 * height,
            left: 0.05 * width,
            child: GestureDetector(
              onTap: () {
                if (user != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ImageFullScreen(user.imageUrl)));
                }
              },
              child: _buildUserImage(context),
            ),
          ),
        ],
      ),
    );
  }

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _buildUserImage(BuildContext context) {
    return user != null
        ? ValueListenableBuilder(
            valueListenable: userData,
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(120.0),
                child: Container(
                  height: 0.125 * height,
                  width: 0.125 * height,
                  color: AppTheme.mainColor,
                  child: CachedNetworkImage(
                      fadeInDuration: Duration(microseconds: 100),
                      imageUrl: value != null ? value.imageUrl : " ",
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          Icon(Mdi.alert, color: AppTheme.iconColor),
                      placeholder: (context, url) => Shimmer.fromColors(
                          child: Container(
                            color: Colors.red,
                          ),
                          baseColor: AppTheme.shimmerBaseColor,
                          highlightColor: AppTheme.shimmerEndingColor)),
                ),
              );
            },
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(120.0),
            child: Shimmer.fromColors(
              baseColor: AppTheme.shimmerBaseColor,
              highlightColor: AppTheme.shimmerEndingColor,
              child: Container(
                height: 0.125 * height,
                width: 0.125 * height,
                color: Colors.red,
              ),
            ),
          );
  }
}
