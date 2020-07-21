import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messaging_app_new/user/user.dart';
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
    print('getting user from uid : $uid');
    QuerySnapshot a = await Firestore.instance
        .collection('user')
        .where('uid', isEqualTo: uid)
        .getDocuments();
    User user = User.fromJson(a.documents[0].data);

    return user;
  }
}

MainRepo mainRepo = MainRepo();
