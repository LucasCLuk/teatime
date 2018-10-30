import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

class GildedTile extends StatelessWidget {
  final UserContentInitialized post;
  final double iconSize = 20.0;
  final double leftPadding = 5.0;

  const GildedTile({Key key, @required this.post}) : super(key: key);

  List<Widget> buildRow() {
    var children = <Widget>[];
    var silver = post.silver;
    var gold = post.gold;
    var plat = post.platinum;
    var first = false;
    if (silver > 0) {
      children.add(buildTeaCup(Colors.grey, first ? leftPadding : 0.0));
      children.add(buildAmountText(silver, Colors.grey));
      if (!first) first = true;
    }
    if (gold > 0) {
      children.add(buildTeaCup(Colors.yellow, first ? leftPadding : 0.0));
      children.add(buildAmountText(gold, Colors.yellow));
      if (!first) first = true;
    }
    if (plat > 0) {
      children
          .add(buildTeaCup(Colors.lightGreenAccent, first ? leftPadding : 0.0));
      children.add(buildAmountText(plat, Colors.lightGreenAccent));
      if (!first) first = true;
    }
    return children;
  }

  Widget buildTeaCup(Color color, double padding) {
    return Padding(
      padding: EdgeInsets.only(left: padding),
      child: ImageIcon(
        AssetImage("assets/TeaCup.png"),
        color: color,
        size: iconSize,
      ),
    );
  }

  Widget buildAmountText(int amount, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 3.0),
      child: Text(
        "x$amount",
        style: TextStyle(color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        children: buildRow(),
      ),
    );
  }
}
