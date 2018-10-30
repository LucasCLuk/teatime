import 'package:teatime/items/general/general.dart';
import 'package:teatime/items/profile/avatar.dart';
import 'package:teatime/utils/listingBloc.dart';
import 'package:teatime/utils/redditBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> with RouteAware {
  @override
  Widget build(BuildContext context) {
    RedditBloc redditState = RedditProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Friends"),
      ),
      body: ListingBuilder(
          listingBloc: ListingBloc(
              redditState: redditState, endpoint: "/api/v1/me/friends"),
          builder: (context, ListingSnapShot<Redditor> item) {
            return ListTile(
              leading: ProfileIcon(
                iconURL: item.data.data['icon_img'],
              ),
              title: Text(item.data.displayName),
              trailing: IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () async =>
                      await item.data.unfriend().then(setState)),
            );
          }, sliverAppBar: SliverAppBar(),),
    );
  }
}
