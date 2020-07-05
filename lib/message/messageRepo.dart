import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'message.dart';
import '../groupModel.dart';

class MessageRepo {
  CollectionReference reference = Firestore.instance.collection("message");

//? Check if room exists else create it

  setReference(GroupModel model) async {
    print(" in set reference ");
    QuerySnapshot a = await Firestore.instance
        .collection("message")
        .where('participants', isEqualTo: model.participants)
        .getDocuments();

    if (a.documents.length > 0) {
      print(" in set reference  -- if -- \n ");
      var e = a.documents[0].reference;

      reference = e.collection("messages").reference();
    } else {
      print(" in set reference --else -- \n");
      await Firestore.instance
          .collection('message')
          .document()
          .setData({'participants': model.participants}, merge: true);

      QuerySnapshot a = await Firestore.instance
          .collection('message')
          .where('participants', isEqualTo: model.participants)
          .getDocuments();

      var e = a.documents[0].reference;
      reference = e.collection("messages").reference();
    }
  }

  Stream<QuerySnapshot> getStream() {
    return reference.orderBy("date", descending: true).snapshots();
  }

  Future<void> addMessage(Message message) {
    return reference
        .document(message.date.millisecondsSinceEpoch.toString())
        .setData(message.toJson());
  }

  Future getGroupDocumentId(GroupModel model) async {
    var snapshot = await Firestore.instance
        .collection("message")
        .where(
          'participants',
          isEqualTo: model.participants,
        )
        .getDocuments();
    return snapshot.documents[0].documentID;
  }

  Stream getLastMessage(GroupModel model, var documentId) {
    return Firestore.instance
        .collection('message')
        .document(documentId)
        .collection('messages')
        .snapshots();
  }

  deleteMessage(Message message) async {
    if (message.message != "This message has been deleted") {
      await reference
          .document(message.date.millisecondsSinceEpoch.toString())
          .updateData(
            Message(
                    message: "This message has been deleted",
                    date: message.date,
                    idFrom: message.idFrom,
                    idTo: message.idTo,
                    documentId: message.documentId,
                    isSeen: message.isSeen,
                    type: 0)
                .toJson(),
          );
    }
  }

  deleteGroup(GroupModel model) async {
    _printer(" in delete group ");
    getGroupDocumentId(model).then((value) async {
      Firestore.instance.collection("message").document(value).delete();

      var querySnapshot = await Firestore.instance
          .collection('message')
          .document(value)
          .collection('messages')
          .where('type', isEqualTo: 1)
          .getDocuments();

      if (querySnapshot.documents.length > 0) {
        for (int i = 0; i < querySnapshot.documents.length; i++) {
          Message message = Message.fromSnapshot(querySnapshot.documents[i]);
          deleteImage(value, message);
        }
      }
    });
  }

  deleteImage(String documentId, Message message) {
    deleteMessage(message);
    FirebaseStorage.instance
        .ref()
        .child('chats/$documentId/${message.date.millisecondsSinceEpoch}')
        .delete()
        .then((value) {
      _printer("-Deleted message completely-");
    });
  }

  updateIsSeen(Message message) async {
    await reference
        .document(message.date.millisecondsSinceEpoch.toString())
        .updateData(
          Message(
                  message: message.message,
                  date: message.date,
                  idFrom: message.idFrom,
                  idTo: message.idTo,
                  documentId: message.documentId,
                  isSeen: true,
                  imageUrl: message.imageUrl,
                  type: message.type)
              .toJson(),
        );
  }

  getChatRoom(String uid) async {
    _printer("getChatRoom [MessageRepo.dart]");
    /*  Stream<QuerySnapshot> a = Firestore.instance
        .collection("message")
        .where('participants', arrayContains: uid)
        .getDocuments()
        .asStream();
    _printer("-");

    return a; */
    var a = await Firestore.instance
        .collection('message')
        .where(
          'participants',
          arrayContains: uid,
        )
        .getDocuments();
    var b = a.documents[0].reference;
    b.collection("message").add({'kuchbhi': "aur nitpo lue"});
  }
}

_printer(String text) {
  print(
      "\n\n--------------------------------$text---------------------------\n\n");
  print("\n\n\n");
}

MessageRepo messageRepo = MessageRepo();
