import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mdi/mdi.dart';
import 'package:messaging_app_new/consts/theme.dart';
import 'package:messaging_app_new/data/sharedPrefs.dart';
import 'package:messaging_app_new/mainRepo.dart';
import 'package:messaging_app_new/message/imageFullScreen.dart';
import 'package:messaging_app_new/message/message.dart';
import 'package:messaging_app_new/message/messagePage.dart';
import 'package:messaging_app_new/message/messageRepo.dart';
import 'package:messaging_app_new/user/user.dart';
import 'package:messaging_app_new/user/userInfoPage.dart';
import 'groupModel.dart';
import './Layout/DrawerBuilder.dart';
import 'package:shimmer/shimmer.dart';
import './message/searchPage.dart';
import 'appData.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var key = GlobalKey<FormState>();
  var height, searchUid, width;
  String currentUid = '';
  List<GroupModel> numberOfUsers = [];
  User currentUser;

  @override
  void initState() {
    currentUid = sharedPrefs.getValueFromSharedPrefs('uid');
    initVariables();
    super.initState();
  }

  initVariables() async {
    print(" in init state() value : ");
    currentUser = await mainRepo.getUserFromUid(currentUid);
    print(" in init state() value : ${currentUser.imageUrl}");
    setUser(currentUser);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: DrawerBuilder(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Mdi.sortVariant,
            color: AppTheme.iconColor,
          ),
          onPressed: () {
            scaffoldKey.currentState.openDrawer();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Mdi.searchWeb,
              color: AppTheme.iconColor,
            ),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => SearchPage()));
            },
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(120.0),
              child: Container(
                width: 52.5,
                height: 50,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(120.0),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: ValueListenableBuilder(
                            valueListenable: userData,
                            builder: (context, User value, child) {
                              return Hero(
                                tag: 'userImage',
                                child: Container(
                                  color: Theme.of(context).cardColor,
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        value != null ? value.imageUrl : '',
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => Icon(
                                        Mdi.alert,
                                        color: AppTheme.iconColor),
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                            child: Container(
                                              color: Colors.red,
                                            ),
                                            baseColor:
                                                AppTheme.shimmerBaseColor,
                                            highlightColor:
                                                AppTheme.shimmerEndingColor),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => UserInfo(),
                                ));
                              },
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
      body: _getMainWidget(),
    );
  }

  _getMainWidget() {
    return StreamBuilder(
      stream: mainRepo.getStream(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        print("new dat dound");
        if (snapshot.hasData) {
          return _buildMainWidget(snapshot.data);
        } else {
          return Container();
        }
      },
    );
  }

  itemBuilder(DocumentSnapshot snapshot, int index) {
    User user;
    GroupModel model = GroupModel.fromJson(snapshot.data);
    var secondUserId = _getSecondMemberId(model);

    return StreamBuilder<Object>(
        stream: mainRepo.getUserStream(secondUserId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            user = User.fromSnapshot(snapshot.data);
            return FutureBuilder(
              future: messageRepo.getGroupDocumentId(model),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  String documentId = snapshot.data;
                  return _buildUserTileStreamBuilder(
                      model, documentId, user, index);
                } else {
                  //toDO:show Shimmer
                  return _buildShimmerItem();
                }
              },
            );
          } else {
            return _buildShimmerItem();
          }
        });
  }

  _buildShimmerItem() {
    return Container(
      height: 0.1 * height,
      child: Stack(
        children: <Widget>[
          Shimmer.fromColors(
            baseColor: AppTheme.shimmerBaseColor,
            highlightColor: AppTheme.shimmerEndingColor,
            child: Container(
              color: Colors.red,
            ),
          ),
          Positioned(
            left: 0.020 * width,
            child: Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Theme.of(context).cardColor),
            ),
          )
        ],
      ),
    );
  }

  _buildUserTileStreamBuilder(
      GroupModel model, String documentId, User user, int index) {
    return StreamBuilder(
        stream: messageRepo.getLastMessage(model, documentId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            QuerySnapshot querySnapshot = snapshot.data;
            if (querySnapshot.documents.length > 0) {
              Message message = Message.fromSnapshot(
                  querySnapshot.documents[querySnapshot.documents.length - 1]);
              return Dismissible(
                onDismissed: (v) {
                  messageRepo.deleteGroup(model);
                },
                direction: DismissDirection.startToEnd,
                background: Container(
                  width: double.infinity,
                  height: 0.1 * height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).cardColor, Colors.red],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Delete",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                key: Key(documentId),
                child: Center(
                  child: Container(
                    //   width: 0.95 * width,
                    width: double.infinity,
                    height: 0.1 * height,
                    decoration: BoxDecoration(
                      color: _getNewMessageColor(message),
                    ),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        MessagePage(model, user)));
                              },
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 5.0,
                                    right: 8.0,
                                    left: 5.0,
                                    bottom: 5.0),
                                child: Hero(
                                  tag: user.imageUrl,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ImageFullScreen(
                                                      user.imageUrl)));
                                    },
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(120.0),
                                      child: Container(
                                        height: 0.08 * height,
                                        width: 0.08 * height,
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              user != null ? user.imageUrl : '',
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              Icon(Mdi.alert,
                                                  color: AppTheme.iconColor),
                                          placeholder: (context, url) =>
                                              Shimmer.fromColors(
                                                  child: Container(
                                                    color: Colors.red,
                                                  ),
                                                  baseColor:
                                                      AppTheme.shimmerBaseColor,
                                                  highlightColor: AppTheme
                                                      .shimmerEndingColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MessagePage(model, user)));
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Hero(
                                        tag: user.userName,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Text(
                                            user.userName,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: AppTheme.textColor),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        message.message,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontFamily: GoogleFonts.openSans()
                                                .fontFamily,
                                            fontSize: 15,
                                            color: AppTheme.textColor),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return _buildTextWithoutAnyMessage(user, model);
            }
          } else {
            return Container();
          }
        });
  }

  _getNewMessageColor(Message message) {
    if (message.idFrom == currentUid) {
      return Theme.of(context).canvasColor;
    } else {
      if (message.isSeen) return Theme.of(context).canvasColor;
      return AppTheme.mainColor.withOpacity(0.5);
    }
  }

  _buildTextWithoutAnyMessage(User user, GroupModel model) {
    return Dismissible(
      onDismissed: (v) {
        messageRepo.deleteGroup(model);
      },
      direction: DismissDirection.startToEnd,
      background: Container(
        width: double.infinity,
        height: 0.1 * height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).cardColor, Colors.red],
          ),
        ),
        child: Center(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      key: Key(user.uid),
      child: Container(
        width: double.infinity,
        height: 0.1 * height,
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MessagePage(model, user)));
                  },
                ),
              ),
            ),
            Positioned.fill(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Hero(
                      tag: user.imageUrl,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ImageFullScreen(user.imageUrl)));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(120.0),
                          child: Container(
                            height: 0.08 * height,
                            width: 0.08 * height,
                            child: CachedNetworkImage(
                              imageUrl: user != null ? user.imageUrl : '',
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  Icon(Mdi.alert, color: AppTheme.iconColor),
                              placeholder: (context, url) => Shimmer.fromColors(
                                  child: Container(
                                    color: Colors.red,
                                  ),
                                  baseColor: AppTheme.shimmerBaseColor,
                                  highlightColor: AppTheme.shimmerEndingColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MessagePage(model, user)));
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: Hero(
                        tag: user.userName,
                        child: Text(
                          user.userName,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppTheme.textColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getSecondMemberId(GroupModel model) {
    String secondUserId;
    List participants = model.participants;
    for (var a in participants) {
      if (a != currentUid) {
        secondUserId = a;
      }
    }
    return secondUserId;
  }

  _buildMainWidget(QuerySnapshot data) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        //TODO: Set the divider here
        return Container(
          height: 1,
          width: double.infinity,
          color: Theme.of(context).cardColor,
        );
      },
      itemBuilder: (context, index) {
        return itemBuilder(data.documents[index], index);
      },
      itemCount: data.documents.length,
    );
  }
}
