import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:messaging_app_new/user/UserRepo.dart';
import 'package:messaging_app_new/user/editProfileBuilder.dart';
import 'storage.dart';
import '../data/strings.dart';
import '../data/sharedPrefs.dart';
import '../consts/theme.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  var height, width;
  String uid;

  @override
  void initState() {
    _getUId();
    super.initState();
  }

  _getUId() {
    dynamic val = sharedPrefs.getValueFromSharedPrefs("uid");
    setState(() {
      this.uid = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor:AppTheme. mainColor,
          centerTitle: true,
          title: Text("Edit profile"),
        ),
        body: StreamBuilder(
          stream: UserRepo().getReferenceSnapshots(uid),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return EditProfileBuilder(snapshot: snapshot.data);
            } else if (snapshot.hasError ||
                snapshot == null ||
                snapshot.connectionState == ConnectionState.none) {
              return _errorBuilder();
            } else
              return Center(child: CircularProgressIndicator());
          },
        ));
  }

  _errorBuilder() {
    return Center(
      child: Text("An error Occured"),
    );
  }
}
