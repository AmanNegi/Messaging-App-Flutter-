import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messaging_app_new/consts/theme.dart';

import '../Layout/TextFormBuilder.dart';
import 'auth.dart';
import '../mainPage.dart';
import '../data/strings.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  var key = GlobalKey<FormState>();

  String buttonText = signUp;
  String helperText = signUpHelperText;
  String email;
  String password;

  double width;

  bool error = false;
  bool isLoading = false;
  bool isVerified = false;

  RegExp r = new RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
      caseSensitive: false);

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    _animation = Tween(begin: 0.0, end: -1.0).animate(
        CurvedAnimation(curve: Curves.easeIn, parent: _animationController));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        print("in status completed ");
        _animationController.reverse();
        setState(() {
          if (_getSignInOrLogin(buttonText) == 1) {
            buttonText = "Login";
            helperText = loginHelperText;
          } else {
            buttonText = signUp;
            helperText = signUpHelperText;
          }
        });
      }
    });
    _initializeStreams();
  }

  _initializeStreams() {
    authService.userEmailVerified.listen((data) {
      this.isVerified = data;
      if (isVerified) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => MainPage(),
          ),
        );
      }
    });

    authService.loading.listen((data) => setState(() {
          this.isLoading = data;
        }));

    authService.errorHandler.listen((data) => setState(() {
          print("eror value : - " + data.toString());
          this.error = data;
        }));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text(buttonText),
        ),
        body: _buildBody());
  }

  _buildBody() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return _buildForm();
    }
  }

  _buildForm() {
    return Form(
      key: key,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
                color: mainColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.0)),
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormBuilder(
                    hintText: "Email",
                    icon: Icon(Icons.email),
                    keybordType: TextInputType.emailAddress,
                    onSaved: (val) {
                      email = val;
                    },
                    validator: (val) {
                      if (!r.hasMatch(val)) {
                        return "Enter a valid Email";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormBuilder(
                    hintText: "Password",
                    icon: Icon(Icons.keyboard),
                    keybordType: TextInputType.visiblePassword,
                    onSaved: (val) {
                      setState(() {
                        password = val;
                      });
                    },
                    validator: (val) {
                      if (val.length < 6) {
                        return "Enter more than 6 characters";
                      }
                      return null;
                    },
                  ),
                ),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (BuildContext context, Widget child) {
                    return Transform(
                      child: child,
                      transform: Matrix4.translationValues(
                          _animation.value * width, 0, 0),
                    );
                  },
                  child: RaisedButton(
                    color: accentColor.withOpacity(0.7),
                    onPressed: _getSignInOrLogin(buttonText) == 1
                        ? _onPressedsignUpButton
                        : _onPressedLoginButton,
                    child: Text(
                      buttonText,
                      style: TextStyle(color: buttonTextColor),
                    ),
                  ),
                ),
                _buildHelperText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getSignInOrLogin(String text) {
    if (text == signUp) {
      return 1;
    } else {
      return 0;
    }
  }

  _onPressedLoginButton() async {
    if (key.currentState.validate()) {
      key.currentState.save();
      FirebaseUser user = await authService.login(email, password);
      if (isVerified && !error) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => MainPage()));
      } else {
        if (error == false && user != null) {
          _buildVerificationDialog();
        }
      }
    }
  }

  _buildVerificationDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            children: <Widget>[
              Container(
                child: Card(
                  elevation: 0,
                  child: _buildDialogContent(context),
                ),
              ),
            ],
          );
        });
  }

  Column _buildDialogContent(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          dialogVerificationTitle,
          textAlign: TextAlign.start,
          style: GoogleFonts.aBeeZee(
            fontSize: 20,
          ),
        ),
        Divider(
          thickness: 3.0,
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(dialogVerificationBodyText),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                color: Colors.lightGreen[400],
                onPressed: () {
                  if (!isVerified) {
                    authService.sendVerification();
                  }
                },
                child: Text("Re-Send"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                color: Colors.red[200],
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  _onPressedsignUpButton() async {
    if (key.currentState.validate()) {
      key.currentState.save();
      FirebaseUser user = await authService.signUp(email, password);
      if (isVerified && !error) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => MainPage()));
      } else {
        if (!error && user != null) {
          _buildVerificationDialog();
        }
      }
    }
  }

  _buildHelperText() {
    return GestureDetector(
        child: Text(helperText, style: TextStyle(color: mainColor)),
        onTap: () {
          _animationController.forward();
        });
  }
}
