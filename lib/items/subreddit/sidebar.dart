import 'package:teatime/items/post/content.dart';
import 'package:teatime/screens/screens.dart';
import 'package:teatime/utils/utils.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class SideBar extends StatefulWidget {
  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<SideBar> {
  Subreddit subreddit;
  RedditBloc redditState;

  Widget buildHeader() {
    return new DrawerHeader(
        padding: EdgeInsets.fromLTRB(10.0, 20.0, 8.0, 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                subreddit.displayName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    decorationStyle: TextDecorationStyle.wavy),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(subreddit.data['subscribers'].toString()),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text("Subscribers"),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(subreddit.data['active_user_count'].toString()),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text("Active Users"),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      width: 170.0,
                      height: 50.0,
                      decoration: BoxDecoration(border: Border.all()),
                      child: InkWell(
                        onTap: redditState.isLoggedIn
                            ? () async {
                                await redditState.preferences.currentAccount
                                    .toggleSubscription(subreddit);
                                setState(() {});
                              }
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Icon(redditState.preferences.currentAccount
                                    .isSubbed(subreddit)
                                ? Icons.check_box
                                : Icons.check_box_outline_blank),
                            Text(redditState.preferences.currentAccount
                                    .isSubbed(subreddit)
                                ? "Subscribed".toUpperCase()
                                : "Subscribe".toUpperCase())
                          ],
                        ),
                      ),
                    ),
                  ),
//                  FlatButton.icon(
//                      onPressed: () {
//                        subreddit
//                      },
//                      icon: Icon(subreddit.data['user_has_favorited'] == true
//                          ? Icons.star
//                          : Icons.star_border),
//                      label: Text(subreddit.data['user_has_favorited'] == true
//                          ? "Favorited".toUpperCase()
//                          : "Favorite".toUpperCase())),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                        icon: Icon(Icons.more_vert), onPressed: buildDetails),
                  )
                ],
              ),
            ),
          ],
        ));
  }

  void buildDetails() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Container(
                height: 400.0,
                width: 300.0,
                child: ListView(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.edit),
                      title: Text("Create Post"),
                      onTap: redditState.isLoggedIn
                          ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ComposeSubmission(
                                        subreddit: subreddit,
                                        submissionType: SubmissionTypes.self,
                                      )))
                          : null,
                    ),
                    ListTile(
                      leading: Icon(Icons.more),
                      title: Text("Edit Flair"),
                    ),
                    ListTile(
                      leading: Icon(Icons.verified_user),
                      title: Text("View Mods"),
                      onTap: () => Dialogs.showMods(context, subreddit),
                    ),
//TODO figure out how to send a message to mods
//                    ListTile(
//                      leading: Icon(Icons.mail),
//                      title: Text("Message mods"),
//                    ),
                    ListTile(
                      leading: Icon(Icons.insert_link),
                      title: Text("View Wiki"),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Wiki(
                                    subreddit: subreddit,
                                  ))),
                    ),
                    ListTile(
                      leading: Icon(Icons.details),
                      title: Text("View rules"),
                      onTap: () => Dialogs.showRules(context, subreddit),
                    ),
                    ListTile(
                      leading: Icon(Icons.share),
                      title: Text("Share Subreddit"),
                      onTap: () => Share.share("Check out ${subreddit.path}"),
                    ),
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    redditState = RedditProvider.of(context);
    subreddit = redditState.currentSubreddit;
    var data = subreddit?.data['description'];
    return Drawer(
      child: ListView(
        children: <Widget>[
          buildHeader(),
          data != null
              ? Content(content: data,)
              : Container()
        ],
      ),
    );
  }
}
