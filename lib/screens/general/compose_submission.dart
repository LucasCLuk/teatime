import 'dart:async';

import 'package:teatime/items/general/general.dart';
import 'package:teatime/screens/screens.dart';
import 'package:teatime/utils/utils.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

enum SubmissionTypes { link, self, image, video, videogif }

class ComposeSubmission extends StatefulWidget {
  final Submission submission;
  final SubmissionTypes submissionType;
  final Subreddit subreddit;

  const ComposeSubmission(
      {Key key, this.submission, this.submissionType, this.subreddit})
      : super(key: key);

  @override
  _ComposeMessageState createState() => _ComposeMessageState();
}

class _ComposeMessageState extends State<ComposeSubmission> {
  RedditBloc redditState;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final bool done = false;
  final TextEditingController _subredditController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  Subreddit _subreddit;
  bool showError = false;
  Map<String, dynamic> options = {
    "sendreplies": true,
    "nsfw": false,
    "spoiler": false,
  };

  void validate() {
    if (_formKey.currentState.validate()) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Submitted")));
    }
  }

  @override
  void initState() {
    super.initState();
    _subredditController.addListener(() {
      if (showError) {
        setState(() {
          showError = false;
        });
      }
    });
    _subredditController.text = widget.submission?.subreddit?.displayName;
    _titleController.text = widget.submission?.title;
    _bodyController.text =
        widget.submission?.body ?? widget.submission?.selftext;
    options['kind'] = widget.submissionType.toString().split(".")[1];
    _subreddit = widget.subreddit;
  }

  void postMessage() async {
    if (_formKey.currentState.validate()) {
      bool confirm = await Dialogs.showConfirmationDialog(context);
      if (confirm == true) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
                  content: LoadingScreen(),
                ));

        await _subreddit.submit(_titleController.text,
            selftext: _bodyController.text,
            nsfw: options['nsfw'],
            sendReplies: options['sendreplies'],
            spoiler: options['spoiler']);
        Navigator.of(context).pop();
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Message Sucessfully posted"),
          action: SnackBarAction(label: "View", onPressed: () {}),
        ));
      }
    }
  }

  void showRules(BuildContext context) async {
    if (_subreddit != null) {
      Dialogs.showRules(context, _subreddit);
    } else {
      setState(() {
        showError = true;
      });
    }
  }

  void manageOptions(String field, bool selection) {
    setState(() {
      options[field] = selection;
    });
  }

  void manageFlair() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text("Flair"),
              title: Text("Set Flair"),
            ));
  }

  Future<List<dynamic>> searchSubreddits(String query) async {
    var endPoint = "/api/subreddit_autocomplete_v2";
    var params = {
      "query": query,
      "include_over_18": "${!redditState.preferences.filterNSFW}",
      "include_profiles": "${false}",
      "include_categories": "${false}",
      "limit": "3",
    };
    Map<String, dynamic> response =
        await redditState.reddit.get(endPoint, params: params);
    return response.remove("listing");
  }

  String validateURL(String input) {
    RegExp regExp = RegExp(
        "https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)");
    if (regExp.hasMatch(input)) {
      return null;
    } else {
      return "Enter a valid URL";
    }
  }

  String validateSelf(String input) {
    if (input.isNotEmpty) {
      return null;
    }
    return "";
  }

  Widget buildBody() {
    switch (widget.submissionType) {
      case SubmissionTypes.self:
        return buildSelf();
      case SubmissionTypes.link:
        return buildLink();
      default:
        return Container();
    }
  }

  Widget buildSelf() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
          controller: _bodyController,
          validator: validateSelf,
          maxLines: null,
          decoration: InputDecoration(
              hintText: "Type your message", border: InputBorder.none)),
    );
  }

  Widget buildLink() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
          controller: _bodyController,
          validator: validateURL,
          maxLines: null,
          decoration: InputDecoration(
              hintText: "Enter a valid Link", border: InputBorder.none)),
    );
  }

  @override
  Widget build(BuildContext context) {
    redditState = RedditProvider.of(context);
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.close), onPressed: Navigator.of(context).pop),
          title: Text("Create Post"),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.send), onPressed: postMessage)
          ],
        ),
        body: new Form(
            key: _formKey,
            child: new Stack(
              children: <Widget>[
                new ListView(
                  padding: EdgeInsets.only(bottom: 100.0),
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                      child: new Row(
                        children: <Widget>[
                          Expanded(
                            child: SearchSubredditWidget(
                              subreddit: widget.subreddit,
                              onFind: (subreddit) {
                                _subreddit = subreddit;
                                _subredditController.text =
                                    subreddit.displayName;
                              },
                            ),
                          ),
                          FlatButton(
                              onPressed: () {
                                showRules(context);
                              },
                              child: Text("RULES"))
                        ],
                      ),
                    ),
                    Divider(),
                    new TextFormField(
                      validator: (String title) =>
                          title.isEmpty ? "Title Cannot be empty" : null,
                      controller: _titleController,
                      decoration: InputDecoration(
                          labelText: "Title", border: InputBorder.none),
                      maxLength: 300,
                    ),
                    Divider(),
                    ExpansionTile(
                      title: Text("Post Options"),
                      children: <Widget>[
                        Container(
                          height: 75.0,
                          width: double.infinity,
                          child: new ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FilterChip(
                                    label: Text("Send Replies to Inbox"),
                                    disabledColor: Colors.blueGrey,
                                    onSelected: (selection) {
                                      manageOptions("sendreplies", selection);
                                    },
                                    selected: options['sendreplies']),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FilterChip(
                                    label: Text("NSFW"),
                                    disabledColor: Colors.blueGrey,
                                    onSelected: (selection) {
                                      manageOptions("nsfw", selection);
                                    },
                                    selected: options['nsfw']),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FilterChip(
                                  label: Text("Spoiler"),
                                  disabledColor: Colors.blueGrey,
                                  onSelected: (selection) {
                                    manageOptions("spoiler", selection);
                                  },
                                  selected: options['spoiler'],
                                ),
                              ),
//                            FilterChip(
//                              label: Text("Set Flair"),
//                              selected: true,
//                              disabledColor: Colors.blueGrey,
//                            )
                            ],
                          ),
                        )
                      ],
                    ),
                    buildBody(),
                  ],
                ),
//              Opacity(
//                opacity: 0.0,
//                child: Align(
//                    alignment: FractionalOffset.bottomCenter,
//                    child: Container(
//                      height: 45.0,
//                      color: Theme
//                          .of(context)
//                          .backgroundColor,
//                      child: ListView(
//                        scrollDirection: Axis.horizontal,
//                        children: List.generate(
//                            50,
//                                (index) =>
//                                Padding(
//                                  padding: EdgeInsets.only(left: 15.0),
//                                  child: Icon(Icons.place),
//                                )),
//                      ),
//                    )),
//              )
              ],
            )));
  }
}
