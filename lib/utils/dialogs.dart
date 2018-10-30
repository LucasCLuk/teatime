import 'dart:async';

import 'package:teatime/items/general/general.dart';
import 'package:teatime/items/post/content.dart';
import 'package:teatime/items/post/detail.dart';
import 'package:teatime/screens/general/compose_private_message.dart';
import 'package:teatime/utils/utils.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class Dialogs {
  static void showRules(BuildContext context, Subreddit subreddit) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("These are the rules!"),
              content: new FutureBuilder(
                future: subreddit.rules(),
                builder: (context, AsyncSnapshot<List<Rule>> snapshot) {
                  if (snapshot.hasError) {
                    return Container(child: Text(snapshot.error.toString()));
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      if (snapshot.hasData) {
                        return Container(
                          height: 500.0,
                          width: 300.0,
                          child: new ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              Rule rule = snapshot.data[index];
                              return ListTile(
                                contentPadding: EdgeInsets.all(5.0),
                                isThreeLine: true,
                                title: Text(rule.shortName),
                                subtitle: Content(content: rule.description),
                              );
                            },
                          ),
                        );
                      }
                      return Container(
                        width: 150.0,
                        height: 150.0,
                        child: Text("${subreddit.displayName} has no rules"),
                      );
                    default:
                      return CircularProgressIndicator();
                  }
                },
              ),
            ));
  }

  static void reportSubmission(BuildContext context, Submission post) async {
    Rule brokenRule = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("What rule is being broken?"),
              content: new FutureBuilder(
                future: post.subreddit.rules(),
                builder: (context, AsyncSnapshot<List<Rule>> snapshot) {
                  if (snapshot.hasError) {
                    return Container(child: Text(snapshot.error.toString()));
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      if (snapshot.hasData) {
                        return Container(
                          height: 500.0,
                          width: 300.0,
                          child: new ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              Rule rule = snapshot.data[index];
                              return ListTile(
                                contentPadding: EdgeInsets.all(5.0),
                                isThreeLine: true,
                                title: Text(rule.shortName),
                                subtitle: Content(
                                  content: rule.description,
                                ),
                                onTap: () => Navigator.pop(context, rule),
                              );
                            },
                          ),
                        );
                      }
                      return Container(
                        width: 150.0,
                        height: 150.0,
                        child:
                            Text("${post.subreddit.displayName} has no rules"),
                      );
                    default:
                      return CircularProgressIndicator();
                  }
                },
              ),
            ));
    await post.report(brokenRule.description);
    Navigator.pop(context);
  }

  static void crossPost(BuildContext context, Submission post) async {
    Subreddit sub;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SearchSubredditWidget(
                onFind: (subreddit) {
                  sub = subreddit;
                },
              ),
              actions: <Widget>[
                FlatButton.icon(
                    onPressed: () {
                      post.crosspost(sub).then((Submission newSubmission) =>
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PostDetail(
                                        post: newSubmission,
                                      )),
                              ModalRoute.withName("/")));
                    },
                    icon: Icon(Icons.send),
                    label: Text("CrossPost"))
              ],
            ));
  }

  static void showMods(BuildContext context, Subreddit subreddit) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Container(
                height: 500.0,
                width: 300.0,
                child: ListingBuilder(
                  builder:
                      (BuildContext context, ListingSnapShot<Redditor> item) {
                    if (item.hasData) {
                      return ListTile(
                        title: Text(item.data.displayName),
                        trailing: IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ComposePrivateMessage(
                                          redditor: item.data,
                                        )))),
                      );
                    }
                  },
                  listingBloc: ListingBloc(
                      endpoint: "${subreddit.path}/about/moderators",
                      redditState: RedditProvider.of(context)), sliverAppBar: null,
                ),
              ),
            ));
  }

  static void showMediaShare(BuildContext context, Uri target) async {
    String url = target.toString();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(target.toString()),
              content: Scrollable(
                viewportBuilder:
                    (BuildContext context, ViewportOffset position) {
                  return Container(
                    height: 180.0,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.open_in_browser),
                          title: Text("Open in browser"),
                          onTap: () async {
                            if (await canLaunch(url)) {
                              launch(url);
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.share),
                          title: Text("Share link"),
                          onTap: () {
                            Share.share(url);
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.content_copy),
                          title: Text("Copy link"),
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: url));
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ));
  }

  static Future<dynamic> showLoadingDialog(
      BuildContext context, Future future) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              content: CircularProgressIndicator(),
            ));
    var result = await future;
    Navigator.of(context).pop();
    return result;
  }

  static Future<bool> showConfirmationDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text("Confirm"),
              content: Text("Are you sure?"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("No")),
                FlatButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text("Yes"))
              ],
            ));
  }
}
