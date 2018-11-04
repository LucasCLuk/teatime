import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:teatime/items/general/general.dart';
import 'package:teatime/items/post/content.dart';
import 'package:teatime/items/post/forest.dart';
import 'package:teatime/items/post/locked.dart';
import 'package:teatime/items/post/nsfw.dart';
import 'package:teatime/items/post/spoiler.dart';
import 'package:teatime/items/post/thumbnail.dart';
import 'package:teatime/items/subreddit/icon_builder.dart';
import 'package:teatime/screens/general/compose_comment.dart';
import 'package:teatime/utils/commentBloc.dart';
import 'package:teatime/utils/enums.dart';
import 'package:teatime/utils/redditBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetail extends StatefulWidget {
  final Submission post;

  const PostDetail({Key key, this.post}) : super(key: key);

  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  RedditBloc redditState;
  final ScrollController _scrollController = ScrollController();
  final greyTextTheme = TextStyle(color: Colors.grey);
  CommentBloc commentBloc;

  Widget buildMessage() {
    String content = widget.post.body ?? widget.post.selftext;
    if (content?.isNotEmpty == true) {
      return Card(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Content(
                content: content,
              ),
            )
          ],
        ),
      );
    } else {
      return Container(width: 0.0, height: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    var post = widget.post;
    commentBloc = CommentBloc(submission: post);
    redditState = RedditProvider.of(context);
    return Dismissible(
      key: Key(post.subreddit.displayName),
      onDismissed: (_) => Navigator.pop(context),
      direction: DismissDirection.startToEnd,
      child: new Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: new AppBar(
            automaticallyImplyLeading: true,
            title: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text("Comments"),
                ),
                StreamBuilder<String>(
                  stream: commentBloc.currentSortStream,
                  initialData: "Best",
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(snapshot.data,
                            style:
                                TextStyle(color: Colors.grey, fontSize: 18.0)),
                      );
                    } else {
                      return Container(
                        width: 0.0,
                        height: 0.0,
                      );
                    }
                  },
                )
              ],
            ),
            actions: <Widget>[
//          IconButton(icon: Icon(Icons.search), onPressed: null),
              PopupMenuButton(
                itemBuilder: (BuildContext context) {
                  return commentBloc.sortTypes
                      .map((String sort) => PopupMenuItem(
                            child: Text(sort),
                            value: commentBloc.sortTypes.indexOf(sort),
                          ))
                      .toList();
                },
                icon: Icon(Icons.filter_list),
                onSelected: (dynamic value) => commentBloc.changeSort(value),
              )
            ],
          ),
          body: new Scrollbar(
            child: new Padding(
              padding: const EdgeInsets.all(3.0),
              child: new ListView(
                controller: _scrollController,
                padding: EdgeInsets.only(bottom: 100.0),
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  SubredditIcon(subreddit: post.subreddit),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: post.subreddit != null &&
                                                !redditState.isCurrentSub(
                                                    post.subreddit)
                                            ? LinkAble(
                                                target: post.subreddit,
                                                targetString:
                                                    post.subreddit.path.trim(),
                                                targetType:
                                                    TargetType.Subreddit,
                                              )
                                            : Container(
                                                width: 0.0,
                                                height: 0.0,
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: LinkAble(
                                          target: post.author,
                                          targetType: TargetType.User,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: GildedTile(post: post),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, right: 8.0, bottom: 8.0),
                          child: Thumbnail(
                            isDetailScreen: true,
                            submission: post,
                          ),
                        ),
                      ),
                    ],
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SpoilerTile(
                          isSpoiler: post.spoiler,
                        ),
                        NSFWTile(
                          isOver18: post.over18,
                        ),
                        LockedTile(
                          isLocked: post.locked,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.arrow_upward,
                              color: post.vote == VoteState.upvoted
                                  ? Colors.orange
                                  : Theme.of(context).iconTheme.color,
                            ),
                            Text("${post.upvotes}"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("${post.numComments} Comments"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          timeago.format(post.createdUtc, locale: "en_short"),
                          style: greyTextTheme,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("${post.title}"),
                  ),
                  Divider(),
                  buildMessage(),
                  new ActionMenu(
                    voteable: post,
                  ),
                  new Divider(),
                  CommentForestWidget(
                      key: Key(post.id), commentBloc: commentBloc)
                ],
              ),
            ),
          ),
          bottomSheet: redditState.isLoggedIn
              ? new Container(
                  width: double.infinity,
                  height: 50.0,
                  child: new Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 12.0, top: 3.0, right: 12.0),
                          child: InkWell(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ComposeComment(
                                          submission: post,
                                        ))),
                            child: Container(
                              height: 30.0,
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 3.0),
                                    child: Text("Add a comment"),
                                  )),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).disabledColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0))),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Container(
                  width: 0.0,
                  height: 0.0,
                )),
    );
  }
}
