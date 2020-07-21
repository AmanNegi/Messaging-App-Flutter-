import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messaging_app_new/Layout/verificationDialog.dart';
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
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  AuthService authService;
  AnimationController _animationController;
  Animation _animation;
  String buttonText = login;
  String helperText = loginHelperText;
  String email;
  String password;

  double width;
  bool error = false;
  bool isLoading = false;
  bool isVerified = false;
  var height;
  RegExp r = new RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
      caseSensitive: false);

  var obscureText = true;
  IconData currentIcon = Icons.visibility_off;
  TextEditingController emailController, passwordController;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    authService = AuthService(scaffoldKey);
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
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: _buildForm(),
    );
  }

  _buildForm() {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Opacity(
            opacity: isLoading ? 0.6 : 1.0,
            child: Image.asset(
              "assets/giphy.gif",
              fit: BoxFit.cover,
              height: height,
            ),
          ),
        ),
        Positioned(
          top: 0.4 * height,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: isLoading ? 0.6 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: TextFormBuilder(
                      textStyle: TextStyle(color: Colors.grey),
                      hintText: "Email",
                      controller: emailController,
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
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: TextFormBuilder(
                      textStyle: TextStyle(color: Colors.grey),
                      obscureText: obscureText,
                      suffixWidget: IconButton(
                        icon: Icon(currentIcon),
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                            if (obscureText)
                              currentIcon = Icons.visibility_off;
                            else
                              currentIcon = Icons.visibility;
                          });
                        },
                      ),
                      controller: passwordController,
                      hintText: "Password",
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
                  SizedBox(height: 60.0),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (BuildContext context, Widget child) {
                      return Transform(
                        child: child,
                        transform: Matrix4.translationValues(
                            _animation.value * width, 0, 0),
                      );
                    },
                    child: _buildRaisedButton(),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  _buildHelperText(),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Visibility(
            visible: isLoading,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.deepOrange),
            ),
          ),
        ),
      ],
    );
  }

  _buildRaisedButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30.0),
        onTap: _getSignInOrLogin(buttonText) == 1
            ? _onPressedsignUpButton
            : _onPressedLoginButton,
        child: Ink(
          width: 0.9 * width,
          height: 0.07 * height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            gradient: LinearGradient(
              colors: [
                fromHex('#ff5f6d'),
                fromHex('#ffc371d'),
              ],
            ),
          ),
          child: Center(
              child: Text(
            buttonText,
            style: TextStyle(color: Colors.white),
          )),
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
    if (!(emailController.text.length <= 0) &&
        !(passwordController.text.length <= 0)) {
      FirebaseUser user = await authService.login(
          emailController.text, passwordController.text);
      if (isVerified && !error) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => MainPage()));
      } else {
        if (error == false && user != null) {
          _buildVerificationDialog();
        }
      }
    } else {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Enter valid Details"),
      ));
    }
  }

  _buildVerificationDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return VerificationDialog(() {
            if (!isVerified) {
              authService.sendVerification();
            }
          });
        });
  }

  _onPressedsignUpButton() async {
    if (!(emailController.text.length <= 0) &&
        !(passwordController.text.length <= 0)) {
      FirebaseUser user = await authService.signUp(
          emailController.text, passwordController.text);
      if (isVerified && !error) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => MainPage()));
      } else {
        if (!error && user != null) {
          _buildVerificationDialog();
        }
      }
    } else {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Enter valid Details"),
      ));
    }
  }

  _buildHelperText() {
    return GestureDetector(
        child: Text(helperText, style: TextStyle(color: Colors.white)),
        onTap: () {
          _animationController.forward();
        });
  }
}

Color fromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
