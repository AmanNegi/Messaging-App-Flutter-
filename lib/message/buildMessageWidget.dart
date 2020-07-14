import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messaging_app_new/message/imageFullScreen.dart';
import 'package:messaging_app_new/message/message.dart';
import 'package:intl/intl.dart';
import 'package:messaging_app_new/message/messageDetail.dart';
import 'package:messaging_app_new/message/messageRepo.dart';
import 'package:messaging_app_new/message/receivedMessageDetail.dart';
import 'package:url_launcher/url_launcher.dart';
import '../consts/theme.dart';

class BuildMessageWidget extends StatelessWidget {
  final String currentUserId;
  final String documentId;
  final DocumentSnapshot documentSnapshot;
  final bool isLast;
  BuildMessageWidget(
      this.documentSnapshot, this.currentUserId, this.documentId, this.isLast);

  var width;
  String idTo;
  Message message;
  String date;
  String idFrom;

  @override
  Widget build(BuildContext context) {
    message = Message.fromSnapshot(documentSnapshot);
    date = DateFormat.jm().format(message.date.toLocal());
    idTo = message.idTo;
    idFrom = message.idFrom;
    width = MediaQuery.of(context).size.width;

    print(" is last $isLast");
    if (isLast) {
      if (message.type == 1) {
        return Column(
          children: <Widget>[
            _getImageWidget(context),
            Container(
              color: Colors.transparent,
              height: 20,
            )
          ],
        );
      }
      return Column(
        children: <Widget>[
          _getWidget(context),
          Container(
            color: Colors.transparent,
            height: 20,
          )
        ],
      );
    } else {
      if (message.type == 1) {
        return _getImageWidget(context);
      }
      return _getWidget(context);
    }
  }

  _getImageWidget(BuildContext context) {
    if (idFrom == currentUserId) {
      return Container(
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 5.0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      blurRadius: 6.0,
                      color: message.isSeen
                          ? AppTheme.isSeen.withOpacity(0.3)
                          : AppTheme.notSeen.withOpacity(0.1),
                      offset: Offset(0.0, 5.0),
                      spreadRadius: 1.0)
                ]),
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          constraints: BoxConstraints(maxWidth: width * 0.7),
                          padding: EdgeInsets.only(
                            top: 15.0,
                            left: 15.0,
                            right: 10.0,
                            bottom: 5.0,
                          ),
                          decoration: BoxDecoration(
                            color: message.isSeen
                                ? AppTheme.isSeen.withOpacity(0.7)
                                : Theme.of(context).cardColor,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20.0),
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                ),
                                child: Hero(
                                  tag: message.imageUrl,
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'assets/loading.png',
                                    image: message.imageUrl,
                                    height: 250,
                                    width: 300,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(date,
                                  style: TextStyle(
                                      color: message.isSeen
                                          ? AppTheme.seenTimeColor
                                          : AppTheme.notSeenTimeColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                        child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ImageFullScreen(message.imageUrl)));
                        },
                        onDoubleTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MessageDetail(
                                    message: message,
                                    documentId: documentId,
                                  )));
                        },
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      messageRepo.updateIsSeen(message);
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
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: width * 0.7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20.0),
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                        color: AppTheme.notSeen.withOpacity(0.4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20.0),
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 15.0,
                              left: 10.0,
                              right: 15.0,
                              bottom: 5.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(20.0),
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                  ),
                                  child: Hero(
                                    tag: message.imageUrl,
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'assets/loading.png',
                                      image: message.imageUrl,
                                      height: 250,
                                      width: 300,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(date,
                                    style: TextStyle(
                                        color: AppTheme.receivedTimeColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ImageFullScreen(message.imageUrl)));
                        },
                        onDoubleTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ReceivedMessageDetail(
                                    documentId: documentId,
                                    message: message,
                                  )));
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
  }

  _getWidget(BuildContext context) {
    if (idFrom == currentUserId) {
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
                        color: message.isSeen
                            ? AppTheme.isSeen.withOpacity(0.7)
                            : Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 3.0,
                              color: message.isSeen
                                  ? AppTheme.isSeen.withOpacity(0.3)
                                  : AppTheme.shadowColor.withOpacity(0.1),
                              offset: Offset(0.0, 2.0),
                              spreadRadius: 2.0)
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        buildTextWithLinks(
                            message.message,
                            message.isSeen
                                ? AppTheme.seenTextColor
                                : AppTheme.notSeenTextColor),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(date,
                            style: TextStyle(
                                color: message.isSeen
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
                        splashColor: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                        onTap: () {},
                        onDoubleTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MessageDetail(
                                    message: message,
                                    documentId: documentId,
                                  )));
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
    } else {
      messageRepo.updateIsSeen(message);
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
              child: Stack(
                children: <Widget>[
                  Padding(
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
                        /*  boxShadow: [
                            BoxShadow(
                                blurRadius: 3.0,
                                color: AppTheme.notSeen.withOpacity(0.4),
                                offset: Offset(0.0, 2.0),
                                spreadRadius: 2.0)
                          ] */
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Container(
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
                              buildTextWithLinks(message.message,
                                  AppTheme.receivedMessageTextColor),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(date,
                                  style: TextStyle(
                                      color: AppTheme.receivedTimeColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onDoubleTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ReceivedMessageDetail(
                                    message: message,
                                    documentId: documentId,
                                  )));
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
  }
}

Text buildTextWithLinks(String textToLink, Color color) => Text.rich(TextSpan(
    children: linkify(textToLink),
    style: TextStyle(fontSize: 16.0, color: color)));

Future<void> openUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

const String urlPattern = r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+';
const String emailPattern = r'\S+@\S+';
const String phonePattern = r'[\d-]{9,}';
const String emojiPattern =
    r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])';

final RegExp linkRegExp = RegExp(
    '($urlPattern)|($emailPattern)|($phonePattern)|($emojiPattern)',
    caseSensitive: false);

WidgetSpan buildEmoteComponent(String text) {
  return WidgetSpan(
      child: SelectableText(
    text,
    style: TextStyle(fontSize: 30),
  ));
}

WidgetSpan buildLinkComponent(String text, String linkToOpen) => WidgetSpan(
        child: InkWell(
      child: Text(text,
          style: TextStyle(
              fontSize: 16.0,
              decoration: TextDecoration.underline,
              color: AppTheme.mainColor)),
      onTap: () => openUrl(linkToOpen),
    ));

List<InlineSpan> linkify(String text) {
  final List<InlineSpan> list = <InlineSpan>[];
  final RegExpMatch match = linkRegExp.firstMatch(text);
  if (match == null) {
    list.add(TextSpan(text: text));
    return list;
  }

  if (match.start > 0) {
    list.add(TextSpan(text: text.substring(0, match.start)));
  }

  final String linkText = match.group(0);
  if (linkText.contains(RegExp(urlPattern, caseSensitive: false))) {
    list.add(buildLinkComponent(linkText, linkText));
  } else if (linkText.contains(RegExp(emailPattern, caseSensitive: false))) {
    list.add(buildLinkComponent(linkText, 'mailto:$linkText'));
  } else if (linkText.contains(RegExp(phonePattern, caseSensitive: false))) {
    list.add(buildLinkComponent(linkText, 'tel:$linkText'));
  } else if (linkText.contains(RegExp(emojiPattern, caseSensitive: false))) {
    list.add(buildEmoteComponent(linkText));
  } else {
    throw 'Unexpected match: $linkText';
  }

  list.addAll(linkify(text.substring(match.start + linkText.length)));

  return list;
}
