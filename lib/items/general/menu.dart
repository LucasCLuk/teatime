import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:teatime/screens/general/edit_sent.dart';
import 'package:teatime/screens/screens.dart';
import 'package:teatime/utils/redditBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';
import 'package:teatime/utils/utils.dart';

class ActionMenu extends StatefulWidget {
  final dynamic voteable;

  const ActionMenu({Key key, @required this.voteable})
      : super(key: key);

  @override
  _PostMenuState createState() => _PostMenuState();
}

class _PostMenuState extends State<ActionMenu> {
  RedditBloc redditState;
  Color defaultColor;
  int upvotes;

  @override
  void initState() {
    super.initState();
    upvotes = widget.voteable.upvotes;
  }

  void vote(VoteState vote, {BuildContext context}) async {
    if (!redditState.isLoggedIn) return;
    try {
      if (widget.voteable.vote == vote) {
        await widget.voteable.clearVote();
        upvotes = widget.voteable.upvotes;
      } else {
        if (vote == VoteState.upvoted) {
          await widget.voteable.upvote();
          upvotes += 1;
        } else if (vote == VoteState.downvoted) {
          await widget.voteable.downvote();
          upvotes -= 1;
        }
      }
    } catch (e) {
      if (context != null) {
        Scaffold.of(context,nullOk: true)?.showSnackBar(SnackBar(content: Text("Unable to process request")));
      }
    }
    setState(() {});
  }

  void favorite({BuildContext context}) async {
    if (!redditState.isLoggedIn) return;
    try {
      widget.voteable.saved
          ? await widget.voteable.unsave()
          : await widget.voteable.save();
      widget.voteable.data['saved'] = !widget.voteable.saved;
    } catch (e) {
      if (context != null) {
        Scaffold.of(context,nullOk: true)
            ?.showSnackBar(SnackBar(content: Text("Unable to process request")));
      }
    }
    setState(() {});
  }

  void share() async {
    String url = widget.voteable.data['url'];
    if (!url.contains(RegExp("reddit\.com"))) {
      url = "https://www.reddit.com$url";
    }
    Share.share(url);
  }

  void delete() async {
    if (!redditState.isLoggedIn) return;

    try {
      await widget.voteable.delete();
      if (widget.voteable is UserContent) {
        redditState.refreshSubreddit();
      }
      redditState.showSnackBar("Sucessfully deleted");
    } on DRAWAuthenticationError {
      redditState.showSnackBar("Unable to delete");
    } catch (e) {
      if (context != null) {
        redditState.showSnackBar("Unable to process request");
      }
    }
  }

  dynamic reply() async {
    switch (widget.voteable.runtimeType) {
      case Submission:
        return Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ComposeComment(
                  submission: widget.voteable,
                )));
      case Comment:
        return Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ComposeReply(
                  comment: widget.voteable,
                )));
      case Redditor:
        return Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ComposePrivateMessage(
                  redditor: widget.voteable,
                )));
    }
  }

  void edit() {
    if (redditState.isLoggedIn) return;

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditContentWidget(target: widget.voteable)));
  }

  void goTo() async {}

  void extra() async {
    bool isMe = false;
    if (redditState.isLoggedIn) {
      isMe = widget.voteable.author ==
          redditState.currentAccount.redditor.displayName;
    }
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Container(
                height: 500.0,
                width: 300.0,
                child: ListView(
                  children: <Widget>[
                    isMe
                        ? ListTile(
                            leading: Icon(Icons.edit),
                            onTap: edit,
                            title: Text("Edit Message"),
                          )
                        : Container(
                            height: 0.0,
                            width: 0.0,
                          ),
                    isMe
                        ? ListTile(
                            leading: Icon(Icons.delete),
                            onTap: () => delete(),
                            title: Text("Delete"),
                          )
                        : Container(
                            height: 0.0,
                            width: 0.0,
                          ),
                    widget.voteable is UserContent &&
                            widget.voteable.subreddit != null
                        ? ListTile(
                            leading: Icon(Icons.copyright),
                            title: Text(
                                "Go to ${widget.voteable.subreddit.displayName}"),
                            onTap: () {
                              Navigator.pop(context);
                              redditState.changeSubreddit(
                                  context, widget.voteable.subreddit);
                            },
                          )
                        : Container(),
                    ListTile(
                      leading: Icon(Icons.account_circle),
                      title: Text("About ${widget.voteable.author}"),
                      onTap: () {
                        Navigator.popAndPushNamed(
                            context, "/u/${widget.voteable.author}");
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.check),
                      title: Text("Mark unread"),
                      onTap: redditState.isLoggedIn
                          ? () {
                              redditState.preferences.unRead(widget.voteable);
                            }
                          : null,
                    ),
                    ListTile(
                      leading: Icon(Icons.close),
                      title: Text("Hide"),
                      onTap: redditState.isLoggedIn
                          ? () {
                              widget.voteable.hide();
                              redditState.listingBloc
                                  .hide(post: widget.voteable);
                            }
                          : null,
                    ),
                    ListTile(
                      leading: Icon(Icons.reply),
                      title: Text("Reply"),
                      onTap: redditState.isLoggedIn ? reply : null,
                    ),
//                    ListTile(
//                      leading: Icon(Icons.remove),
//                      title: Text("Hide Previous posts"),
//                    ),
                    ListTile(
                      leading: Icon(Icons.report),
                      title: Text("Report"),
                      onTap: () =>
                          Dialogs.reportSubmission(context, widget.voteable),
                    ),
                    (widget.voteable is Submission) &&
                            (widget.voteable as Submission).isCrosspostable
                        ? ListTile(
                            leading: Icon(Icons.call_split),
                            title: Text("Crosspost"),
                            onTap: () =>
                                Dialogs.crossPost(context, widget.voteable),
                          )
                        : Container(),
//                    ListTile(
//                      leading: Icon(Icons.filter_list),
//                      title: Text("Filter"),
//                      trailing: Icon(Icons.keyboard_arrow_right),
//                    ),
//                    ListTile(
//                      leading: Icon(Icons.content_copy),
//                      title: Text("Copy"),
//                      trailing: Icon(Icons.keyboard_arrow_right),
//                    ),
//                    ListTile(
//                        leading: Icon(Icons.add),
//                        title: Text("Add to multireddit")),
                  ],
                ),
              ),
            ));
  }

  Widget buildSubmissionMenu() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new IconButton(
            icon: Icon(
              Icons.arrow_upward,
              color: widget.voteable.vote == VoteState.upvoted
                  ? Colors.orange
                  : defaultColor,
            ),
            onPressed: () => vote(VoteState.upvoted)),
        new Text("${widget.voteable.upvotes ?? "?"}"),
        new IconButton(
            icon: Icon(
              Icons.arrow_downward,
              color: widget.voteable.vote == VoteState.downvoted
                  ? Colors.purple
                  : defaultColor,
            ),
            onPressed: () => vote(VoteState.downvoted)),
        new IconButton(
            icon: Icon(
              Icons.star,
              color: widget.voteable.saved == true
                  ? Colors.yellow
                  : Theme.of(context).iconTheme.color,
            ),
            onPressed: favorite),
        new IconButton(icon: Icon(Icons.share), onPressed: share),
        new IconButton(icon: Icon(Icons.more_vert), onPressed: extra),
      ],
    );
  }

  Widget buildCommentMenu() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new IconButton(
            icon: Icon(
              Icons.arrow_upward,
              color: widget.voteable.vote == VoteState.upvoted
                  ? Colors.orange
                  : defaultColor,
            ),
            onPressed: () => vote(VoteState.upvoted)),
        new IconButton(
            icon: Icon(
              Icons.arrow_downward,
              color: widget.voteable.vote == VoteState.downvoted
                  ? Colors.purple
                  : defaultColor,
            ),
            onPressed: () => vote(VoteState.downvoted)),
        new IconButton(
            icon: Icon(
              Icons.star,
              color: widget.voteable.saved == true
                  ? Colors.yellow
                  : Theme.of(context).iconTheme.color,
            ),
            onPressed: favorite),
        new IconButton(icon: Icon(Icons.share), onPressed: share),
        new IconButton(icon: Icon(Icons.more_vert), onPressed: extra),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    redditState = RedditProvider.of(context);
    defaultColor = Theme.of(context).iconTheme.color;
    if (widget.voteable is Submission) {
      return buildSubmissionMenu();
    } else if (widget.voteable is Comment) {
      return buildCommentMenu();
    } else {
      return Container(
        width: 0.0,
        height: 0.0,
      );
    }
  }
}
