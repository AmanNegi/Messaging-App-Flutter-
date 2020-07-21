import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app_new/user/UserRepo.dart';
import 'package:messaging_app_new/user/user.dart';
import 'storage.dart';
import '../consts/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../appData.dart';

class EditProfileBuilder extends StatefulWidget {
  final DocumentSnapshot snapshot;
  final GlobalKey<ScaffoldState> scaffoldKey;
  EditProfileBuilder({this.snapshot, this.scaffoldKey});
  @override
  _EditProfileBuilderState createState() => _EditProfileBuilderState();
}

class _EditProfileBuilderState extends State<EditProfileBuilder> {
  User user;

  var height, width;
  var userName, userEmail;
  String userImageUrl;

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
        User userObj = User(
            email: user.email,
            imageUrl: userImageUrl,
            reference: user.reference,
            uid: user.uid,
            userName: user.userName);
        userRepo.updateUser(userObj);
        setUser(userObj);
      });
    });

    storageService.editProfileIsLoading.listen((value) {
      print(
          '------------------- value of image is loading [$value] ------------------ ');
      if (value) {
        _showSnackBar(
            "Updating the image may take a while according to the size of the image selected.");
      } else {
        _showSnackBar("Updated the image");
      }
      setState(() {
        isImageLoading = value;
      });
    });
  }

  _showSnackBar(String text) {
    widget.scaffoldKey.currentState.showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).cardColor,
        content: Text(
          text,
          style: TextStyle(
              color: AppTheme.textColor, fontFamily: AppTheme.fontFamily),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: isLoading || isImageLoading ? 0.6 : 1.0,
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
          visible: isLoading || isImageLoading,
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
                          if (a.length < 4) {
                            return "Enter name with atleast 4 characters";
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
            SizedBox(
              height: 0.05 * height,
            ),
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

                _showSnackBar("Updated data sucessfully");

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
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              // color: AppTheme.mainColor.withOpacity(0.3),
              color: Theme.of(context).cardColor,
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
                  constraints: BoxConstraints(
                      maxHeight: 0.25 * height, maxWidth: 0.25 * height),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: CachedNetworkImage(
                          imageUrl: userImageUrl,
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              decoration: BoxDecoration(
                                //   color: Theme.of(context).cardColor,
                                color: AppTheme.mainColor,
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            );
                          },
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
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
