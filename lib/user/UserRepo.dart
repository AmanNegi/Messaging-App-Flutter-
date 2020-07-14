import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:messaging_app_new/user/user.dart';

class UserRepo {
  CollectionReference reference = Firestore.instance.collection("user");

  Stream<QuerySnapshot> getStream() {
    return reference.snapshots();
  }

  Stream getReferenceSnapshots(String uid) {
    return reference.document(uid).snapshots();
  }

  Future<void> addUser(User user) {
    //  return reference.add(user.toJson());
    return reference.document(user.uid).setData(user.toJson(), merge: false);
  }

  checkIfUserExists(String uid) async {
    var snapshot = await reference.document(uid).get();
    if (snapshot == null || !snapshot.exists) {
      return false;
    }
    return true;
  }

  Future<DocumentSnapshot> getConfirmedUser(String uid) async {
    return reference.document(uid).get(source: Source.server);
  }

  updateUser(User newUser) async {
    print("-----------------------------------URL{" +
        newUser.imageUrl.toString() +
        "}-------------------\n uid:{$newUser.uid}");
    await Firestore.instance
        .collection('user')
        .document(newUser.uid)
        .updateData(newUser.toJson());
  }
}
