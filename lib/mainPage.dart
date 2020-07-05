import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messaging_app_new/consts/theme.dart';
import 'package:messaging_app_new/data/sharedPrefs.dart';
import 'package:messaging_app_new/mainRepo.dart';
import 'package:messaging_app_new/message/imageFullScreen.dart';
import 'package:messaging_app_new/message/message.dart';
import 'package:messaging_app_new/message/messagePage.dart';
import 'package:messaging_app_new/message/messageRepo.dart';
import 'package:messaging_app_new/message/searchRepo.dart';
import 'package:messaging_app_new/message/searchResultTileBuilder.dart';
import 'package:messaging_app_new/user/user.dart';
import 'groupModel.dart';
import './Layout/DrawerBuilder.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String errorText = "";

  var _isSearch = false;
  var isLoading = false;
  var userExists = false;
  var _appBar;
  var key = GlobalKey<FormState>();
  var height, searchUid, width;
  var currentUid = '';
  List<GroupModel> numberOfUsers = [];

  @override
  void initState() {
    currentUid = sharedPrefs.getValueFromSharedPrefs('uid');
    _appBar = AppBar(
      title: Text("Messaging app"),
      actions: <Widget>[
        IconButton(
          onPressed: _changeWidget,
          icon: Icon(
            Icons.search,
          ),
        )
      ],
    );
    super.initState();

    _initializeStreams();
  }

  _initializeStreams() {
    searchRepo.loading.listen((value) => setState(() {
          this.isLoading = value;
        }));
  }

  _changeWidget() {
    if (_isSearch) {
      setState(() {
        _isSearch = false;
        _appBar = AppBar(
          title: Text("Messaging app"),
          actions: <Widget>[
            IconButton(
              onPressed: _changeWidget,
              icon: Icon(
                Icons.search,
              ),
            )
          ],
        );
      });
    } else {
      setState(() {
        _isSearch = true;
        _appBar = AppBar(
          automaticallyImplyLeading: false,
          title: Form(
            key: key,
            child: TextFormField(
              validator: (a) {
                if (a.length < 4) {
                  return "Enter a valid U-id Key";
                }
                return null;
              },
              onSaved: (value) {
                setState(() {
                  searchUid = value;
                });
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(20.0),
                hintText: "Search your friends U-id here...",
                hintStyle: TextStyle(color: iconColor),
                border: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                if (key.currentState.validate()) {
                  key.currentState.save();
                  print(
                      " in search the value of uid : " + searchUid.toString());
                  bool exists = await searchRepo.checkIfUserExists(searchUid);
                  if (exists != true) {
                    errorText = "Check the U-id and try again";
                  }
                  if (exists) {
                    int result = await searchRepo.getConfirmedUser(searchUid);
                    if (result == 0) {
                      setState(() {
                        errorText = "Don't find yourself";
                      });
                    }
                  }
                }
              },
              icon: Icon(
                Icons.search,
              ),
            ),
            IconButton(
              onPressed: _changeWidget,
              icon: Icon(
                Icons.close,
              ),
            ),
          ],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: DrawerBuilder(),
      appBar: _appBar,
      body: _getMainWidget(),
    );
  }

  _getMainWidget() {
    if (!_isSearch) {
      return StreamBuilder(
        stream: mainRepo.getStream(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          print("new dat dound");
          if (snapshot.hasData) {
            return _buildMainWidget(snapshot.data);
          } else if (snapshot.hasError) {
            return Center(
              child: Text(" child text "),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    } else {
      return StreamBuilder(
          stream: searchRepo.searchResult.stream,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.hasData) {
                return SearchResultTileBuilder(snapshot.data);
              } else if (!snapshot.hasData) {
                return ListView(
                  children: <Widget>[
                    Container(
                      height: 0.8 * height,
                      child: SvgPicture.asset("assets/search.svg"),
                    ),
                    Center(child: Text(errorText)),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                );
              } else {
                return Text(" id k ");
              }
            }
          });
    }
  }

  itemBuilder(DocumentSnapshot snapshot, int index) {
    User user;
    GroupModel model = GroupModel.fromJson(snapshot.data);
    var secondUserId = _getSecondMemberId(model);

    return StreamBuilder<Object>(
        stream: mainRepo.getUserStream(secondUserId),
        builder: (context, snapshot) {
          print("user update found ");
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
                  return Container();
                }
              },
            );
          } else {
            return Container(
              color: Colors.red,
            );
          }
        });
  }

  StreamBuilder _buildUserTileStreamBuilder(
      GroupModel model, String documentId, User user, int index) {
    return StreamBuilder(
        stream: messageRepo.getLastMessage(model, documentId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            QuerySnapshot querySnapshot = snapshot.data;
            if (querySnapshot.documents.length > 0) {
              Message message = Message.fromSnapshot(
                  querySnapshot.documents[querySnapshot.documents.length - 1]);
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                child: Dismissible(
                  onDismissed: (v) {
                    messageRepo.deleteGroup(model);
                  },
                  direction: DismissDirection.startToEnd,
                  background: Container(
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
                      width: 0.95 * width,
                      height: 0.1 * height,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 5.0,
                              color: Colors.black38.withOpacity(0.2),
                              offset: Offset(0.0, 3.0),
                              spreadRadius: 2.0)
                        ],
                      ),
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: 5.0,
                            bottom: 5.0,
                            left: 0.225 * width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  user.userName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: textColor),
                                ),
                                Text(
                                  message.message,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontFamily:
                                          GoogleFonts.openSans().fontFamily,
                                      fontSize: 15,
                                      color: message.isSeen
                                          ? textColor
                                          : textColor),
                                ),
                              ],
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15.0),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          MessagePage(model)));
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            left: 5.0,
                            top: 5.0,
                            bottom: 5.0,
                            child: Hero(
                              tag: user.imageUrl,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          ImageFullScreen(user.imageUrl)));
                                },
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(user.imageUrl),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  _showNewMessageIcon(Message message) {
    if (message.idFrom == sharedPrefs.getValueFromSharedPrefs('uid')) {
      return Theme.of(context).cardColor;
    } else {
      if (message.isSeen) {
        return Theme.of(context).cardColor;
      } else {
        return accentColor;
      }
    }
  }

  _buildTextWithoutAnyMessage(User user, GroupModel model) {
    print("\n THe Image url : ${user.imageUrl} \n");
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Dismissible(
        onDismissed: (v) {
          messageRepo.deleteGroup(model);
        },
        direction: DismissDirection.startToEnd,
        background: Container(
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
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                    blurRadius: 5.0,
                    color: Colors.black38.withOpacity(0.2),
                    offset: Offset(0.0, 3.0),
                    spreadRadius: 2.0)
              ]),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 5.0,
                bottom: 5.0,
                left: 0.225 * width,
                child: Text(
                  user.userName,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: textColor),
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MessagePage(model)));
                    },
                  ),
                ),
              ),
              Positioned(
                left: 5.0,
                top: 5.0,
                bottom: 5.0,
                child: Hero(
                  tag: user.imageUrl,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ImageFullScreen(user.imageUrl)));
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(user.imageUrl),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    return ListView.builder(
      itemBuilder: (context, index) {
        return itemBuilder(data.documents[index], index);
      },
      itemCount: data.documents.length,
    );
  }
}
