import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:teatime/items/post/content.dart';
import 'package:teatime/screens/general/loading_screen.dart';
import 'package:teatime/utils/dialogs.dart';

class ComposeComment extends StatefulWidget {
  final Submission submission;

  const ComposeComment({Key key, this.submission}) : super(key: key);

  @override
  _ComposeCommentState createState() => _ComposeCommentState();
}

class _ComposeCommentState extends State<ComposeComment> {
  TextEditingController bodyController = TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool enabled = true;

  void submit() async {
    bool confirm = await Dialogs.showConfirmationDialog(context);
    if (confirm == true){
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: LoadingScreen(),
          ));
      if (bodyController.text.isEmpty) {
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text("Cannot send a blank message")));
      } else {
        try {
          await widget.submission.reply(bodyController.text);
          _scaffoldKey.currentState
              .showSnackBar(SnackBar(content: Text("Replied Sucessfully")));
          setState(() {
            enabled = false;
          });
        } catch (e) {
        }
        Navigator.pop(context);
      }
    }
  }

  void showMessage() async {
    String content = widget.submission.body ?? widget.submission.selftext;
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text("Previous Message"),
              content: Container(
                width: 300.0,
                height: 500.0,
                child: ListView(
                  children: <Widget>[
                    Text(widget.submission.title),
                    Divider(),
                    content?.isNotEmpty == true
                        ? Content(
                            content: widget.submission.body ??
                                widget.submission.selftext)
                        : Row(
                            children: <Widget>[
                              Center(
                                child: Text("No content"),
                              ),
                            ],
                          )
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.send),
              onPressed: enabled ? () => submit() : null,
            )
          ],
          title: Text("New Comment"),
        ),
        body: ListView(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.submission.title,
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                widget.submission != null
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                            icon: Icon(Icons.arrow_drop_down),
                            onPressed: showMessage))
                    : Container(
                        width: 0.0,
                        height: 0.0,
                      ),
              ],
            ),
            TextField(
              enabled: enabled,
              controller: bodyController,
              maxLines: null,
              decoration: InputDecoration(hintText: "Your Comment"),
            )
          ],
        ));
  }
}
