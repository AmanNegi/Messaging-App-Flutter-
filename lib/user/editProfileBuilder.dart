import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app_new/user/UserRepo.dart';
import 'package:messaging_app_new/user/user.dart';
import 'storage.dart';
import '../consts/theme.dart';

class EditProfileBuilder extends StatefulWidget {
  final DocumentSnapshot snapshot;
  EditProfileBuilder({this.snapshot});
  @override
  _EditProfileBuilderState createState() => _EditProfileBuilderState();
}

class _EditProfileBuilderState extends State<EditProfileBuilder> {
  User user;
  var height, width;
  var userName, userEmail;
  var userImageUrl;
  var _formKey = GlobalKey<FormState>();
  var isLoading = false;

  @override
  void initState() {
    user = User.fromSnapshot(widget.snapshot);
    userName = user.userName;
    userEmail = user.email;
    userImageUrl = user.imageUrl;
    super.initState();

    storageService.imageUrl.listen((data) {
      print(data);
      setState(() {
        userImageUrl = data;
      });
    });
    storageService.editProfileIsLoading.listen((value) {
      print(
          '------------------- value of image is loading [$value] ------------------ ');
      setState(() {
        isLoading = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ListView(
        children: <Widget>[
          _buildTopWidget(),
          _buildForm(),
        ],
      ),
    );
  }

  _buildForm() {
    return Container(
      height: 0.525 * height,
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("UserName")),
                  ),
                  TextFormField(
                    validator: (a) {
                      if (a.length == 0) {
                        return "Enter a valid name";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      setState(() {
                        this.userName = value;
                      });
                    },
                    initialValue: userName,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: ButtonTheme(
                minWidth: width * 0.9,
                height: height * 0.06,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  color: accentColor,
                  child: Text(
                    " Save Details ",
                    style: TextStyle(color: buttonTextColor),
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      User newUser = User(
                          email: user.email,
                          userName: userName,
                          imageUrl: userImageUrl,
                          uid: user.uid);
                      print(" in onPressed val: " + newUser.userName);
                      UserRepo().updateUser(newUser);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildTopWidget() {
    return Container(
      // color: Colors.red,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              color: mainColor.withOpacity(0.3),
              height: 0.22 * height,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: GestureDetector(
                onTap: () async {
                  var a = await storageService.pickFile();
                  if (a != null) {
                    storageService.uploadFile(a);
                  }
                },
                child: Container(
                  constraints: BoxConstraints(maxHeight: 200, maxWidth: 200),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: CircleAvatar(
                          radius: 100,
                          backgroundImage: NetworkImage(userImageUrl),
                          child: Visibility(
                            visible: isLoading,
                            child: CircularProgressIndicator(),
                            maintainAnimation: true,
                            maintainState: true,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 5,
                        bottom: 5,
                        child: FloatingActionButton(
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            var a = await storageService.pickFile();
                            if (a != null) {
                              storageService.uploadFile(a);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
