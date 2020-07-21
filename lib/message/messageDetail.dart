import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messaging_app_new/message/messageRepo.dart';
import 'package:url_launcher/url_launcher.dart';
import '../message/message.dart';
import '../consts/theme.dart';

class MessageDetail extends StatelessWidget {
  final Message message;
  final String documentId;
  var width, height;

  MessageDetail({this.message, @required this.documentId});
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.textColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          _buildMainWidget(context),
          SizedBox(
            height: 10,
          ),
          _buildColorContainer(AppTheme.isSeen.withOpacity(0.8), "Seen color",
              AppTheme.buttonTextColor),
          _buildColorContainer(
              Theme.of(context).cardColor, "Unseen color", AppTheme.textColor),
          Spacer(),
          _showOrNotShowDeleteMessage(context),
        ],
      ),
    );
  }

  _buildMainWidget(context) {
    if (message.type == 0) {
      return _buildMessageWidget(context);
    } else {
      return _buildImageWidget(context);
    }
  }

  _showOrNotShowDeleteMessage(context) {
    if (message.message != "This message has been deleted") {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: ButtonTheme(
          minWidth: 0.75 * width,
          height: 0.075 * height,
          child: RaisedButton(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            color: Colors.red,
            onPressed: () {
              if (message.type == 0) {
                messageRepo.deleteMessage(message);
                Navigator.of(context).pop();
              } else {
                messageRepo.deleteImage(documentId, message);
                Navigator.of(context).pop();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.delete_forever,
                  color: AppTheme.buttonTextColor,
                ),
                Text(
                  "Delete message?",
                  style: TextStyle(
                      color: AppTheme.buttonTextColor,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container();
  }

  _buildColorContainer(Color color, String text, Color textColor) {
    return Container(
      height: 50,
      width: width,
      decoration: BoxDecoration(color: color),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }

  _buildImageWidget(context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0, top: 10.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: Stack(
            children: <Widget>[
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                constraints: BoxConstraints(maxWidth: width * 0.7),
                padding: EdgeInsets.only(
                  top: 8.0,
                  left: 8.0,
                  right: 8.0,
                  bottom: 5.0,
                ),
                color: message.isSeen
                    ? AppTheme.isSeen.withOpacity(0.7)
                    : Theme.of(context).cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                      child: Image.network(
                        message.imageUrl,
                        height: 250,
                        width: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(_getFormattedDate(message.date, 'jms'),
                        style: TextStyle(
                            color: message.isSeen
                                ? Colors.white
                                : AppTheme.receivedTimeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              Positioned.fill(
                  child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onDoubleTap: () {},
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  _buildMessageWidget(context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, top: 5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(20.0),
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  blurRadius: 5.0,
                  color: message.isSeen
                      ? AppTheme.isSeen.withOpacity(0.05)
                      : AppTheme.notSeen.withOpacity(0.05),
                  offset: Offset(0.0, 2.0),
                  spreadRadius: 1.0)
            ]),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(20.0),
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                child: Stack(
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(maxWidth: width * 0.7),
                      decoration: BoxDecoration(
                        color: message.isSeen
                            ? AppTheme.isSeen.withOpacity(0.7)
                            : Theme.of(context).cardColor,
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
                          buildTextWithLinks(message.message, message.isSeen),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(_getFormattedDate(message.date, 'jms'),
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 10))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _getFormattedDate(DateTime date, String format) {
    var formatter = new DateFormat(format);
    String formatted = formatter.format(date);
    return formatted;
  }
}

Text buildTextWithLinks(String textToLink, bool isSeen) => Text.rich(TextSpan(
    children: linkify(textToLink),
    style: TextStyle(
        fontSize: 16.0,
        fontFamily: AppTheme.fontFamily,
        color: isSeen ? Colors.white : AppTheme.textColor)));

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
      child: Text(
    text,
    style: TextStyle(fontSize: 30),
  ));
}

WidgetSpan buildLinkComponent(String text, String linkToOpen) => WidgetSpan(
        child: InkWell(
      child: SelectableText(text,
          style: TextStyle(
              fontSize: 16.0,
              decoration: TextDecoration.underline,
              color: AppTheme.linkColor)),
      onTap: () => openUrl(linkToOpen),
    ));

List<InlineSpan> linkify(String text) {
  final List<InlineSpan> list = <InlineSpan>[];
  final RegExpMatch match = linkRegExp.firstMatch(text);
  if (match == null) {
    list.add(TextSpan(
        text: text, style: TextStyle(fontFamily: AppTheme.fontFamily)));
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
