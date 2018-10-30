import 'package:flutter/material.dart';
import 'package:teatime/items/post/post.dart';
import 'package:teatime/utils/commentBloc.dart';
import 'package:teatime/utils/utils.dart';

class CommentForestWidget extends StatefulWidget {
  final CommentBloc commentBloc;

  const CommentForestWidget({Key key, @required this.commentBloc})
      : super(key: key);

  @override
  _CommentForestWidgetState createState() => _CommentForestWidgetState();
}

class _CommentForestWidgetState extends State<CommentForestWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.commentBloc.loadComments();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.commentBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: widget.commentBloc.isUpdatedStream,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasError) {
          return ListTile(title: Text(snapshot.error.toString()));
        }
        if (snapshot.data == true) {
          return Column(
            children: <Widget>[
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: widget.commentBloc.loadedComments.length,
                itemBuilder: (BuildContext context, int index) {
                  var item = widget.commentBloc.loadedComments[index];
                  return CommentWidget(
                    key: Key(item?.fullname ?? "em"),
                    comment: item,
                    commentBloc: widget.commentBloc,
                  );
                },
              ),
            ],
          );
        } else if (snapshot.data == null &&
            widget.commentBloc.loadedComments.isEmpty) {
          return new Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("No Results Found :("),
                RaisedButton(
                    onPressed: () =>
                        widget.commentBloc.loadComments(refresh: true),
                    child: Text("Retry"))
              ],
            ),
          );
        } else if (snapshot.data == false) {
          return LinearProgressIndicator();
        }
      },
    );
  }
}
