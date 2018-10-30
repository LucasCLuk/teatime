import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:teatime/utils/dialogs.dart';
import 'package:teatime/utils/redditBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';

class ComposePrivateMessage extends StatefulWidget {
  final RedditorRef redditor;

  const ComposePrivateMessage({Key key, this.redditor}) : super(key: key);

  @override
  _ComposePrivateState createState() => _ComposePrivateState();
}

class _ComposePrivateState extends State<ComposePrivateMessage> {
  final GlobalKey<FormState> messageFormKey = GlobalKey();
  final TextEditingController _redditorController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  void validate() async {
    var currentState = messageFormKey.currentState;
    RedditBloc redditState = RedditProvider.of(context);
    bool confirm = await Dialogs.showConfirmationDialog(context);
    if (currentState.validate() && confirm == true) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                content: CircularProgressIndicator(),
              ));
      redditState.reddit
          .redditor(_redditorController.text)
          .message(_titleController.text, _bodyController.text)
          .then((_) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        redditState.showSnackBar("Message sent sucessfully");
      }).catchError((error) => redditState.showSnackBar(error.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Message"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.send), onPressed: validate)
        ],
      ),
      body: Form(
        key: messageFormKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              controller: _redditorController,
              initialValue: widget.redditor?.displayName ?? null,
              decoration: InputDecoration(labelText: "Recipient"),
              validator: (String content) =>
                  content.isEmpty ? "Recipient cannot be blank" : null,
            ),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Title"),
              validator: (String content) =>
                  content.isEmpty ? "Title cannot be blank" : null,
            ),
            TextFormField(
              controller: _bodyController,
              decoration: InputDecoration(labelText: "Message"),
            )
          ],
        ),
      ),
    );
  }
}
