import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  String message;
  String idTo;
  String idFrom;
  DateTime date;
  bool isSeen = false;
  String documentId;
  int type;
  String imageUrl;
  bool notificationShown = false;
  DocumentReference reference;

//0 message : 1 image
  Message(
      {@required this.message,
      @required this.idTo,
      @required this.idFrom,
      @required this.date,
      @required this.documentId,
      @required this.type,
      this.notificationShown = false,
      this.imageUrl,
      this.isSeen});

  factory Message.fromSnapshot(DocumentSnapshot snapshot) {
    Message message = Message.fromJson(snapshot.data);
    message.reference = snapshot.reference;
    return message;
  }

  factory Message.fromJson(Map<dynamic, dynamic> json) {
    return Message(
        message: json['message'] as String,
        date: json['date'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                json['date'].millisecondsSinceEpoch),
        idFrom: json['idFrom'] as String,
        idTo: json['idTo'] as String,
        isSeen: json['isSeen'] as bool,
        documentId: json['documentId'] as String,
        imageUrl: json['imageUrl'] as String,
        notificationShown: json['notification'] as bool,
        type: json['type'] as int);
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'date': date,
      'idFrom': idFrom,
      'idTo': idTo,
      'isSeen': isSeen,
      'documentId': documentId,
      'type': type,
      'imageUrl': imageUrl,
      'notificationShown': notificationShown
    };
  }
}
