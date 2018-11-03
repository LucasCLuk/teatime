import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:teatime/items/general/general.dart';
import 'package:teatime/items/post/post.dart';
import 'package:teatime/items/profile/profile.dart';
import 'package:teatime/screens/general/retry.dart';
import 'package:teatime/utils/utils.dart';

class SavedWidget extends StatefulWidget {
  @override
  _SavedWidgetState createState() => _SavedWidgetState();
}

class _SavedWidgetState extends State<SavedWidget> {
  final String endpoint = "saved";
  RedditBloc redditState;

  Widget buildListing(Redditor redditor) {
    return new ListingBuilder(
      refresh: false,
      listingBloc: ListingBloc(
          endpoint: "user/${redditor.displayName}/$endpoint",
          redditState: redditState),
      builder: (context, ListingSnapShot<dynamic> item) {
        switch (item.data.runtimeType) {
          case Comment:
            return CommentWidget(
              comment: item.data,
            );
          case Submission:
            return PostSummary(post: item.data);
          case Message:
            return MessageWidget(message: item.data);
          default:
            return Container(child: Text(item.data.toString()));
        }
      },
      sliverAppBar: SliverAppBar(
        title: Text("Saved"),
      ),
    );
  }

  Widget buildRetry() {
    return RetryWidget(
      message: Text("No Information Found"),
      onTap: () {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    redditState = RedditProvider.of(context);
    var redditor = redditState.currentAccount.redditor;
    return Scaffold(
      body: redditor != null ? buildListing(redditor) : buildRetry(),
    );
  }
}
