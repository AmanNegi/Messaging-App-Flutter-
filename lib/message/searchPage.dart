import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mdi/mdi.dart';
import 'package:messaging_app_new/consts/theme.dart';
import 'package:messaging_app_new/message/searchRepo.dart';
import 'package:messaging_app_new/message/searchResultTileBuilder.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var errorText = "";
  var height, width;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  TextEditingController controller;
  var fabIndexSelected = 0;

  @override
  initState() {
    controller = TextEditingController();
    super.initState();
    _initializeStreams();
  }

  _initializeStreams() {
    searchRepo.loading.listen((value) => setState(() {
          this.isLoading = value;
        }));

    controller.addListener(_queryOnBasisOfFab);
  }

  _queryOnBasisOfFab() {
    if (fabIndexSelected == 0) {
      if (controller.text.length >= 4) {
        _queryData();
      }
    } else {
      if (controller.text.length >= 6) {
        _queryData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton.extended(
            heroTag: 'name',
            onPressed: () {
              setState(() {
                fabIndexSelected = 0;
                _queryOnBasisOfFab();
              });
            },
            label: Row(
              children: <Widget>[
                Visibility(
                  visible: fabIndexSelected == 0,
                  child: Icon(
                    Mdi.progressCheck,
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text("Name"),
              ],
            ),
            backgroundColor: Colors.black,
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton.extended(
            heroTag: 'Uid',
            onPressed: () {
              setState(() {
                fabIndexSelected = 1;
                _queryOnBasisOfFab();
              });
            },
            label: Row(
              children: <Widget>[
                Visibility(
                  visible: fabIndexSelected == 1,
                  child: Icon(
                    Mdi.progressCheck,
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text("UiD"),
              ],
            ),
            backgroundColor: Colors.black,
          ),
        ],
      ),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return StreamBuilder(
      stream: searchRepo.searchResult.stream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (!snapshot.hasData || snapshot.data.length <= 0) {
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
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemBuilder: (context, index) {
                return SearchResultTileBuilder(snapshot.data[index]);
              },
              itemCount: snapshot.data.length,
            );
          } else {
            return Text(" id k ");
          }
        }
      },
    );
  }

  _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).canvasColor,
      automaticallyImplyLeading: false,
      title: TextField(
        autofocus: true,
        autocorrect: false,
        controller: controller,
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText:
              "Search your friends ${fabIndexSelected == 0 ? 'name' : 'Uid'} here...",
          hintStyle: TextStyle(color: AppTheme.iconColor),
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: _queryData,
          icon: Icon(
            Mdi.shieldSearch,
            color: AppTheme.iconColor,
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.close,
            color: AppTheme.iconColor,
          ),
        ),
      ],
    );
  }

  _queryData() async {
    if (!(controller.text.length <= 0)) {
      if (fabIndexSelected == 0) {
        bool exists =
            await searchRepo.checkUserExistsByUserName(controller.text);
        if (!exists) {
          setState(() {
            errorText = "Check the name again";
          });
        }
      } else {
        if (controller.text != null) {
          print(" in search the value of uid : " + controller.text.toString());
          bool exists = await searchRepo.checkIfUserExists(controller.text);
          if (exists != true) {
            setState(() {
              errorText = "Check the U-id and try again";
            });
          }
          if (exists) {
            int result = await searchRepo.getConfirmedUser(controller.text);
            if (result == 0) {
              setState(() {
                errorText = "Don't find yourself";
              });
            }
          }
        }
      }
    } else {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).cardColor,
        content: Text(
          "Enter a valid text",
          style: TextStyle(color: AppTheme.textColor),
        ),
      ));
    }
  }
}
