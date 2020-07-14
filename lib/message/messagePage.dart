import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/parser.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:messaging_app_new/consts/theme.dart';
import 'package:messaging_app_new/data/sharedPrefs.dart';
import 'package:messaging_app_new/groupModel.dart';
import 'package:messaging_app_new/message/buildMessageWidget.dart';
import 'package:messaging_app_new/message/message.dart';
import 'package:messaging_app_new/message/messageRepo.dart';
import 'package:messaging_app_new/user/storage.dart';
import 'package:messaging_app_new/user/user.dart';
import 'package:rxdart/rxdart.dart';

class MessagePage extends StatefulWidget {
  GroupModel model;
  User user;
  MessagePage(this.model, this.user);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>
    with SingleTickerProviderStateMixin {
  GroupModel model;

  var messageEntered = "";
  var idTo, idFrom;
  var documentId;
  TextEditingController controller;

  var isLoading = true;
  PublishSubject isLoadingSubject = PublishSubject();

  AnimationController animationController;
  Animation rotationAnimation;
  var photoColor = AppTheme.iconColor;

  _getDataFromApi() async {
    isLoadingSubject.add(true);
    print(model.toJson().toString());
    await messageRepo.setReference(model);
    documentId = await messageRepo.getGroupDocumentId(model);
    isLoadingSubject.add(false);
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  void initState() {
    model = widget.model;
    idFrom = sharedPrefs.getValueFromSharedPrefs('uid');
    animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 150,
      ),
    );

    rotationAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    ));
    _getAnotherUserId();

    controller = TextEditingController();
    _getDataFromApi();
    super.initState();
    isLoadingSubject.listen((value) {
      setState(() {
        isLoading = value;
      });
    });
  }

  _getAnotherUserId() {
    for (var a in model.participants) {
      if (a != idFrom) {
        idTo = a;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${widget.user.userName}"),
          //   backgroundColor: Theme.of(context).canvasColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            PopupMenuButton(
              offset: Offset(0, 50.0),
              onSelected: (value) {
                print("in print value: " + value.toString());
                if (value == 0) {
                  messageRepo.clearChat(model);
                  Navigator.of(context).pop();
                }
              },
              icon: Icon(MdiIcons.dotsVertical, color: Colors.white),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: Text("Clear chat"),
                    value: 0,
                  ),
                ];
              },
            ),
          ],
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              MdiIcons.arrowLeft,
              color: Colors.white,
            ),
          ),
        ),
        body: _getMainWidget());
  }

  _getMainWidget() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return StreamBuilder(
      stream: messageRepo.getStream(),
      builder: (context, AsyncSnapshot snapshot) {
        print(snapshot.data.toString());
        if (snapshot.hasData) {
          return _buildMainWidget(snapshot.data);
        } else if (snapshot.connectionState == ConnectionState.active) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(" An error occured "),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  _buildMainWidget(QuerySnapshot data) {
    List list = data.documents;
    return _buildMessagingLayout(list);
  }

  _getList(list) {
    if (list.length > 0) {
      return Container(
        color: Colors.transparent,
        margin: EdgeInsets.only(bottom: 60.0),
        child: ListView.builder(
          reverse: true,
          itemBuilder: (context, index) {
            print(" ${index + 1} -- ${list.length}");
            print(" abc ");
            return BuildMessageWidget(
                list[index],
                sharedPrefs.getValueFromSharedPrefs('uid'),
                documentId,
                index == 0);
          },
          itemCount: list.length,
        ),
      );
    } else {
      return Center(
        child: Text(" No message try sending one"),
      );
    }
  }

  _buildMessagingLayout(list) {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          _getList(list),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                height: 60,
                color: Colors.black12,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: controller,
                          cursorRadius: Radius.circular(20.0),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.only(
                                left: 10.0, right: 10.0, bottom: 5.0),
                            hintText: "Type your message.",
                            border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                width: 5.0,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: 1.5 * rotationAnimation.value,
                          child: child,
                        );
                      },
                      animation: animationController,
                      child: IconButton(
                        icon: Icon(
                          MdiIcons.googlePhotos,
                          color: photoColor,
                        ),
                        onPressed: _onPressedPhotoIcon,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        if (controller.text.length > 0) {
                          messageRepo.addMessage(
                              Message(
                                  date: DateTime.now(),
                                  message: controller.text,
                                  idFrom: sharedPrefs
                                      .getValueFromSharedPrefs('uid'),
                                  idTo: idTo,
                                  isSeen: false,
                                  documentId: documentId,
                                  type: 0),
                              model,
                              documentId);
                          setState(() {
                            controller.text = "";
                          });
                        } else {
                          Fluttertoast.showToast(
                              msg: "Enter a message to send");
                        }
                      },
                    )
                  ],
                )),
          ),
        ],
      ),
    );
  }

  _onPressedPhotoIcon() async {
    setState(() {
      photoColor = AppTheme.accentColor;
    });
    animationController.repeat();

    DateTime time = DateTime.now();
    var value = await storageService.pickFile();
    if (value != null) {
      Fluttertoast.showToast(msg: "The image may take a while to display");
      storageService.uploadChatImage(value, documentId, time).then((url) {
        print(url);
        if (url != null) {
          Message message = Message(
              documentId: documentId,
              type: 1,
              date: time,
              idFrom: idFrom,
              idTo: idTo,
              message: "Image",
              imageUrl: url,
              isSeen: false);

          messageRepo.addMessage(message, model, documentId);
        }

        animationController.stop();
        setState(() {
          photoColor = AppTheme.iconColor;
        });
      });
    } else {
      animationController.stop();
      setState(() {
        photoColor = AppTheme.iconColor;
      });
    }
  }
}
