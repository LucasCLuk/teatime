import 'package:flutter/material.dart';

class LockedTile extends StatelessWidget {
  final bool isLocked;

  const LockedTile({
    Key key,
    this.isLocked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLocked) {
      return Container(
        width: 75.0,
        height: 20.0,
        child: Center(
            child: Text(
              "Locked",
              style: TextStyle(color: Colors.grey),
            )),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
      );
    } else {
      return Container(
        width: 0.0,
        height: 0.0,
      );
    }
  }
}
