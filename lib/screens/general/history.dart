import 'dart:async';

import 'package:teatime/items/post/summary.dart';
import 'package:teatime/items/subreddit/tile.dart';
import 'package:teatime/screens/general/loading_screen.dart';
import 'package:teatime/utils/redditBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  RedditBloc redditState;


  Future<List<dynamic>> getHistory() async {
    var response = await redditState.reddit.get("/api/info",
        params: {"id": redditState.preferences.clicked.toList().join(",")});
    try {
      return response['listing'];
    } catch (e) {
      return response;
    }
  }

  void clearHistory() async {
    redditState.preferences.clearHistory();
    Scaffold.of(scaffoldKey.currentContext)
        .showSnackBar(SnackBar(content: Text("History Cleared")));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    redditState = RedditProvider.of(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("History"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.clear), onPressed: clearHistory)
        ],
      ),
      body: FutureBuilder(
        future: getHistory(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.data?.isNotEmpty == true) {
            return ListView(
              children: snapshot.data.map((dynamic document) {
                if (document is Subreddit) {
                  return SubredditTile(subreddit: document);
                } else if (document is Submission) {
                  return PostSummary(post: document);
                } else {
                  return Container(
                    width: 0.0,
                    height: 0.0,
                  );
                }
              }).toList(),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Center(child: Text("No history found"));
          } else {
            return LoadingScreen();
          }
        },
      ),
    );
  }
}
