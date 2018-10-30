import 'dart:async';

import 'package:teatime/items/post/summary.dart';
import 'package:teatime/items/subreddit/tile.dart';
import 'package:teatime/items/utils/keep_alive.dart';
import 'package:teatime/screens/general/loading_screen.dart';
import 'package:teatime/utils/redditBloc.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class SearchSubreddit extends StatefulWidget {
  final RedditBloc redditState;

  const SearchSubreddit({Key key, this.redditState}) : super(key: key);

  @override
  _SearchSubredditState createState() => _SearchSubredditState();
}

class _SearchSubredditState extends State<SearchSubreddit>
    with SingleTickerProviderStateMixin {
  final String endPoint = "/api/subreddit_autocomplete_v2";
  Map<String, String> params = {};
  TextEditingController searchController = TextEditingController();
  TabController tabController;
  PublishSubject<int> tabPublishSubject = PublishSubject<int>();
  PublishSubject<String> searchSubject = PublishSubject<String>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    params = {
      "include_over_18": "${!widget.redditState.preferences.filterNSFW}",
      "include_profiles": false.toString(),
      "include_categories": false.toString(),
      "limit": 10.toString(),
    };
  }

  @override
  void dispose() {
    super.dispose();
    tabPublishSubject.close();
    searchSubject.close();
  }

  AppBar buildSearchBar(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color barColor = theme.canvasColor;
    return new AppBar(
      backgroundColor: barColor,
      title: new Directionality(
          textDirection: Directionality.of(context),
          child: new TextField(
            key: new Key('SearchBarTextField'),
            keyboardType: TextInputType.text,
            style: new TextStyle(fontSize: 16.0),
            decoration: new InputDecoration(
                hintText: "Search",
                hintStyle: new TextStyle(fontSize: 16.0),
                border: null),
            onChanged: searchSubject.add,
            autofocus: true,
            controller: searchController,
          )),
      actions: <Widget>[
        // Show an icon if clear is not active, so there's no ripple on tap
        new IconButton(
            icon: new Icon(Icons.clear),
            onPressed: () {
              searchController.clear();
              searchSubject.add(null);
            })
      ],
      bottom: TabBar(controller: tabController, tabs: <Tab>[
        Tab(
          child: Text("Search"),
        ),
        Tab(
          child: Text("Recent"),
        )
      ])
    );
  }

  Widget buildSearchResults() {
    return StreamBuilder(
      stream: searchSubject.stream,
      builder: (BuildContext context, AsyncSnapshot<String> querySnapshot) {
        if (querySnapshot.data?.isNotEmpty == true) {
          params['query'] = querySnapshot.data;
          return FutureBuilder(
              future: widget.redditState.reddit.get(endPoint, params: params),
              builder: (BuildContext context, futureSnapshot) {
                if (futureSnapshot.hasData &&
                    futureSnapshot.connectionState == ConnectionState.done) {
                  return ListView.builder(
                    itemCount: futureSnapshot.data['listing'].length,
                    itemBuilder: (context, index) {
                      var item = futureSnapshot.data["listing"][index];
                      return SubredditTile(
                        subreddit: item,
                        onTap: () =>
                            widget.redditState.changeSubreddit(context, item),
                      );
                    },
                  );
                } else if (futureSnapshot.connectionState ==
                    ConnectionState.done) {
                  return Center(
                    child: Text("No results found"),
                  );
                } else {
                  return LoadingScreen();
                }
              });
        } else if (widget.redditState.isLoggedIn &&
            querySnapshot.data?.isEmpty == true) {
          return ListView.builder(
            itemCount:
                widget.redditState.currentAccount.subscriptionOrder.length,
            itemBuilder: (context, index) {
              String subName =
                  widget.redditState.currentAccount.subscriptionOrder[index];
              Subreddit subreddit =
                  widget.redditState.loadedSubreddits[subName];
              return SubredditTile(subreddit: subreddit);
            },
          );
        } else {
          return Center(
            child: Text("Nothing is here :("),
          );
        }
      },
    );
  }

  Future<List<dynamic>> getHistory() async {
    var response = await widget.redditState.reddit.get("/api/info", params: {
      "id": widget.redditState.preferences.clicked.toList().join(",")
    });
    try {
      return response['listing'];
    } catch (e) {
      return response;
    }
  }

  Widget buildHistory() {
    return FutureBuilder(
      future: getHistory(),
      initialData: List(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.data.isNotEmpty) {
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
        } else {
          return Center(child: Text("No history found"));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildSearchBar(context),
        body: TabBarView(controller: tabController, children: <Widget>[
          KeepAliveWidget(child: buildSearchResults()),
          KeepAliveWidget(
            child: buildHistory(),
          )
        ]));
  }
}
