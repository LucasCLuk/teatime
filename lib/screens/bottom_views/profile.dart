import 'package:teatime/items/items.dart';
import 'package:teatime/items/profile/about.dart';
import 'package:teatime/screens/general/compose_private_message.dart';
import 'package:teatime/screens/general/profile_message.dart';
import 'package:teatime/utils/enums.dart';
import 'package:teatime/utils/redditBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatefulWidget {
  final RedditorRef redditor;

  const ProfileWidget({Key key, this.redditor}) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> with RouteAware, SingleTickerProviderStateMixin {
  RedditBloc redditState;
  RedditorRef redditor;
  TabController _tabController;
  ScrollController _scrollViewController;
  @override
  void initState() {
    super.initState();
    redditor = widget.redditor;
    _tabController = TabController(vsync: this, length: 7);
    _scrollViewController = ScrollController(initialScrollOffset: 0.0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollViewController.dispose();
    super.dispose();
  }

  List<Tab> buildTabs() {
    return ProfileTabs.values
        .map(
            (ProfileTabs tab) => Tab(child: Text(tab.toString().split(".")[1])))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    redditState = RedditProvider.of(context);
    redditor ??= redditState.currentAccount.redditor;
    var _scaffold = Scaffold.of(context, nullOk: true);
    return NestedScrollView(
      controller: _scrollViewController,
      headerSliverBuilder: (context,isScrolled){
        return <Widget>[
          SliverAppBar(
            snap: true,
            floating: true,
            forceElevated: isScrolled,
            title: Text(redditor?.displayName ?? ""),
            leading: IconButton(
                icon: Icon(_scaffold != null ? Icons.menu : Icons.arrow_back),
                onPressed: () {
                  if (_scaffold != null) {
                    Scaffold.of(context).openDrawer();
                  } else {
                    Navigator.pop(context);
                  }
                }),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ComposePrivateMessage(
                            redditor: redditor.displayName !=
                                redditState
                                    .currentAccount.redditor.displayName
                                ? redditor
                                : null,
                          )));
                },
                tooltip: "Send",
              )
            ],
            bottom: TabBar(
              tabs: buildTabs(),
              isScrollable: true,
              controller: _tabController,
            ),
          ),
        ];
      },
      body: new TabBarView(
          controller: _tabController,
          children: [
        ProfileMessage(
          redditor: redditor,
          endpoint: "overview",
        ),
        About(redditor: redditor),
        ProfileMessage(redditor: redditor, endpoint: "submitted"),
        ProfileMessage(redditor: redditor, endpoint: "comments"),
        ProfileMessage(redditor: redditor, endpoint: "hidden"),
        ProfileMessage(redditor: redditor, endpoint: "saved"),
        ProfileMessage(redditor: redditor, endpoint: "gilded"),
      ]),
    );
  }
}