import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  String userName;
  String email;
  String imageUrl;
  DocumentReference reference;

  User({
    this.uid,
    this.userName,
    this.email,
    this.reference,
    this.imageUrl,
  });

  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    User user = User.fromJson(snapshot.data);
    user.reference = snapshot.reference;
    return user;
  }

  factory User.fromJson(Map<dynamic, dynamic> json) {
    return User(
      imageUrl: json['imageUrl'] as String,
      email: json['email'] as String,
      uid: json['uid'] as String,
      userName: json['userName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'userName': userName,
      'imageUrl': imageUrl,
      'uid': uid,
    };
  }
}
