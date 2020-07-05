import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messaging_app_new/user/user.dart';
import '../data/sharedPrefs.dart';

import 'package:rxdart/rxdart.dart';

class SearchRepo {
  CollectionReference reference = Firestore.instance.collection("user");

  PublishSubject<User> searchResult = PublishSubject<User>();
  PublishSubject loading = PublishSubject();

  Future<bool> checkIfUserExists(String uid) async {
    loading.add(true);
    var snapshot = await reference.document(uid).get();
    loading.add(false);
    if (snapshot == null || !snapshot.exists) {
      return false;
    }
    return true;
  }

 Future getConfirmedUser(String uid) async {
    print(" in confirmed user + " + uid);
    loading.add(true);

    DocumentSnapshot a =
        await reference.document(uid).get(source: Source.serverAndCache);

    loading.add(false);
    User searchUser = User.fromSnapshot(a);
    if (searchUser.uid != sharedPrefs.getValueFromSharedPrefs("uid")) {
      searchResult.add(searchUser);
      return 1;
    } else {
      return 0;
    }
  }
}

SearchRepo searchRepo = SearchRepo();
