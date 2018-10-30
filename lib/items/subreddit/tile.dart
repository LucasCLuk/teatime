import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

class SubredditTile extends StatelessWidget {
  final Subreddit subreddit;
  final void Function() onTap;
  final Widget trailing;

  const SubredditTile(
      {Key key, @required this.subreddit, this.onTap, this.trailing})
      : super(key: key);

  CircleAvatar buildIcon() {
    var icon = subreddit?.data['icon_img'];
    if (icon == null || icon.toString().isEmpty) {
      return CircleAvatar(
        child: Text("r"),
        backgroundColor: Colors.lightBlue,
      );
    } else {
      return CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(icon));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        child: ListTile(
          onTap: onTap,
          leading: buildIcon(),
          trailing: trailing,
          title: Text(subreddit.displayName),
        ),
      ),
    );
  }
}
