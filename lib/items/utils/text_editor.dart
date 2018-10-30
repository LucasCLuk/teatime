import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomTextField extends StatefulWidget {
  final TextField child;

  const CustomTextField({Key key, this.child})
      : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.child..focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.landscape && widget.child.focusNode.hasFocus) {
      return Column(
        children: <Widget>[
          Scrollable(
            viewportBuilder: (BuildContext context, ViewportOffset position) {
              return widget.child;
            },
          )
        ],
      );
    }
    return widget.child;
  }
}
