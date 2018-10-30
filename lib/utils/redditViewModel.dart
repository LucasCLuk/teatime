import 'package:teatime/utils/redditBloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RedditProvider extends InheritedWidget {
  final RedditBloc data;

  RedditProvider({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    return true;
  }

  static RedditBloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(RedditProvider) as RedditProvider)
          .data;
}
