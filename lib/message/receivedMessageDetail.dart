import 'package:flutter/material.dart';
import 'package:flutter_clipboard_manager/flutter_clipboard_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../message/message.dart';
import '../consts/theme.dart';

class ReceivedMessageDetail extends StatelessWidget {
  final Message message;
  final String documentId;

  ReceivedMessageDetail({this.message, @required this.documentId});
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: message.type == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                FlutterClipboardManager.copyToClipBoard(message.message);
                Fluttertoast.showToast(
                  msg: 'Copied "${message.message}" to clipboard',
                );
              },
              label: Row(
                children: <Widget>[
                  Icon(MdiIcons.clipboardFileOutline),
                  SizedBox(
                    width: 5,
                  ),
                  Text("Copy Text"),
                ],
              ),
            )
          : null,
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
          _buildMainWidget(context, width),
          Container(),
        ],
      ),
    );
  }

  _buildMainWidget(context, width) {
    if (message.type == 0) {
      return _buildMessageWidget(context, width);
    } else {
      return _buildImageWidget(context, width);
    }
  }

  _buildImageWidget(context, width) {
    return Center(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                      blurRadius: 5.0,
                      color: Colors.black38.withOpacity(0.05),
                      offset: Offset(0.0, 3.0),
                      spreadRadius: 5.0),
                ],
              ),
              constraints: BoxConstraints(maxWidth: width * 0.7),
              padding: EdgeInsets.only(
                top: 8.0,
                left: 8.0,
                right: 8.0,
                bottom: 5.0,
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
                          color: AppTheme.receivedTimeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900)),
                ],
              ),
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
    );
  }

  _buildMessageWidget(context, width) {
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
                  blurRadius: 2.0,
                  color: AppTheme.notSeen.withOpacity(0.05),
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
                        color: Theme.of(context).cardColor,
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
                          buildTextWithLinks(message.message),
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

Text buildTextWithLinks(String textToLink) => Text.rich(TextSpan(
    children: linkify(textToLink),
    style: TextStyle(fontSize: 16.0, fontFamily: AppTheme.fontFamily)));

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
