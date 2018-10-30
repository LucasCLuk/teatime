import 'package:flutter/material.dart';

class RetryWidget extends StatelessWidget {
  final void Function() onTap;
  final Text message;

  const RetryWidget({Key key, this.onTap, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            message ?? Text("No Results Found :("),
            RaisedButton(onPressed: onTap, child: Text("Retry"))
          ],
        ),
      ),
    );
  }
}
