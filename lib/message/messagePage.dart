import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mdi/mdi.dart';
import 'package:messaging_app_new/consts/theme.dart';
import 'package:messaging_app_new/data/sharedPrefs.dart';
import 'package:messaging_app_new/groupModel.dart';
import 'package:messaging_app_new/message/buildMessageWidget.dart';
import 'package:messaging_app_new/message/demo.dart';
import 'package:messaging_app_new/message/message.dart';
import 'package:messaging_app_new/message/messageRepo.dart';
import 'package:messaging_app_new/user/storage.dart';
import 'package:messaging_app_new/user/user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class MessagePage extends StatefulWidget {
  final GroupModel model;
  final User user;
  MessagePage(this.model, this.user);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>
    with SingleTickerProviderStateMixin {
  GroupModel model;

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var messageEntered = "";
  var idTo, idFrom;
  var documentId;
  TextEditingController controller;

  var isLoading = true;
  PublishSubject isLoadingSubject = PublishSubject();

  ScrollController scrollController;
  bool showGoToTopFab = false;
  bool showDemo = true;
  AnimationController animationController;
  Animation rotationAnimation;
  var photoColor = AppTheme.iconColor;
  var height;
  var anotherUserName;
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
    scrollController = ScrollController();
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

    scrollController.addListener(() {
      if (scrollController.offset ==
          scrollController.position.minScrollExtent) {
        setState(() {
          showGoToTopFab = false;
        });
      } else {
        setState(() {
          showGoToTopFab = true;
        });
      }
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
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        key: scaffoldKey,
        floatingActionButton: Visibility(
          visible: showGoToTopFab,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton(
                onPressed: () {
                  scrollController.animateTo(
                      scrollController.position.minScrollExtent,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn);
                },
                child: Icon(Mdi.menuDown),
              ),
              SizedBox(
                height: 0.075 * height,
              )
            ],
          ),
        ),
        appBar: AppBar(
          title: Hero(
            tag: widget.user.userName,
            child: Material(
              child: Text(
                "${widget.user.userName}",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppTheme.textColor),
              ),
            ),
          ),
          backgroundColor: Theme.of(context).canvasColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            PopupMenuButton(
              offset: Offset(0, 50.0),
              onSelected: (value) {
                if (value == 0) {
                  messageRepo.clearChat(model);
                  Navigator.of(context).pop();
                }
              },
              icon: Icon(MdiIcons.dotsVertical, color: AppTheme.iconColor),
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
              MdiIcons.chevronLeft,
              color: AppTheme.iconColor,
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
          physics: BouncingScrollPhysics(),
          controller: scrollController,
          reverse: true,
          itemBuilder: (context, index) {
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
      if (showDemo) {
        return Center(
          child: DemoPage(scaffoldKey),
        );
      }
      return Container();
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
                          onTap: () {
                            setState(() {
                              showDemo = false;
                            });
                          },
                          controller: controller,
                          cursorRadius: Radius.circular(20.0),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10.0, right: 10.0, bottom: 5.0),
                              hintText: "Type your message.",
                              alignLabelWithHint: true,
                              border: InputBorder.none),
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
                        tooltip: 'Send a photo',
                        icon: Icon(
                          MdiIcons.googlePhotos,
                          color: photoColor,
                        ),
                        onPressed: _onPressedPhotoIcon,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Send',
                      icon: Icon(
                        Icons.send,
                        color: AppTheme.mainColor,
                      ),
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
      // Fluttertoast.showToast(msg: "The image may take a while to display");
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          "The image may take a while to display",
          style: TextStyle(color: AppTheme.textColor),
        ),
        backgroundColor: Theme.of(context).cardColor,
      ));
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
