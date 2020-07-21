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

    print("First query results = : ${a.documents.length}");

    if (a.documents.length <= 0) {
      print(" in if ----checking another way");
      a = await Firestore.instance.collection("message").where('participants',
          isEqualTo: [
            model.participants[1],
            model.participants[0]
          ]).getDocuments();
    }

    if (a.documents.length > 0) {
      print(" in set reference  -- if -- \n ");
      var e = a.documents[0].reference;

      reference = e.collection("messages").reference();
    } else {
      print(" in set reference --else -- \n");
      await Firestore.instance.collection('message').document().setData(
          {'participants': model.participants, 'date': DateTime.now()},
          merge: true);

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

  Future<void> addMessage(Message message, GroupModel model, var docId) {
    updateTime(docId, message.date, model);
    return reference
        .document(message.date.millisecondsSinceEpoch.toString())
        .setData(message.toJson());
  }

  updateTime(String docId, DateTime date, GroupModel model) {
    Firestore.instance
        .collection('message')
        .document(docId)
        .setData({'participants': model.participants, 'date': date});
  }

  Future getGroupDocumentId(GroupModel model) async {
    var snapshot = await Firestore.instance
        .collection("message")
        .where(
          'participants',
          isEqualTo: model.participants,
        )
        .getDocuments();
    if (snapshot.documents.length <= 0) return null;
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

  clearChat(GroupModel model) async {
    print('-------------in Clear chat--------- ');
    getGroupDocumentId(model).then((value) async {
      var querySnapshot = await Firestore.instance
          .collection('message')
          .document(value)
          .collection('messages')
          .getDocuments();

      var inst = Firestore.instance.collection('message').document(value);

      if (querySnapshot.documents.length > 0) {
        for (int i = 0; i < querySnapshot.documents.length; i++) {
          Message message = Message.fromSnapshot(querySnapshot.documents[i]);
          if (message.type == 1) {
            deleteImageCompletely(value, message);
            inst
                .collection('messages')
                .document(message.date.millisecondsSinceEpoch.toString())
                .delete();
          } else {
            print("\n--- Deleting message(${message.documentId})---\n ");
            inst
                .collection('messages')
                .document(message.date.millisecondsSinceEpoch.toString())
                .delete();
          }
        }
      }
    });
  }

  deleteGroup(GroupModel model) async {
    _printer(" in delete group ");
    getGroupDocumentId(model).then((value) async {
      var querySnapshot = await Firestore.instance
          .collection('message')
          .document(value)
          .collection('messages')
          .where('type', isEqualTo: 1)
          .getDocuments();

      if (querySnapshot.documents.length > 0) {
        for (int i = 0; i < querySnapshot.documents.length; i++) {
          Message message = Message.fromSnapshot(querySnapshot.documents[i]);
          deleteImageCompletely(value, message);
        }
      }
      Firestore.instance.collection("message").document(value).delete();
    });
  }

  deleteImageCompletely(String documentId, Message message) {
    FirebaseStorage.instance
        .ref()
        .child('chats/$documentId/${message.date.millisecondsSinceEpoch}')
        .delete()
        .then((value) {
      _printer("-Deleted message completely-");
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
                  notificationShown: message.notificationShown,
                  imageUrl: message.imageUrl,
                  type: message.type)
              .toJson(),
        );
  }

  updateIsNotificationShown(Message message) async {
    await Firestore.instance
        .collection('message')
        .document(message.documentId)
        .collection("messages")
        .document(message.date.millisecondsSinceEpoch.toString())
        .updateData(Message(
                message: message.message,
                date: message.date,
                idFrom: message.idFrom,
                idTo: message.idTo,
                documentId: message.documentId,
                isSeen: message.isSeen,
                notificationShown: true,
                imageUrl: message.imageUrl,
                type: message.type)
            .toJson());
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
