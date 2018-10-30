import 'package:flutter/material.dart';

class NSFWTile extends StatelessWidget {
  final bool isOver18;

  const NSFWTile({Key key, this.isOver18 = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isOver18
        ? Container(
      width: 75.0,
      height: 20.0,
      child: Center(child: Text("NSFW")),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.all(Radius.circular(8.0))),

    )
        : Container();
  }
}
