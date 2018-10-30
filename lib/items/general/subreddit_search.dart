import 'dart:async';

import 'package:teatime/items/subreddit/tile.dart';
import 'package:teatime/utils/redditBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SearchSubredditWidget extends StatefulWidget {
  final void Function(dynamic subreddit) onFind;
  final Subreddit subreddit;
  const SearchSubredditWidget({Key key, @required this.onFind, this.subreddit})
      : super(key: key);

  @override
  _SearchSubredditWidgetState createState() => _SearchSubredditWidgetState();
}

class _SearchSubredditWidgetState extends State<SearchSubredditWidget> {
  final TextEditingController _subredditController = TextEditingController();
  bool showError = false;
  RedditBloc redditState;

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

  @override
  Widget build(BuildContext context) {
    redditState = RedditProvider.of(context);
    return TypeAheadFormField(
        initialValue: widget.subreddit?.displayName ?? null,
        textFieldConfiguration: TextFieldConfiguration(
            enabled: widget.subreddit == null,
            controller: _subredditController,
            decoration: InputDecoration(
                border: InputBorder.none,
                errorText: showError ? "Select a subreddit" : null,
                labelText: "Subreddit")),
        onSuggestionSelected: (subreddit) {
          _subredditController.text = subreddit.displayName;
          widget.onFind(subreddit);
        },
        itemBuilder: (context, result) => SubredditTile(
              subreddit: result,
            ),
        suggestionsCallback: searchSubreddits);
  }
}
