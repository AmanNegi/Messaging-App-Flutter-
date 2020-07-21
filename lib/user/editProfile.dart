import 'package:flutter/material.dart';

import 'package:messaging_app_new/user/UserRepo.dart';
import 'package:messaging_app_new/user/editProfileBuilder.dart';
import '../data/sharedPrefs.dart';
import '../consts/theme.dart';
import 'package:mdi/mdi.dart';
import '../Layout/useOfDataDialog.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  var height, width;
  String uid;
  var scaffoldKey = GlobalKey<ScaffoldState>();

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
        key: scaffoldKey,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            "Edit profile",
            style: TextStyle(color: AppTheme.textColor),
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.info,
                color: AppTheme.iconColor,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => UseOfDataDialog(),
                );
              },
            )
          ],
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Mdi.chevronLeft,
              color: AppTheme.iconColor,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: StreamBuilder(
          stream: UserRepo().getReferenceSnapshots(uid),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return EditProfileBuilder(
                  snapshot: snapshot.data, scaffoldKey: scaffoldKey);
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
