import 'package:teatime/items/post/comment.dart';
import 'package:teatime/items/post/summary.dart';
import 'package:teatime/items/subreddit/tile.dart';
import 'package:teatime/screens/general/loading_screen.dart';
import 'package:teatime/utils/redditBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';
import 'package:teatime/utils/utils.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with RouteAware {
  final TextEditingController controller = TextEditingController();
  RedditBloc redditState;
  String query = "";
  List<dynamic> results = [];
  bool isSearching = false;
  List<String> qOptions = ["Posts With", "Subreddits With"];
  String searchType;

  AppBar buildSearchBar(BuildContext context) {
    ThemeData theme = Theme.of(context);
    List<dynamic> results = [];
    Color barColor = theme.canvasColor;
    return new AppBar(
      backgroundColor: barColor,
      title: new Directionality(
          textDirection: Directionality.of(context),
          child: new TextField(
            key: new Key('SearchBarTextField'),
            keyboardType: TextInputType.text,
            style: new TextStyle(fontSize: 16.0),
            decoration: new InputDecoration(
                hintText: "Search",
                hintStyle: new TextStyle(fontSize: 16.0),
                border: null),
            onChanged: (String value) {
              setState(() {
                query = value;
              });
            },
            autofocus: true,
            controller: controller,
          )),
      actions: <Widget>[
        // Show an icon if clear is not active, so there's no ripple on tap
        new IconButton(
            icon: new Icon(Icons.clear),
            onPressed: () {
              controller.clear();
              setState(() {
                results.clear();
                query = "";
                isSearching = false;
              });
            })
      ],
    );
  }

  Widget buildRow() {
    return new ListView(
      children: qOptions
          .map((String option) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                child: Container(
                  height: 50.0,
                  width: double.infinity,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isSearching = true;
                        searchType = option;
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.search),
                        Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: Text("$option $query"),
                        )
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  List<dynamic> _buildParams() {
    Map<String, String> params = {"q": query, "sort": "relevance"};
    String endPoint;
    switch (searchType.toLowerCase()) {
      case "posts with":
        endPoint = "/search";
        break;
      case "subreddits with":
        endPoint = "/api/subreddit_autocomplete_v2";
        params = {
          "query": query,
          "include_over_18": "${!redditState.preferences.filterNSFW}",
          "include_profiles": "${false}",
          "include_categories": "${false}"
        };
        break;
      case "go to user":
        endPoint = "/profiles/search";
        params = {
          "q": query,
          "sort": "relevance",
        };
        break;
    }
    return [params, endPoint];
  }

  Widget buildResults() {
    List<dynamic> data = _buildParams();
    return FutureBuilder(
      future: redditState.reddit.get(data[1], params: data[0]),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data["listing"].length,
            itemBuilder: (context, index) {
              var item = snapshot.data["listing"][index];
              switch (item.runtimeType) {
                case Subreddit:
                  return SubredditTile(
                    subreddit: item,
                    onTap: () => redditState.changeSubreddit(context,item),
                  );
                case Submission:
                  return PostSummary(post: item);
                case Comment:
                  return CommentWidget(
                    comment: item,
                    commentBloc: CommentBloc(submission: null),
                  );
                default:
                  return ListTile(
                    title: Text(item.runtimeType.toString()),
                  );
              }
            },
          );
        } else {
          return LoadingScreen();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    redditState = RedditProvider.of(context);
    return Scaffold(
      appBar: buildSearchBar(context),
      body: isSearching
          ? buildResults()
          : query.length > 0 ? buildRow() : Container(),
    );
  }
}
