import 'dart:async';

import 'package:async/async.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teatime/items/profile/profile.dart';
import 'package:teatime/screens/general/loading_screen.dart';
import 'package:teatime/screens/general/retry.dart';
import 'package:timeago/timeago.dart' as timeago;

class About extends StatefulWidget {
  final RedditorRef redditor;

  const About({Key key, this.redditor}) : super(key: key);

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About>
    with AutomaticKeepAliveClientMixin<About> {
  final AsyncMemoizer _usermemoizer = AsyncMemoizer();
  final AsyncMemoizer _trophyMemoizer = AsyncMemoizer();

  // TODO: implement wantKeepAlive
  @override
  bool get wantKeepAlive => true;

  fetchUser() async {
    return _usermemoizer.runOnce(() async => await widget.redditor.reddit
        .redditor(widget.redditor.displayName)
        .populate());
  }

  Future<GridView> buildTrophies(BuildContext context) async {
    var orientation;
    var response = await _trophyMemoizer.runOnce(() async => await widget
        .redditor.reddit
        .get("/api/v1/user/${widget.redditor.displayName}/trophies",
            objectify: false));
    var trophies = response['data']['trophies'];
    try {
      orientation = MediaQuery.of(context).orientation;
    } catch (e) {
      orientation = Orientation.portrait;
    }
    return GridView.builder(
        shrinkWrap: true,
        itemCount: trophies.length,
        physics: ClampingScrollPhysics(),
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (orientation == Orientation.portrait) ? 3 : 4),
        itemBuilder: (context, index) {
          var trophy = trophies[index]['data'];
          return GridTile(
              child: Image.network(
                trophy['icon_70'],
                width: 25.0,
                height: 25.0,
              ),
              footer: Center(child: Text(trophy['name'])));
        });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new FutureBuilder(
      future: fetchUser(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasError) {
          return RetryWidget(
            message: Text(snapshot.error.toString()),
            onTap: () {
              setState(() {});
            },
          );
        }
        if (snapshot.hasData) {
          var redditor = snapshot.data;
          return new ListView(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  children: <Widget>[
                    new Center(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ProfileIcon(
                                iconURL: redditor.data['icon_img'],
                              )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(redditor?.displayName ?? ""),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new Column(
                          children: <Widget>[
                            Text("KARMA"),
                            Text(
                                "${redditor?.commentKarma ?? 0 + redditor?.linkKarma ?? 0}"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(Icons.link),
                                Text("${redditor?.linkKarma ?? 0}"),
                                Icon(Icons.comment),
                                Text("${redditor?.commentKarma ?? 0}")
                              ],
                            )
                          ],
                        ),
                        new Column(
                          children: <Widget>[
                            Text("REDDIT AGE"),
                            Text(timeago.format(redditor?.createdUtc)),
                            Row(
                              children: <Widget>[
                                Icon(Icons.cake),
                                Text(DateFormat.yMMMd()
                                    .format(redditor?.createdUtc))
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    new Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height: 25.0,
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(.5)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text("Trophy Case"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder(
                      future: buildTrophies(context),
                      builder: (BuildContext context,
                          AsyncSnapshot<GridView> snapshot) {
                        if (snapshot.hasError) {
                          return RetryWidget(
                            onTap: () {
                              setState(() {});
                            },
                          );
                        }
                        if (snapshot.hasData) {
                          return snapshot.data;
                        } else {
                          return LoadingScreen();
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          );
        } else {
          return LoadingScreen();
        }
      },
    );
  }
}
