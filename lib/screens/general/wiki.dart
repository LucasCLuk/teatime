import 'package:teatime/items/general/general.dart';
import 'package:teatime/utils/utils.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

class Wiki extends StatelessWidget {
  final Subreddit subreddit;

  const Wiki({Key key, this.subreddit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${subreddit.displayName} Wiki"),
        ),
        body: ListingBuilder(
            builder: (BuildContext context, ListingSnapShot<dynamic> snapshot) {
              return ListTile(title: Text(snapshot.data.toString()));
            },
            listingBloc: ListingBloc(
                endpoint: "${subreddit.path}",
                redditState: RedditProvider.of(context),
                isListing: false), sliverAppBar: SliverAppBar(),));
  }
}
