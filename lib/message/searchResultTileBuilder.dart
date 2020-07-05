import 'package:flutter/material.dart';
import 'package:messaging_app_new/data/sharedPrefs.dart';
import 'package:messaging_app_new/groupModel.dart';
import 'package:messaging_app_new/message/messagePage.dart';
import 'package:messaging_app_new/message/messageRepo.dart';
import 'package:messaging_app_new/user/user.dart';
import '../consts/theme.dart';

class SearchResultTileBuilder extends StatelessWidget {
  final User user;

  SearchResultTileBuilder(this.user);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.0),
        onTap: () async {
          var model = GroupModel(participants: [
            user.uid,
            sharedPrefs.getValueFromSharedPrefs('uid')
          ]);

          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => MessagePage(model)));
        },
        child: Ink(
          height: 0.15 * height,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            color: mainColor.withOpacity(0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(user.imageUrl),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.userName,
                    ),
                    Text(
                      user.uid,
                    ),
                    Text(
                      user.email,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
