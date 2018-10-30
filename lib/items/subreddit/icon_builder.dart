import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:teatime/utils/utils.dart';

class SubredditIcon extends StatelessWidget {
  final SubredditRef subreddit;
  final double radius;
  final VoidCallback onTap;

  const SubredditIcon({Key key, this.subreddit, this.radius, this.onTap})
      : super(key: key);

  Widget defaultIcon() {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        child: Text("r"),
        backgroundColor: Colors.lightBlue,
        radius: radius,
      ),
    );
  }

  Widget subredditIcon(Map<dynamic, dynamic> data) {
    String icon = data['icon_img'];
    if (icon == null || icon.isEmpty) {
      return defaultIcon();
    } else {
      return InkWell(
        onTap: onTap,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(icon),
          radius: radius,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    RedditBloc redditState = RedditProvider.of(context);
    Subreddit data = redditState.loadedSubreddits[subreddit.displayName];
    if (data != null) {
      return subredditIcon(data.data);
    } else {
      return FutureBuilder(
        future: redditState.fetchSubreddit(subreddit),
        builder: (BuildContext context, AsyncSnapshot<Subreddit> snapshot) {
          if (snapshot.hasData) {
            return subredditIcon(snapshot.data.data);
          } else {
            return defaultIcon();
          }
        },
      );
    }
  }
}
