import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:teatime/items/post/content.dart';
import 'package:teatime/screens/general/loading_screen.dart';
import 'package:teatime/utils/dialogs.dart';

class ComposeReply extends StatefulWidget {
  final Comment comment;

  const ComposeReply({Key key, @required this.comment}) : super(key: key);
  @override
  _ComposeReplyState createState() => _ComposeReplyState();
}

class _ComposeReplyState extends State<ComposeReply> {
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
          await widget.comment.reply(bodyController.text);
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
    String content = widget.comment.body;
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("Previous Message"),
          content: Container(
            width: 300.0,
            height: 500.0,
            child: ListView(
              children: <Widget>[
                Text(widget.comment.author),
                Divider(),
                content?.isNotEmpty == true
                    ? Content(
                    content: widget.comment.body)
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
                    widget.comment.author,
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                widget.comment != null
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
