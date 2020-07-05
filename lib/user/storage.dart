import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

class StorageService {
  PublishSubject imageUrl = PublishSubject();
  PublishSubject chatImageUrl = PublishSubject();

  PublishSubject editProfileIsLoading = PublishSubject();

  Future<PickedFile> pickFile() async {
    try {
      PickedFile file =
          await ImagePicker().getImage(source: ImageSource.gallery);
      return file;
    } catch (e) {
      Fluttertoast.showToast(msg: "Select an image");
      return null;
    }
  }

  Future uploadChatImage(
      PickedFile file, String documentID, DateTime time) async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('chats/$documentID/${time.millisecondsSinceEpoch.toString()}');
    File properFile = File(file.path);

    StorageUploadTask uploadTask = storageReference.putFile(properFile);
    await uploadTask.onComplete;
    print('File Uploaded');
    var url = await storageReference.getDownloadURL();

    chatImageUrl.add(url);
    return url;
  }

  uploadFile(PickedFile file) async {
    editProfileIsLoading.add(true);
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('profiles/${user.uid}');
    File properFile = File(file.path);

    StorageUploadTask uploadTask = storageReference.putFile(properFile);
    await uploadTask.onComplete;
    print('File Uploaded');
    var url = await storageReference.getDownloadURL();
    imageUrl.add(url);
    editProfileIsLoading.add(false);
  }
}

StorageService storageService = StorageService();
