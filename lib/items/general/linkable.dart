import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:teatime/utils/enums.dart';
import 'package:teatime/utils/redditViewModel.dart';

class LinkAble extends StatefulWidget {
  final dynamic target;
  final String targetString;
  final TargetType targetType;
  final Widget child;

  const LinkAble(
      {Key key, this.target, this.targetString, this.targetType, this.child})
      : super(key: key);

  @override
  _LinkAbleState createState() => _LinkAbleState();
}

class _LinkAbleState extends State<LinkAble> {
  @override
  Widget build(BuildContext context) {
    var redditState = RedditProvider.of(context);
    var targetString = widget.targetString ?? widget.target.toString();
    return DefaultTextStyle(
      style: TextStyle(color: Theme
          .of(context)
          .accentColor),
      child: InkWell(
        onTap: () =>
            redditState.goTo(context,
                target: widget.target, type: widget.targetType),
        onLongPress: widget.target is Subreddit
            ? () => redditState.showShareMenu(context, widget.target.url)
            : null,
        child: widget.child ??
            Text(
              targetString.toLowerCase(),
              overflow: TextOverflow.ellipsis,
            ),
      ),
    );
  }
}
