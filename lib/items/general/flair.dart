import 'package:flutter/material.dart';

class FlairTile extends StatelessWidget {
  final String flair;

  const FlairTile({Key key, this.flair}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey, border: Border.all(color: Colors.grey)),
      child: Text(
        flair,
      ),
    );
  }
}
