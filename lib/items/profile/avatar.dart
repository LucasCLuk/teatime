import 'package:flutter/material.dart';

class ProfileIcon extends StatelessWidget {
  final String iconURL;

  const ProfileIcon({Key key, @required this.iconURL}) : super(key: key);

  Widget buildIcon() {
    if (iconURL != null) {
      return CircleAvatar(backgroundImage: NetworkImage(iconURL));
    } else {
      return CircleAvatar(child: Text("u"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildIcon();
  }
}
