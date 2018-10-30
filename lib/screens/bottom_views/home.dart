import 'dart:async';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:teatime/items/general/general.dart';
import 'package:teatime/items/post/summary.dart';
import 'package:teatime/items/subreddit/sidebar.dart';
import 'package:teatime/items/subreddit/tile.dart';
import 'package:teatime/utils/enums.dart';
import 'package:teatime/utils/listingBloc.dart';
import 'package:teatime/utils/redditBloc.dart';
//import 'package:fluttertoast/fluttertoast.dart';

class HomeWidget extends StatefulWidget {
  final dynamic subreddit;
  final RedditBloc redditState;

  const HomeWidget({Key key, this.subreddit, this.redditState})
      : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with RouteAware {
  bool isBackPressed = false;
  static List<String> ignoredSubreddits = ["all", "popular"];
  RedditBloc redditState;
  Subreddit currentSubreddit;
  Subreddit previousSubreddit;
  SupportedSortTypes sortingType;

  @override
  void initState() {
    super.initState();
    redditState = widget.redditState;
    redditState?.snackBarStream?.listen((String value) =>
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(value))));
  }

  Widget currentSubredditHeader() {
    return StreamBuilder<String>(
      stream: redditState.listingBloc.endpointStream,
      initialData: redditState.listingBloc.endpoint,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        try {
          return Text(
            snapshot.data == "/"
                ? "Home Page"
                : snapshot.data.substring(2, snapshot.data.length - 1),
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.title.fontSize - 2),
          );
        } catch (e) {
          return Text("Home Page");
        }
      },
    );
  }

  Widget currentSortHeader() {
    return StreamBuilder<SupportedSortTypes>(
      stream: redditState.preferences.currentSortStream,
      initialData: redditState.preferences.currentSort,
      builder:
          (BuildContext context, AsyncSnapshot<SupportedSortTypes> snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data.toString().split(".")[1],
              style: TextStyle(
                  fontSize: 12.0, color: Theme.of(context).accentColor));
        } else {
          return Text("");
        }
      },
    );
  }

  Widget buildAppBar() {
    return new SliverAppBar(
      snap: true,
      floating: true,
      title: InkWell(
        onTap: () => Navigator.pushNamed(context, "/search"),
        child: new Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                currentSubredditHeader(),
                currentSortHeader(),
              ],
            )),
      ),
      leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer()),
      actions: <Widget>[
        new IconButton(
          icon: Icon(Icons.keyboard_arrow_up),
          onPressed: redditState.listingBloc.jumpToTop,
          tooltip: "Go to Top",
        ),
        new IconButton(
          icon: Icon(Icons.clear_all),
//          onPressed: () => redditState.clearRead(),
          tooltip: "Clear Read", onPressed: redditState.listingBloc.clearRead,
        ),
        new PopupMenuButton(
          icon: Icon(Icons.sort),
          tooltip: "Sort Menu",
          onSelected: (SupportedSortTypes sort) =>
              redditState.preferences.currentSort = sort,
          itemBuilder: (BuildContext context) {
            List<PopupMenuEntry<SupportedSortTypes>> items = [];
            SupportedSortTypes.values
                .forEach((SupportedSortTypes type) => items.add(PopupMenuItem(
                      child: Text(type.toString().split(".")[1]),
                      value: type,
                    )));
            return items;
          },
        ),
      ],
    );
  }

  Future<void> manageBackPressed() async {
    isBackPressed = true;
//    Fluttertoast.showToast(
//        msg: "Press BACK again to exit",
//        toastLength: Toast.LENGTH_SHORT,
//        textcolor: '#ffffff');
    Future.delayed(Duration(seconds: 2))
        .whenComplete(() => isBackPressed = false);
  }

  Future<bool> manageHistory() async {
    if (isBackPressed) {
      return true;
    }
    try {
      redditState.manageHistory();
      return false;
    } catch (e) {
      manageBackPressed();
      return false;
    }
  }

  Widget buildBody() {
    return ListingBuilder(
      refresh: false,
      listingBloc: redditState.listingBloc,
      builder: (BuildContext context, ListingSnapShot<dynamic> snapshot) {
        return PostSummary(
          post: snapshot.data,
        );
      },
      sliverAppBar: buildAppBar(),
    );
  }

  Widget buildTrending() {
    return new Drawer(
      child: new ListingBuilder(
          builder: (BuildContext context, ListingSnapShot<Subreddit> snapshot) {
            if (snapshot.hasData) {
              return SubredditTile(
                subreddit: snapshot.data,
                onTap: () {
                  redditState
                      .changeSubreddit(context, snapshot.data)
                      .then((_) => Navigator.pop(context));
                },
              );
            }
          },
          listingBloc: ListingBloc(
              redditState: redditState,
              endpoint: "/trending_subreddits",
              isListing: false), sliverAppBar: null,),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: new Scaffold(
          resizeToAvoidBottomPadding: false,
          body: buildBody(),
          endDrawer: new StreamBuilder(
            stream: redditState.currentSubredditStream,
            builder: (BuildContext context, AsyncSnapshot<Subreddit> snapshot) {
              if (redditState.currentSubreddit != null) {
                return SideBar();
              } else {
                return buildTrending();
              }
            },
          ),
        ),
        onWillPop: manageHistory);
  }
}
