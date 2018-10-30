import 'package:teatime/items/general/general.dart';
import 'package:teatime/items/items.dart';
import 'package:teatime/items/post/thumbnail.dart';
import 'package:teatime/items/subreddit/icon_builder.dart';
import 'package:teatime/utils/enums.dart';
import 'package:teatime/utils/redditBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostSummary extends StatefulWidget {
  final Submission post;

  PostSummary({@required this.post});

  @override
  _PostSummaryState createState() => _PostSummaryState();
}

class _PostSummaryState extends State<PostSummary> {
  RedditBloc redditState;
  final greyTextTheme = TextStyle(color: Colors.grey);
  bool showActionBar = false;

  @override
  Widget build(BuildContext context) {
    redditState = RedditProvider.of(context);
    Submission post = widget.post;
    bool isClicked = redditState.preferences.isClicked(post);
    return Opacity(
      opacity: !isClicked ? 1.0 : 0.5,
      child: InkWell(
          onLongPress: () {
            setState(() {
              showActionBar = !showActionBar;
            });
          },
          onTap: () => redditState.clickPost(context, post),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: post.subreddit != null &&
                                              !redditState
                                                  .isCurrentSub(post.subreddit)
                                          ? ClipRect(
                                              child: LinkAble(
                                                target: post.subreddit,
                                                targetString:
                                                    post.subreddit.path.trim(),
                                                targetType:
                                                    TargetType.Subreddit,
                                              ),
                                            )
                                          : Container(
                                              width: 0.0,
                                              height: 0.0,
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, top: 8.0),
                                      child: LinkAble(
                                        target: post.author,
                                        targetType: TargetType.User,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
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
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("${post.title}"),
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
                showActionBar
                    ? ActionMenu(
                        voteable: post,
                      )
                    : Container()
              ],
            ),
          )),
    );
  }
}
