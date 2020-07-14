import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app_new/user/UserRepo.dart';
import 'package:messaging_app_new/user/user.dart';
import 'storage.dart';
import '../consts/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  var isImageLoading = false;
  var isLoading = false;
  UserRepo userRepo = UserRepo();
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
        userRepo.updateUser(User(
            email: user.email,
            imageUrl: userImageUrl,
            reference: user.reference,
            uid: user.uid,
            userName: user.userName));
      });
    });
    
    storageService.editProfileIsLoading.listen((value) {
      print(
          '------------------- value of image is loading [$value] ------------------ ');
      setState(() {
        isImageLoading = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: isLoading ? 0.6 : 1.0,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: ListView(
              children: <Widget>[
                _buildTopWidget(),
                _buildForm(),
              ],
            ),
          ),
        ),
        Visibility(
          visible: isLoading,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
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
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextFormField(
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
                        decoration: InputDecoration()),
                  ),
                ],
              ),
            ),
            Spacer(),
            _buildButton(),
          ],
        ),
      ),
    );
  }

  _buildButton() {
    return OrientationBuilder(
      builder: (context, orientation) {
        return ButtonTheme(
          minWidth: width * 0.9,
          height: orientation == Orientation.landscape
              ? height * 0.5
              : height * 0.07,
          child: RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            color: AppTheme.accentColor,
            child: Text(
              " Save Details ",
              style: TextStyle(color: AppTheme.buttonTextColor),
            ),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                User newUser = User(
                    email: user.email,
                    userName: userName,
                    imageUrl: userImageUrl,
                    uid: user.uid);
                print(" in onPressed val: " + newUser.userName);
                setState(() {
                  isLoading = true;
                });
                await userRepo.updateUser(newUser);
                Fluttertoast.showToast(msg: "Updated Data sucessfully");
                setState(() {
                  isLoading = false;
                });
              }
            },
          ),
        );
      },
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
              color: AppTheme.mainColor.withOpacity(0.3),
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
                            visible: isImageLoading,
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
