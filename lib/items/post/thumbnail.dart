import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:teatime/items/general/transparent.dart';
import 'package:teatime/screens/general/image_view.dart';
import 'package:teatime/utils/dialogs.dart';
import 'package:teatime/utils/redditViewModel.dart';
import 'package:teatime/utils/url_handler.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

class Thumbnail extends StatefulWidget {
  final Submission submission;
  final bool isDetailScreen;

  const Thumbnail({Key key, this.submission, this.isDetailScreen = false})
      : super(key: key);

  @override
  _ThumbnailState createState() => _ThumbnailState();
}

class _ThumbnailState extends State<Thumbnail> {
  Uri thumbnailUri;
  Uri submissionUrl;
  double height;

  Uri get url => submissionUrl ?? thumbnailUri;

  @override
  void initState() {
    super.initState();
    submissionUrl = widget.submission?.url;
    try {
      thumbnailUri = widget.submission.preview.first.source.url;
      height = widget.submission.preview.first.source.height.toDouble();
    } catch (e) {}
  }

  Widget generateImage() {
    var _url = thumbnailUri.toString().replaceAll(RegExp("\&amp;s"), "&s");
    return FadeInImage.memoryNetwork(
      placeholder: kTransparentImage,
      image: _url,
    );
  }

  Future<List<dynamic>> getImageUrl() async {
    Uri imageUri = widget.submission.url;
    bool isVideo = false;
    try {
      imageUri = Uri.parse(
          widget.submission.data['media']['reddit_video']["fallback_url"]);
      isVideo = true;
    } catch (e) {
      print(e);
    }
    try {
      imageUri = widget.submission.variants[0]['gif'].resolutions[2].url;
    } catch (e) {
      print(e);
    }
    if (URLHandler(imageUri.toString()).isMedia()) {
      return [imageUri, isVideo];
    } else {
      return [null, false];
    }
  }

  void _onTap() async {
    CustomTabsOption option = CustomTabsOption(
      toolbarColor: Theme.of(context).primaryColor,
      enableDefaultShare: true,
      enableUrlBarHiding: true,
      showPageTitle: true,
      animation: new CustomTabsAnimation.slideIn(),
    );
    URLHandler urlHandler = URLHandler(url.toString());
    if (urlHandler.isExternal()) {
      if (await urlLauncher.canLaunch(urlHandler.url)) {
        await urlLauncher.launch(urlHandler.url);
      }
    } else if (urlHandler.isReddit()) {
      if (widget.isDetailScreen == false)
        RedditProvider.of(context).clickPost(context, widget.submission);
    } else {
      try {
        var mediaUrl = await getImageUrl();
        if (mediaUrl[0] != null) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MediaView(
                    isVideo: mediaUrl[1],
                    url: mediaUrl[0].toString(),
                  )));
        } else {
          await launch(urlHandler.url, option: option);
        }
      } catch (e) {
        print("Error: $e");
      }
    }
    return;
  }

  void _onLongTap() {
    Dialogs.showMediaShare(context, url);
  }

  @override
  Widget build(BuildContext context) {
    if (thumbnailUri != null) {
      return Container(
        height: height > 500 ? 100.0 : null,
        child: InkWell(
          onTap: _onTap,
          onLongPress: _onLongTap,
          child: generateImage(),
        ),
      );
    } else {
      return Container(width: 0.0, height: 0.0);
    }
  }
}
