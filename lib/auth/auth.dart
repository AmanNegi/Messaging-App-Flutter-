import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import 'package:messaging_app_new/errorHelper.dart';
import 'package:messaging_app_new/user/UserRepo.dart';
import 'package:messaging_app_new/user/user.dart';
import '../data/strings.dart';
import '../data/sharedPrefs.dart';

class AuthService {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  PublishSubject errorHandler = PublishSubject();
  PublishSubject loading = PublishSubject();
  PublishSubject userEmailVerified = PublishSubject();

  Stream getMainStream() {
    return _firebaseAuth.onAuthStateChanged;
  }

  login(String email, String password) async {
    print(" in login ");
    loading.add(true);
    try {
      var result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      loading.add(false);
      errorHandler.add(false);

      await sendVerification();
      _keepCheckOfEmailVerification();
      return result.user;
    } catch (error) {
      if (error is PlatformException) {
        errorHandler.add(true);
        ErrorHelper(errorText: error.code.toString()).showErrorText();
      }
      loading.add(false);
      return null;
    }
  }

  _keepCheckOfEmailVerification() {
    Timer.periodic(Duration(seconds: 3), (timer) async {
      await _firebaseAuth.currentUser()
        ..reload();
      var user = await _firebaseAuth.currentUser();
      print("in timer " + user.isEmailVerified.toString());
      if (user.isEmailVerified) {
        timer.cancel();
        userEmailVerified.add(true);
        _addToFirebaseDatabase();
        sharedPrefs.addItemToSharedPrefs("uid", user.uid.toString());
      }
    });
  }

  _addToFirebaseDatabase() async {
    var firebaseUser = await _firebaseAuth.currentUser();
    bool exists = await UserRepo().checkIfUserExists(firebaseUser.uid);
    if (!exists) {
      User user = User(
          imageUrl: demoImage,
          email: firebaseUser.email,
          uid: firebaseUser.uid,
          userName: firebaseUser.email);
      await UserRepo().addUser(user);
    }
  }

  sendVerification() async {
    await _firebaseAuth.currentUser()
      ..reload();
    var user = await _firebaseAuth.currentUser();

    if (user.isEmailVerified) {
      userEmailVerified.add(true);
    } else {
      await user.sendEmailVerification();
      userEmailVerified.add(user.isEmailVerified);
    }
  }

  signUp(String email, String password) async {
    print(" in sign Up ");
    loading.add(true);
    try {
      AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      errorHandler.add(false);
      loading.add(false);

      await sendVerification();
      _keepCheckOfEmailVerification();
      return result.user;
    } catch (error) {
      if (error is PlatformException) {
        errorHandler.add(true);
        ErrorHelper(errorText: error.code.toString()).showErrorText();
      }
      loading.add(false);
      return null;
    }
  }
}

AuthService authService = AuthService();
