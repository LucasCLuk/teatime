import 'package:flutter/material.dart';

class SpoilerTile extends StatelessWidget {
  final bool isSpoiler;

  const SpoilerTile({Key key, this.isSpoiler = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isSpoiler ? Container(
      width: 100.0,
      height: 20.0,
      child: Center(child: Text("SPOILER")),
      decoration: BoxDecoration(
          color: Color(0xFFFF3838),
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.all(Radius.circular(8.0))),

    ) : Container();
  }
}
