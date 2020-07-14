import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messaging_app_new/user/user.dart';
import 'package:rxdart/rxdart.dart';
import './data/sharedPrefs.dart';

class MainRepo {
  var reference = Firestore.instance.collection("message");
  DocumentReference documentReference;
//* TODO: Get all users the current user is messaging with

  Stream<QuerySnapshot> getStream() {
    var uid = sharedPrefs.getValueFromSharedPrefs('uid');

    return reference
        .where(
          "participants",
          arrayContains: uid,
        )
        .orderBy('date', descending: true)
        .snapshots();
  }

  Stream getUserStream(String uid) {
    return Firestore.instance.collection('user').document(uid).snapshots();
  }

  Future<User> getUserFromUid(String uid) async {
    // id : G37dw3hfFnV54d5AmB1sb7Qc0Fo1 :--
    QuerySnapshot a = await Firestore.instance
        .collection('user')
        .where('uid', isEqualTo: uid)
        .getDocuments();
    User user = User.fromJson(a.documents[0].data);
    print(user.userName);
    return user;
  }
}

MainRepo mainRepo = MainRepo();
