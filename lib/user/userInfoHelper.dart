import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clipboard_manager/flutter_clipboard_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messaging_app_new/Layout/infoDialog.dart';
import 'package:messaging_app_new/user/user.dart';
import '../consts/theme.dart';

class UserInfoHelper extends StatefulWidget {
  final DocumentSnapshot snapshot;
  UserInfoHelper({this.snapshot});
  @override
  _UserInfoHelperState createState() => _UserInfoHelperState();
}

class _UserInfoHelperState extends State<UserInfoHelper> {
  User user;
  var height, width;

  @override
  void initState() {
    user = User.fromSnapshot(widget.snapshot);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return ListView(
      children: <Widget>[
        _buildTopWidget(),
        _buildRestPage(),
        SizedBox(
          height: 0.15 * height,
        ),
        _buildBottomPage(),
      ],
    );
  }

  _buildBottomPage() {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Container(
        height: 0.2 * height,
        child: Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          color: AppTheme.mainColor.withOpacity(0.3),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => InfoDialog());
                  },
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: FloatingActionButton(
                  child: Icon(Icons.content_copy),
                  onPressed: () {
                    FlutterClipboardManager.copyToClipBoard(user.uid)
                        .then((result) {
                      final snackBar = SnackBar(
                        content: Text('Copied to Clipboard'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {},
                        ),
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                    });
                  },
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectableText(
                    user.uid,
                    style: TextStyle(
                        fontSize: 25, fontFamily: AppTheme.fontFamily),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildRestPage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                  blurRadius: 4.0,
                  color: Colors.black38.withOpacity(0.1),
                  offset: Offset(0.0, 3.0),
                  spreadRadius: 3.0),
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(user.imageUrl),
                radius: 35,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Center(
                child: Text(user.userName),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildTopWidget() {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            color: AppTheme.mainColor.withOpacity(0.3),
            height: 0.22 * height,
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: CircleAvatar(
              radius: 100.0,
              backgroundImage: NetworkImage(user.imageUrl),
            ),
          ),
        ),
      ],
    );
  }
}
