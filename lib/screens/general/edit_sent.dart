import 'package:teatime/utils/redditViewModel.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

class EditContentWidget extends StatefulWidget {
  final dynamic target;

  const EditContentWidget({Key key, @required this.target}) : super(key: key);

  @override
  _EditMessageWidgetState createState() => _EditMessageWidgetState();
}

class _EditMessageWidgetState extends State<EditContentWidget> {
  TextEditingController bodyController = TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool enabled = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    switch (widget.target.runtimeType) {
      case Comment:
        Comment comment = widget.target;
        bodyController.text = comment.body;
        break;
      case Submission:
        Submission submission = widget.target;
        bodyController.text = submission.body ?? submission.selftext;
        break;
    }
  }

  void submit() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CircularProgressIndicator());
    try {
      await widget.target.edit(bodyController.text);
      if (widget.target is UserContent) {
        RedditProvider.of(context)
            .listingBloc
            .refreshSubmission(widget.target);
      }
      Navigator.pop(context);
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text("Editited Sucessfully")));
    } on DRAWAuthenticationError {
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text("Unable to edit")));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: enabled ? () => submit() : null,
          )
        ],
      ),
      body: TextField(
        controller: bodyController,
        maxLines: null,
        autofocus: true,
      ),
    );
  }
}
