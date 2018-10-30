import 'package:flutter/material.dart';

class ReadAble extends StatefulWidget {
  final Widget child;
  final bool isRead;

  const ReadAble({Key key, @required this.child, @required this.isRead})
      : super(key: key);

  @override
  _ReadAbleState createState() => _ReadAbleState();
}

class _ReadAbleState extends State<ReadAble> {
  @override
  Widget build(BuildContext context) {
    ThemeData _currentTheme = Theme.of(context);
    ThemeData newTheme = _currentTheme.copyWith();
    newTheme.textTheme.apply(
        displayColor: _currentTheme.disabledColor,
        bodyColor: _currentTheme.disabledColor);
    return Theme(
      isMaterialAppTheme: true,
      child: widget.child,
      data: widget.isRead ? newTheme : _currentTheme,
    );
  }
}
