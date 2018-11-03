import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:teatime/items/subreddit/tile.dart';
import 'package:teatime/screens/general/loading_screen.dart';
import 'package:teatime/screens/general/retry.dart';
import 'package:teatime/utils/redditViewModel.dart';

class TrendingSubreddits extends StatefulWidget {
  @override
  _TrendingSubredditsState createState() => _TrendingSubredditsState();
}

class _TrendingSubredditsState extends State<TrendingSubreddits> {
  @override
  Widget build(BuildContext context) {
    var redditState = RedditProvider.of(context);
    return FutureBuilder(
      future: redditState.getTrendingSubreddits(),
      builder: (BuildContext context, AsyncSnapshot<List<Subreddit>> snapshot) {
        if (snapshot.hasError) {
          return RetryWidget(
            onTap: () {
              setState(() {});
            },
            message: Text(snapshot.error.toString()),
          );
        }
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            return LoadingScreen();
            break;
          case ConnectionState.waiting:
            return LoadingScreen();
            break;
          case ConnectionState.done:
            var subreddits = snapshot.data;
            if (subreddits != null) {
              return ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                      accountName: Text("Trending Subreddits"),
                      accountEmail: null)
                ]..addAll(subreddits.map((Subreddit sub) {
                    return SubredditTile(
                      subreddit: sub,
                      onTap: () => redditState.changeSubreddit(context, sub),
                    );
                  }).toList()),
              );
            } else {
              return RetryWidget(
                message: Text("No subreddits found"),
                onTap: () {
                  setState(() {});
                },
              );
            }
            break;
          default:
            return RetryWidget(
              onTap: () {
                setState(() {});
              },
            );
        }
      },
    );
  }
}
