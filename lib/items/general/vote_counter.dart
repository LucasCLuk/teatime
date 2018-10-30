import 'package:flutter/material.dart';



class VoteCounter extends StatefulWidget {
  final int count;

  const VoteCounter({Key key, this.count}) : super(key: key);
  @override
  _VoteCounterState createState() => _VoteCounterState();
}

class _VoteCounterState extends State<VoteCounter> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.count.toString(),style: TextStyle(color: Colors.orange,fontSize: 15.0,fontWeight: FontWeight.bold));
  }
}
