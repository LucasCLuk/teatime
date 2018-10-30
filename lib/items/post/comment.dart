import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:teatime/items/general/gilded.dart';
import 'package:teatime/items/general/linkable.dart';
import 'package:teatime/items/general/menu.dart';
import 'package:teatime/items/general/vote_counter.dart';
import 'package:teatime/items/post/content.dart';
import 'package:teatime/utils/commentBloc.dart';
import 'package:teatime/utils/enums.dart';
import 'package:teatime/utils/utils.dart';
import 'package:timeago/timeago.dart' as timeago;

final Map<int, Color> colors = {
  0: Colors.transparent,
  1: Colors.orange,
  2: Colors.yellow,
  3: Colors.green,
  4: Colors.lightBlue,
  5: Colors.blue[800],
  6: Colors.purple,
  7: Colors.deepPurple,
  8: Colors.pink,
  9: Colors.pink[800],
  10: Colors.red,
  11: Colors.red[800],
};

class CommentWidget extends StatefulWidget {
  final dynamic comment;
  final CommentBloc commentBloc;
  final int depth;

  const CommentWidget(
      {Key key, @required this.comment, this.commentBloc, this.depth = 0})
      : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  dynamic comment;
  int nestLevel;
  bool showActionBar = false;
  double padding;
  bool hasLoadedMoreComments = false;
  bool isLoading = false;
  bool isExpanded = true;

  @override
  void initState() {
    super.initState();
    comment = widget.comment;
    nestLevel = comment is Comment ? comment.depth : widget.depth;
    try {
      padding = nestLevel * 3.0;
    } catch (e) {
      padding = 0.0;
    }
  }

  Widget buildComment() {
    Comment _comment = comment;
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.only(left: padding),
          child: Container(
            decoration: new BoxDecoration(
                border: Border(
                    left: BorderSide(
                        color: colors[nestLevel] ?? colors[0], width: 2.0),
                    bottom: BorderSide(color: Colors.white10, width: 0.5))),
            child: InkWell(
              onTap: () {
                setState(() {
                  showActionBar = !showActionBar;
                });
              },
              onLongPress: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Row(
                      children: <Widget>[
                        new LinkAble(
                          target: _comment.author,
                          targetString: _comment.author,
                          targetType: TargetType.User,
                        ),
                        _comment.isSubmitter
                            ? Icon(Icons.account_circle)
                            : Container(),
                        GildedTile(
                          post: _comment,
                        ),
                        new Expanded(
                            child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: VoteCounter(count: _comment.upvotes),
                            ),
                            Text(timeago.format(_comment.createdUtc,
                                locale: "en_short"))
                          ],
                        ))
                      ],
                    ),
                    new Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Content(
                          content: _comment.body,
                        )),
                    showActionBar
                        ? new ActionMenu(
                            voteable: comment,
                          )
                        : Container()
                  ],
                ),
              ),
            ),
          ),
        ),
        isExpanded ? buildChildren() : Container()
      ],
    );
  }

  Widget buildChildren() {
    if (comment.replies != null) {
      return new ListView.builder(
        itemCount: comment.replies?.length ?? 0,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          var item = comment.replies[index];
          return new CommentWidget(
            comment: item,
            commentBloc: widget.commentBloc,
            depth: item is MoreComments ? nestLevel + 1 : item.depth,
          );
        },
      );
    }
    return Container(
      width: 0.0,
      height: 0.0,
    );
  }

  Widget buildSubComments() {
    List<dynamic> expandedComments =
        widget.commentBloc.subComments[comment.parentId];
    if (comment.children != null && expandedComments != null) {
      return new ListView.builder(
        itemCount: expandedComments.length,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          var item = expandedComments[index];
          return new CommentWidget(
            comment: item,
            commentBloc: widget.commentBloc,
            depth: item is MoreComments ? nestLevel + 1 : item.depth,
          );
        },
      );
    }
    return Container(
      width: 0.0,
      height: 0.0,
    );
  }

  Widget buildLoadMore() {
    return Padding(
        padding: EdgeInsets.only(left: padding),
        child: GestureDetector(
          onTap: loadMore,
          child: Container(
            decoration: new BoxDecoration(
                border: Border(
                    left: BorderSide(
                        color: colors[nestLevel] ?? colors[0], width: 2.0),
                    bottom: BorderSide(color: Colors.white10, width: 0.5))),
            height: 30.0,
            child: comment is MoreComments
                ? Text(
                    "Load ${comment.count ?? comment.children.length} Replies")
                : Text("Load more comments..."),
          ),
        ));
  }

  void loadMore() async {
    setState(() {
      isLoading = true;
    });
    await widget.commentBloc.loadMoreComments(comment);
    setState(() {
      isLoading = false;
      hasLoadedMoreComments = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (comment is Comment) {
      return buildComment();
    } else if (hasLoadedMoreComments) {
      return buildSubComments();
    } else {
      return buildLoadMore();
    }
  }
}
