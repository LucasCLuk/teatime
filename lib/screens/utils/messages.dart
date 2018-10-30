import 'dart:async';

import 'package:teatime/items/profile/message.dart';
import 'package:teatime/utils/redditBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';
import 'package:flutter/material.dart';

// Used for displaying Inbox Messages
class MessageList extends StatefulWidget {
  final String endpoint;

  const MessageList({Key key, this.endpoint}) : super(key: key);

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  bool isLoading = false;
  List<dynamic> results = [];
  ScrollController _scrollController = ScrollController();
  RedditBloc redditState;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onNotification);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_onNotification);
  }

  void _onNotification() {
    if (_scrollController.position.extentAfter < 50 && !isLoading) {
      isLoading = true;
      loadMore().then((moreResults) {
        results.addAll(moreResults);
        isLoading = false;
      });
    }
  }

  Future<List<dynamic>> loadMore() async {
    Map<String, String> _params = {
      "limit": "10",
      "count": "${results.length}",
    };
    if (results.isNotEmpty) {
      _params['after'] = results.last.fullname;
    }
    var _results = await redditState.reddit
        .get("/message/${widget.endpoint}", params: _params);
    return _results['listing'];
  }

  Future<Null> refresh() async {
    results = [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    redditState = RedditProvider.of(context);
    return Scaffold(
      body: new FutureBuilder(
        future: loadMore(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasError) {
            return Container(child: Text(snapshot.error.toString()));
          }
          if (snapshot.hasData) {
            results.addAll(snapshot.data);
          }
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return LinearProgressIndicator();
            case ConnectionState.waiting:
              return LinearProgressIndicator();
            case ConnectionState.active:
              return LinearProgressIndicator();
            case ConnectionState.done:
              return Scrollbar(
                  child: ListView.builder(
                controller: _scrollController,
                itemCount: results.length,
                itemBuilder: (BuildContext context, int index) {
                  return MessageWidget(
                    message: results[index],
                  );
                },
              ));
            default:
              return Center(child: Text("Nothing found"));
          }
        },
      ),
    );
  }
}
