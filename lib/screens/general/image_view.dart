import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:teatime/items/general/video.dart';
import 'package:teatime/screens/general/loading_screen.dart';
import 'package:teatime/utils/dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

class MediaView extends StatelessWidget {
  final String url;
  final bool isVideo;

  const MediaView({Key key, this.url, this.isVideo = false}) : super(key: key);

  void _openInBrowser() async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => Navigator.of(context).pop(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.share),
                onPressed: () =>
                    Dialogs.showMediaShare(context, Uri.dataFromString(url))),
            IconButton(
                icon: Icon(Icons.open_in_browser), onPressed: _openInBrowser)
          ],
        ),
        body: Container(
          child: isVideo
              ? VideoApp(url:url)
              : PhotoView(
                  loadingChild: LoadingScreen(),
                  imageProvider: NetworkImage(url),
                ),
        ),
      ),
      key: Key(url),
    );
  }
}
