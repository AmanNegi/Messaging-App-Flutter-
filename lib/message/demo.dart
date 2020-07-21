import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messaging_app_new/consts/theme.dart';
import 'package:messaging_app_new/message/demoDetail.dart';
import 'package:shimmer/shimmer.dart';

class DemoPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  DemoPage(this.scaffoldKey);
  @override
  _DemoPageState createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  var height, width;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Container(
      color: Theme.of(context).canvasColor,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Shimmer.fromColors(
                direction: ShimmerDirection.ltr,
                period: Duration(seconds: 5),
                child: Container(
                  color: Colors.red,
                ),
                baseColor: AppTheme.shimmerBaseColor,
                highlightColor: AppTheme.shimmerEndingColor),
          ),
          Positioned.fill(
            child: Column(
              children: <Widget>[
                Spacer(),
                /* Center(
                  child: Text(
                    "Demo",
                    style: GoogleFonts.abrilFatface(fontSize: 25),
                  ),
                ), */
                _buildSentMessage(false, 'Unseen sent message', '4:11 PM'),
                _getReceivedMessage('Received message', '4:12 PM'),
                _buildSentMessage(true, 'Seen sent message', '4:13 PM'),
                _buildSentMessage(true,
                    'DoubleTap on a message\n to view details', '4:14 PM'),
                Spacer(),
                Center(
                  child: Text(
                    "Try sending a message...",
                    style: TextStyle(
                        fontSize: 25,
                        fontFamily: GoogleFonts.poiretOne().fontFamily),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildSentMessage(var isSeen, String text, String time) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Stack(
              children: <Widget>[
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  constraints: BoxConstraints(maxWidth: width * 0.7),
                  padding: EdgeInsets.only(
                    top: 15.0,
                    left: 15.0,
                    right: 10.0,
                    bottom: 5.0,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                      color: isSeen
                          ? AppTheme.isSeen.withOpacity(0.7)
                          : Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 2.0,
                            color: isSeen
                                ? AppTheme.isSeen.withOpacity(0.1)
                                : AppTheme.notSeen.withOpacity(0.1),
                            offset: Offset(0.0, 3.0),
                            spreadRadius: 1.0)
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        text,
                        style: TextStyle(
                            color: isSeen
                                ? AppTheme.seenTextColor
                                : AppTheme.notSeenTextColor),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(time,
                          style: TextStyle(
                              color: isSeen
                                  ? AppTheme.seenTimeColor
                                  : AppTheme.notSeenTimeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                      onTap: () {
                        widget.scaffoldKey.currentState.showSnackBar(SnackBar(
                          backgroundColor: Theme.of(context).cardColor,
                          content: Text("Double tap to see details",
                              style: TextStyle(color: AppTheme.textColor)),
                        ));
                      },
                      onDoubleTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DemoDetail(
                              isSeen: isSeen,
                              message: text,
                              time: time,
                              scaffoldKey: widget.scaffoldKey,
                            ),
                          ),
                        );
                      },
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

  _getReceivedMessage(String text, String time) {
    return Container(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 5.0,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(20.0),
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                constraints: BoxConstraints(maxWidth: width * 0.7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(20.0),
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  color: AppTheme.notSeen.withOpacity(0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(20.0),
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                        ),
                        padding: EdgeInsets.only(
                          top: 15.0,
                          left: 10.0,
                          right: 15.0,
                          bottom: 5.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              text,
                              style: TextStyle(
                                  color: AppTheme.receivedMessageTextColor),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(time,
                                style: TextStyle(
                                    color: AppTheme.receivedTimeColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900))
                          ],
                        ),
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20.0),
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                            onDoubleTap: () {},
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
