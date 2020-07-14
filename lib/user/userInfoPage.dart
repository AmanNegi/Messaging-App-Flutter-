import 'package:flutter/material.dart';
import 'package:messaging_app_new/consts/theme.dart';
import 'package:messaging_app_new/user/UserRepo.dart';
import 'package:messaging_app_new/user/userInfoHelper.dart';
import '../data/sharedPrefs.dart';

class UserInfo extends StatefulWidget {
  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  String uid;

  _getUId() {
    dynamic val = sharedPrefs.getValueFromSharedPrefs("uid");
    this.uid = val;
  }

  @override
  void initState() {
    _getUId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor:AppTheme. mainColor,
        title: Text("User info"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: UserRepo().getReferenceSnapshots(uid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return UserInfoHelper(snapshot: snapshot.data,);
          } else if (snapshot.hasError ||
              snapshot == null ||
              snapshot.connectionState == ConnectionState.none) {
            return _errorBuilder();
          } else
            return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  _errorBuilder() {
    return Center(
      child: Text("An error Occured"),
    );
  }
}
