import 'package:teatime/items/general/listing.dart';
import 'package:teatime/items/post/post.dart';
import 'package:teatime/items/profile/message.dart';
import 'package:teatime/screens/general/retry.dart';
import 'package:teatime/utils/listingBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';
import 'package:teatime/utils/utils.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';


class ProfileMessage extends StatefulWidget {
  final RedditorRef redditor;
  final String endpoint;

  const ProfileMessage({Key key, this.redditor, this.endpoint}) : super(key: key);
  @override
  _ProfileMessageState createState() => _ProfileMessageState();
}

class _ProfileMessageState extends State<ProfileMessage> with AutomaticKeepAliveClientMixin<ProfileMessage> {
  RedditorRef redditor;
  RedditBloc redditState;


  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    redditor = widget.redditor;
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    redditState = RedditProvider.of(context);
    if (redditor != null) {
      return ListingBuilder(
        refresh: false,
        listingBloc: ListingBloc(
            endpoint: "user/${redditor.displayName}/${widget.endpoint}",
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
        }, sliverAppBar: null,
      );
    } else {
      return RetryWidget(
        message: Text("No Information Found"),
        onTap: () {
          setState(() {});
        },
      );
    }
  }
}
