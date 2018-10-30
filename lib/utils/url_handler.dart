class URLHandler {
  final String url;

  final RegExp urlRegex = RegExp(
      "^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\$");
  final RegExp twitchRegex = RegExp("clips?.twitch?.tv");
  final RegExp youtubeRegex = RegExp("youtu?.be");
  final RegExp imageRegex = RegExp("(redd\.it)|(imgur)|(twimg)");
  final RegExp gifRegex = RegExp("gif(v)?");
  final RegExp redditRegex = RegExp("(reddit\.com)");
  final RegExp imgurRegex = RegExp("imgur");

  URLHandler(this.url);

  bool isValidUrl() => urlRegex.hasMatch(url);

  bool isYouTube() {
    if (isValidUrl()) {
      Iterable<Match> matches = urlRegex.allMatches(url);
      for (Match m in matches) {
        if (youtubeRegex.hasMatch(m.group(0))) {
          return true;
        }
      }
    }
    return false;
  }

  bool isReddit() => isValidUrl() && redditRegex.hasMatch(url);

  bool isTwitch() => isValidUrl() && twitchRegex.hasMatch(url);

  bool isExternal() => isTwitch() || isYouTube();

  bool isMedia() => isValidUrl() && imageRegex.hasMatch(url);

  bool isGif() => gifRegex.hasMatch(url);

  bool isImgur() => imgurRegex.hasMatch(url);
}
