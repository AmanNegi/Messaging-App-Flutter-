import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:messaging_app_new/message/messageRepo.dart';
import 'package:url_launcher/url_launcher.dart';
import '../message/message.dart';
import '../consts/theme.dart';

class MessageDetail extends StatelessWidget {
  Message message;
  var documentId;
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
            color: textColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          _buildMainWidget(context),
          Divider(),
          _buildColorContainer(isSeen.withOpacity(0.7), "Seen color"),
          _buildColorContainer(notSeen, "Unseen color"),
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
          minWidth: 0.9 * width,
          height: 0.075 * height,
          child: FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            color: accentColor,
            onPressed: () {
              if (message.type == 0) {
                messageRepo.deleteMessage(message);
                Navigator.of(context).pop();
              } else {
                messageRepo.deleteImage(documentId, message);
                Navigator.of(context).pop();
              }
            },
            child: Text(
              "Delete message?",
              style: TextStyle(
                  color: buttonTextColor, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );
    }
    return Container();
  }

  _buildColorContainer(Color color, String text) {
    return Container(
      height: 50,
      width: width,
      decoration: BoxDecoration(color: color),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(text),
        ),
      ),
    );
  }

  _buildCustomText(String boldText, String normalText) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
            text: boldText,
            style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
        TextSpan(text: normalText, style: TextStyle(color: textColor))
      ]),
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
                  top: 15.0,
                  left: 15.0,
                  right: 10.0,
                  bottom: 5.0,
                ),
                color: message.isSeen ? isSeen.withOpacity(0.7) : notSeen,
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
                        style: GoogleFonts.aBeeZee(
                            color: timeColor,
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
        padding: const EdgeInsets.only(left: 10.0, top: 10.0),
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
                padding: EdgeInsets.only(
                  top: 15.0,
                  left: 10.0,
                  right: 15.0,
                  bottom: 5.0,
                ),
                color: message.isSeen ? isSeen.withOpacity(0.7) : notSeen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    buildTextWithLinks(message.message),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(_getFormattedDate(message.date, 'jms'),
                        style: GoogleFonts.aBeeZee(
                            color: Colors.white54, fontSize: 10))
                  ],
                ),
              ),
            ],
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
    children: linkify(textToLink), style: GoogleFonts.aBeeZee(fontSize: 16.0)));

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
      child: Text(text,
          style: GoogleFonts.abel(
              fontSize: 16.0,
              decoration: TextDecoration.underline,
              color: linkColor)),
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
