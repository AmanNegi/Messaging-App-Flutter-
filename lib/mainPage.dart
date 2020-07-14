import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:messaging_app_new/consts/theme.dart';
import 'package:messaging_app_new/data/sharedPrefs.dart';
import 'package:messaging_app_new/mainRepo.dart';
import 'package:messaging_app_new/message/buildErrorPage.dart';
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

  int fabIndex = 1;
  var _isSearch = false;
  var isLoading = false;
  var userExists = false;
  var _appBar;
  var key = GlobalKey<FormState>();
  var height, searchUid, width;
  var currentUid = '';

  List<Map> items = List();
  bool isWorking = true;

  User user;

  @override
  void initState() {
    currentUid = sharedPrefs.getValueFromSharedPrefs('uid');
    _getCurrentUser();
    _appBar = AppBar(
      title: Text("Chats"),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          onPressed: _changeWidget,
          icon: Icon(
            MdiIcons.accountSearch,
          ),
        )
      ],
    );
    super.initState();
    getDataFromApi();
    _initializeStreams();
  }

  _getCurrentUser() async {
    user = await mainRepo.getUserFromUid(currentUid);
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
          title: Text("Chats"),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              onPressed: _changeWidget,
              icon: Icon(
                MdiIcons.accountSearch,
              ),
            )
          ],
        );
      });
    } else {
      setState(() {
        _isSearch = true;
        _appBar = AppBar(
          backgroundColor: Theme.of(context).cardColor,
          automaticallyImplyLeading: false,
          title: Form(
            key: key,
            child: TextFormField(
              validator: (a) {
                if (a.length <= 0) {
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
                hintText: "Type here",
                hintStyle: TextStyle(color: AppTheme.textColor),
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
                  if (fabIndex == 1) {
                    print(" In Uid results --\n");
                    print(" in search the value of uid : " +
                        searchUid.toString());
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
                  } else {
                    var result =
                        await searchRepo.checkUserExistsByUserName(searchUid);
                    if (result == 0) {
                      print(" In name results --\n");
                      setState(() {
                        errorText = "No user found!";
                      });
                    }
                  }
                }
              },
              icon: Icon(
                MdiIcons.searchWeb,
                color: AppTheme.textColor,
              ),
            ),
            IconButton(
              onPressed: () {
                errorText = '';
                _changeWidget();
              },
              icon: Icon(
                MdiIcons.closeCircle,
                color: AppTheme.textColor,
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
      floatingActionButton: _isSearch
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                FloatingActionButton.extended(
                  backgroundColor: Colors.black,
                  heroTag: 'name',
                  onPressed: () {
                    Fluttertoast.showToast(
                        msg: "Filtering on basis of name now");
                    setState(() {
                      fabIndex = 0;
                    });
                  },
                  label: Row(
                    children: <Widget>[
                      Visibility(
                          visible: _isCurrentFabIndex(0),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(MdiIcons.checkboxMarkedCircleOutline,
                                color: Colors.white),
                          )),
                      Text(
                        "Name",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                FloatingActionButton.extended(
                  backgroundColor: Colors.black,
                  onPressed: () {
                    Fluttertoast.showToast(
                        msg: "Filtering on basis of U-Id now");
                    setState(() {
                      fabIndex = 1;
                    });
                  },
                  label: Row(
                    children: <Widget>[
                      Visibility(
                          visible: _isCurrentFabIndex(1),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(MdiIcons.checkboxMarkedCircleOutline,
                                color: Colors.white),
                          )),
                      Text(
                        'Uid',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                )
              ],
            )
          : null,
      body: _getMainWidget(),
    );
  }

  getDataFromApi() async {
    setState(() {
      items = [];
      isWorking = true;
    });
    var snapshot = await mainRepo.getStream();

    List listOfSnapshots = snapshot.documents;

    if (listOfSnapshots.length <= 0) {
      setState(() {
        isWorking = false;
      });
      return;
    }
    var _currentId = sharedPrefs.getValueFromSharedPrefs('uid');

    for (int i = 0; i < listOfSnapshots.length; i++) {
      print("\n---------In Round $i---------------\n");
      var currentSnapShots = listOfSnapshots[i];

      GroupModel _model = GroupModel.fromJson(currentSnapShots.data);
      var secondUserId = _getSecondMemberId(_model, _currentId);
      var user = await mainRepo.getUserFromUid(secondUserId);

      var documentId = await messageRepo.getGroupDocumentId(_model);
      var result = await messageRepo.getLastMessage(_model, documentId);
      bool containsLastMessage;
      Message lastMessage;

      if (result != null) {
        lastMessage = result;
        containsLastMessage = true;
      } else {
        containsLastMessage = false;
      }

      var map = {
        'documentId': documentId,
        'lastMessage': lastMessage != null ? lastMessage.toJson() : null,
        'user': user.toJson(),
        'containsLastMessage': containsLastMessage,
        'model': _model.toJson()
      };
      print(map);
      setState(() {
        items.add(map);
      });
    }
    print(items.length.toString());
    if (mounted) {
      setState(() {
        isWorking = false;
      });
    } else {
      isWorking = false;
    }
  }

  _isCurrentFabIndex(int i) {
    return i == fabIndex;
  }

  _getMainWidget() {
    if (!_isSearch) {
      if (isWorking) {
        //TODO: Show shimmer
        return Center(child: CircularProgressIndicator());
      }
      return Container(
        child: ListView.builder(
          itemBuilder: (context, index) {
            print(" item number $index");
            return _buildItemOfMainPage(items[index]);
          },
          itemCount: items.length,
        ),
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
                if (snapshot.data.length <= 0) {
                  return BuildErrorPage("No items");
                }

                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return SearchResultTileBuilder(snapshot.data[index]);
                  },
                );
              } else if (!snapshot.hasData) {
                return BuildErrorPage(errorText);
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }
          });
    }
  }

  _buildItemOfMainPage(Map data) {
    User user = User.fromJson(data['user']);
    bool containsLastMessage = data['containsLastMessage'] as bool;
    var documentId = data['documentId'];
    GroupModel model = GroupModel.fromJson(data['model']);
    if (containsLastMessage) {
      Message message = Message.fromJson(data['lastMessage']);
      return _buildTextWithMessage(message, model, documentId, user);
    }
    return _buildTextWithoutAnyMessage(user, model);
  }

  _buildTextWithMessage(
      Message message, GroupModel model, var documentId, User user) {
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
            decoration: BoxDecoration(
              color: _showNewMessageIcon(message)
                  ? AppTheme.mainColor.withOpacity(0.4)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                    blurRadius: 4.0,
                    color: _showNewMessageIcon(message)
                        ? AppTheme.mainColor.withOpacity(0.3)
                        : Colors.black38.withOpacity(0.1),
                    offset: Offset(0.0, 3.0),
                    spreadRadius: 3.0)
              ],
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 5.0,
                  bottom: 5.0,
                  left: 0.2 * width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        user.userName,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppTheme.textColor),
                      ),
                      Text(
                        message.message,
                        style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 15,
                            color: message.isSeen
                                ? AppTheme.textColor
                                : AppTheme.textColor),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor:
                          Theme.of(context).canvasColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(15.0),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MessagePage(model, user)));
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
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
                          backgroundImage: NetworkImage(
                            user.imageUrl,
                          ),
                        ),
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
  }

  _showNewMessageIcon(Message message) {
    if (message.idFrom == sharedPrefs.getValueFromSharedPrefs('uid')) {
      return false;
    } else {
      if (!message.isSeen) {
        return true;
      } else {
        return false;
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
          width: 0.95 * width,
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                    blurRadius: 4.0,
                    color: Colors.black38.withOpacity(0.1),
                    offset: Offset(0.0, 3.0),
                    spreadRadius: 3.0)
              ]),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 20.0,
                bottom: 5.0,
                left: 0.195 * width,
                child: Text(
                  user.userName,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppTheme.textColor),
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MessagePage(model, user)));
                    },
                  ),
                ),
              ),
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

  _getSecondMemberId(GroupModel model, var currentUid) {
    String secondUserId;
    List participants = model.participants;
    for (var a in participants) {
      if (a != currentUid) {
        secondUserId = a;
      }
    }
    return secondUserId;
  }
}
