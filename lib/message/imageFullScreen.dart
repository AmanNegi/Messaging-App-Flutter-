import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:messaging_app_new/consts/theme.dart';
import 'package:photo_view/photo_view.dart';

class ImageFullScreen extends StatelessWidget {
  var height, width;
  String imageUrl;
  ImageFullScreen(this.imageUrl);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PhotoView(
            maxScale: 1.5,
            minScale: 0.2,
            enableRotation: false,
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            backgroundDecoration:
                BoxDecoration(color: Theme.of(context).canvasColor),
            imageProvider: NetworkImage(imageUrl),
          ),
          Positioned(
            top: 30,
            left: 5,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor
              ),
              child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color:AppTheme. textColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
